"use strict";

(function () {
    const config = window.zulorsInstantNavigationConfig || {};
    if (config.enabled === false) return;

    const prefetchLimit = Math.max(0, Math.min(Number(config.prefetchLimit || 8), 8));
    const maxConcurrentPrefetch = Math.max(1, Math.min(Number(config.maxConcurrentPrefetch || 2), 2));
    const maxTrackedPrefetches = 40;
    const prefetchTrackingTtl = 55 * 1000;
    const cachePartitionStorageKey = "zulors-storefront-cache-partition";
    const prefetchedUrls = new Map();
    const pendingUrls = new Set();
    const automaticPrefetchedUrls = new Set();
    const queue = [];
    const pendingPrefetches = new Map();
    let prefetchSequence = 0;
    let activePrefetches = 0;
    let serviceWorkerRegistration = null;
    let scanQueued = false;
    let progressShowTimer = null;
    let progressTimer = null;

    const eligiblePath = /^\/$|^\/product\/[^/]+\/?$|^\/products\/?$|^\/brand\/[^/]+\/?$|^\/category\/[^/]+\/?$|^\/(featured-products|featured-deal-products|latest-products|best-selling-products|top-rated-products|discounted-products|clearance-sale-products|brands|categories|vendors)\/?$|^\/flash-deals\/\d+\/?$/;
    const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    const constrainedConnection = !!(connection && (connection.saveData || /^(slow-)?2g$/i.test(connection.effectiveType || "")));

    function shouldPrefetch() {
        return !constrainedConnection && prefetchLimit > 0 && document.visibilityState !== "hidden";
    }

    function normalizeUrl(rawUrl) {
        try {
            const url = new URL(rawUrl, window.location.origin);
            if (url.origin !== window.location.origin || !eligiblePath.test(url.pathname)) return null;
            if (url.pathname === window.location.pathname && url.search === window.location.search) return null;
            if (url.username || url.password || url.hash) return null;
            return url.toString();
        } catch (error) {
            return null;
        }
    }

    function getPrefetchUrl(target) {
        if (!(target instanceof Element)) return null;
        const link = target.closest("a[href], [data-prefetch-url], .get-view-by-onclick[data-link]");
        if (!link) return null;
        if (link.matches("a[href]") && ((link.target && link.target !== "_self") || link.hasAttribute("download"))) return null;
        return normalizeUrl(link.matches("a[href]") ? link.href : (link.dataset.prefetchUrl || link.dataset.link || ""));
    }

    function activeWorker() {
        return serviceWorkerRegistration?.active || navigator.serviceWorker?.controller || null;
    }

    function sendWorkerMessage(message) {
        const worker = activeWorker();
        if (!worker || typeof worker.postMessage !== "function") return false;
        worker.postMessage(message);
        return true;
    }

    function sendPartition() {
        if (!config.cachePartition) return;
        sendWorkerMessage({ type: "SET_CACHE_PARTITION", partition: config.cachePartition });
    }

    function clearPartitionCache(partition) {
        if (/^[a-f0-9]{64}$/.test(partition || "")) {
            sendWorkerMessage({ type: "CLEAR_PARTITION_CACHE", partition: partition });
        }
    }

    function getPartitionStorage() {
        try {
            return window.localStorage || null;
        } catch (error) {
            return null;
        }
    }

    function resetPrefetchTracking() {
        prefetchedUrls.clear();
        automaticPrefetchedUrls.clear();
        queue.length = 0;
        pendingUrls.clear();
        document.querySelectorAll("a[href], .get-view-by-onclick[data-link], [data-prefetch-url]").forEach(function (target) {
            delete target.dataset.prefetchObserved;
        });
        queueVisibleTargetScan();
    }

    function setCachePartition(partition, broadcast) {
        if (!/^[a-f0-9]{64}$/.test(partition || "")) return false;

        const previousPartition = config.cachePartition;
        if (previousPartition !== partition) {
            clearPartitionCache(previousPartition);
            config.cachePartition = partition;
            sendPartition();
            resetPrefetchTracking();
        }

        const storage = getPartitionStorage();
        if (broadcast && storage) {
            try {
                storage.setItem(cachePartitionStorageKey, partition);
            } catch (error) {
                // Private browsing modes may deny storage; the current page still works.
            }
        }

        return true;
    }

    function synchronizeInitialPartition() {
        const storage = getPartitionStorage();
        if (!/^[a-f0-9]{64}$/.test(config.cachePartition || "") || !storage) return;

        try {
            const previousPartition = storage.getItem(cachePartitionStorageKey);
            if (previousPartition && previousPartition !== config.cachePartition) {
                clearPartitionCache(previousPartition);
            }
            storage.setItem(cachePartitionStorageKey, config.cachePartition);
        } catch (error) {
            // Service-worker caching remains partitioned even if storage is unavailable.
        }
    }

    function refreshCachePartition() {
        if (!config.partitionUrl || typeof window.fetch !== "function") return Promise.resolve();

        return window.fetch(config.partitionUrl, {
            method: "GET",
            credentials: "same-origin",
            cache: "no-store",
            headers: { Accept: "application/json" },
        }).then(function (response) {
            if (!response.ok) throw new Error("Could not refresh the storefront cache partition");
            return response.json();
        }).then(function (data) {
            setCachePartition(data.partition, true);
        }).catch(function () {
            // A stale partition cannot match the server marker, so navigation safely falls back to Laravel.
        });
    }

    function startPrefetch(rawUrl, highPriority) {
        if (!shouldPrefetch()) return;
        const url = normalizeUrl(rawUrl);
        if (!url) return;

        const now = Date.now();
        prefetchedUrls.forEach(function (startedAt, trackedUrl) {
            if (now - startedAt >= prefetchTrackingTtl && !pendingUrls.has(trackedUrl)) {
                prefetchedUrls.delete(trackedUrl);
            }
        });

        if (prefetchedUrls.has(url)) {
            prefetchedUrls.delete(url);
            prefetchedUrls.set(url, now);
            if (highPriority) promoteQueuedPrefetch(url);
            return;
        }

        if (!highPriority && automaticPrefetchedUrls.size >= prefetchLimit) return;
        if (!makePrefetchRoom(highPriority)) return;

        prefetchedUrls.set(url, now);
        pendingUrls.add(url);
        if (!highPriority) automaticPrefetchedUrls.add(url);

        const entry = { url: url, highPriority: !!highPriority };
        if (highPriority) queue.unshift(entry);
        else queue.push(entry);
        drainQueue();
    }

    function promoteQueuedPrefetch(url) {
        const index = queue.findIndex(function (entry) { return entry.url === url; });
        if (index < 0) return;

        const entry = queue.splice(index, 1)[0];
        entry.highPriority = true;
        queue.unshift(entry);
    }

    function makePrefetchRoom(highPriority) {
        if (prefetchedUrls.size < maxTrackedPrefetches) return true;

        for (const trackedUrl of prefetchedUrls.keys()) {
            if (pendingUrls.has(trackedUrl)) continue;
            prefetchedUrls.delete(trackedUrl);
            return true;
        }

        if (!highPriority) return false;

        for (let index = queue.length - 1; index >= 0; index -= 1) {
            const queued = queue[index];
            if (queued.highPriority) continue;
            queue.splice(index, 1);
            pendingUrls.delete(queued.url);
            prefetchedUrls.delete(queued.url);
            return true;
        }

        return false;
    }

    function drainQueue() {
        while (shouldPrefetch() && activePrefetches < maxConcurrentPrefetch && queue.length) {
            const entry = queue.shift();
            activePrefetches += 1;
            prefetch(entry.url).finally(function () {
                activePrefetches = Math.max(0, activePrefetches - 1);
                pendingUrls.delete(entry.url);
                drainQueue();
            });
        }
    }

    function prefetch(url) {
        const worker = activeWorker();
        if (worker && typeof worker.postMessage === "function") {
            const id = ++prefetchSequence;
            return new Promise(function (resolve) {
                const timeout = window.setTimeout(function () {
                    pendingPrefetches.delete(id);
                    resolve();
                }, 12000);
                pendingPrefetches.set(id, function () {
                    window.clearTimeout(timeout);
                    pendingPrefetches.delete(id);
                    resolve();
                });
                worker.postMessage({ type: "PREFETCH_URL", url: url, partition: config.cachePartition, id: id });
            });
        }

        const link = document.createElement("link");
        link.rel = "prefetch";
        link.as = "document";
        link.href = url;
        document.head.appendChild(link);
        return new Promise(function (resolve) { window.setTimeout(resolve, 500); });
    }

    function registerServiceWorker() {
        if (!("serviceWorker" in navigator) || !config.serviceWorkerUrl) return;

        navigator.serviceWorker.register(config.serviceWorkerUrl, { scope: "/" })
            .then(function (registration) {
                serviceWorkerRegistration = registration;
                synchronizeInitialPartition();
                sendPartition();
                registration.addEventListener("updatefound", sendPartition);
            })
            .catch(function () { serviceWorkerRegistration = null; });

        navigator.serviceWorker.ready.then(function (registration) {
            serviceWorkerRegistration = registration;
            synchronizeInitialPartition();
            sendPartition();
        }).catch(function () { serviceWorkerRegistration = null; });

        navigator.serviceWorker.addEventListener("controllerchange", sendPartition);
    }

    function observeVisibleTargets() {
        document.querySelectorAll("a[href], .get-view-by-onclick[data-link], [data-prefetch-url]").forEach(function (target) {
            if (target.dataset.prefetchObserved === "true") return;
            target.dataset.prefetchObserved = "true";
            if (visibilityObserver) visibilityObserver.observe(target);
        });
    }

    function queueVisibleTargetScan() {
        if (scanQueued) return;
        scanQueued = true;
        window.requestAnimationFrame(function () {
            scanQueued = false;
            observeVisibleTargets();
        });
    }

    const visibilityObserver = "IntersectionObserver" in window
        ? new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                const url = getPrefetchUrl(entry.target);
                if (url) startPrefetch(url, false);
                visibilityObserver.unobserve(entry.target);
            });
        }, { rootMargin: "150px 0px", threshold: 0.01 })
        : null;

    function ensureProgressBar() {
        let bar = document.getElementById("zulors-navigation-progress");
        if (!bar) {
            bar = document.createElement("div");
            bar.id = "zulors-navigation-progress";
            bar.setAttribute("role", "progressbar");
            bar.setAttribute("aria-label", "Loading page");
            document.body.appendChild(bar);
        }
        return bar;
    }

    function showNavigationFeedback() {
        if (progressShowTimer) window.clearTimeout(progressShowTimer);
        if (progressTimer) window.clearTimeout(progressTimer);

        // Most prefetched navigations finish before this delay, so they do not flash a loader.
        progressShowTimer = window.setTimeout(function () {
            const bar = ensureProgressBar();
            bar.classList.remove("is-complete");
            bar.classList.add("is-visible");
        }, 120);
        progressTimer = window.setTimeout(function () {
            const bar = document.getElementById("zulors-navigation-progress");
            if (!bar) return;
            bar.classList.add("is-complete");
            bar.classList.remove("is-visible");
        }, 1920);
    }

    function clearNavigationFeedback() {
        if (progressShowTimer) window.clearTimeout(progressShowTimer);
        if (progressTimer) window.clearTimeout(progressTimer);
        progressShowTimer = null;
        progressTimer = null;
        const bar = document.getElementById("zulors-navigation-progress");
        if (bar) {
            bar.classList.remove("is-visible");
            bar.classList.add("is-complete");
        }
    }

    document.addEventListener("pointerover", function (event) {
        const url = getPrefetchUrl(event.target);
        if (url) startPrefetch(url, true);
    }, { passive: true, capture: true });

    document.addEventListener("touchstart", function (event) {
        const url = getPrefetchUrl(event.target);
        if (url) startPrefetch(url, true);
    }, { passive: true, capture: true });

    document.addEventListener("click", function (event) {
        if (event.defaultPrevented || (event.button !== undefined && event.button !== 0)
            || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

        const url = getPrefetchUrl(event.target);
        if (url) {
            startPrefetch(url, true);
            showNavigationFeedback();
        }
    }, { passive: true, capture: true });

    if ("serviceWorker" in navigator) {
        navigator.serviceWorker.addEventListener("message", function (event) {
            if (event.data?.type !== "PREFETCH_DONE") return;
            const done = pendingPrefetches.get(event.data.id);
            if (done) done();
        });
    }

    window.clearZulorsPrefetchedPages = function () {
        clearPartitionCache(config.cachePartition);
        resetPrefetchTracking();
    };

    window.addEventListener("storage", function (event) {
        if (event.key === cachePartitionStorageKey && event.newValue) {
            setCachePartition(event.newValue, false);
        }
    });

    window.addEventListener("pageshow", function (event) {
        clearNavigationFeedback();
        if (!event.persisted) return;

        refreshCachePartition();
        if (window.jQuery && typeof window.updateNavCart === "function"
            && document.getElementById("route-cart-nav-cart")) {
            window.updateNavCart();
        }
    });

    window.addEventListener("pagehide", clearNavigationFeedback);

    if (window.jQuery) {
        const stateChangingEndpoints = [
            "#route-cart-add",
            "#route-cart-remove",
            "#route-cart-updateQuantity",
            "#route-cart-updateQuantity-guest",
            "#route-currency-change",
            "#route-store-wishlist",
            "#route-delete-wishlist",
        ];

        jQuery(document).on("ajaxSuccess", function (_event, _xhr, settings) {
            let requestUrl;
            try {
                requestUrl = new URL(settings.url, window.location.origin);
            } catch (error) {
                return;
            }

            const changesCachedStorefrontState = stateChangingEndpoints.some(function (selector) {
                const endpoint = document.querySelector(selector)?.dataset.url;
                if (!endpoint) return false;
                try {
                    const endpointUrl = new URL(endpoint, window.location.origin);
                    return endpointUrl.origin === requestUrl.origin && endpointUrl.pathname === requestUrl.pathname;
                } catch (error) {
                    return false;
                }
            });

            if (changesCachedStorefrontState) {
                window.clearZulorsPrefetchedPages();
                refreshCachePartition();
            }
        });
    }

    if ("MutationObserver" in window) {
        const mutationObserver = new MutationObserver(queueVisibleTargetScan);
        document.addEventListener("DOMContentLoaded", function () {
            mutationObserver.observe(document.body, { childList: true, subtree: true });
        }, { once: true });
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", function () {
            registerServiceWorker();
            queueVisibleTargetScan();
        }, { once: true });
    } else {
        registerServiceWorker();
        queueVisibleTargetScan();
    }

    window.addEventListener("load", queueVisibleTargetScan, { once: true });
})();
