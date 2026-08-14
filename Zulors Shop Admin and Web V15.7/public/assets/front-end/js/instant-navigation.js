"use strict";

(function () {
    const config = window.zulorsInstantNavigationConfig || {};
    if (config.enabled === false) {
        return;
    }

    const prefetchLimit = Number(config.prefetchLimit || 24);
    const prefetchedUrls = new Set();
    let totalPrefetched = 0;
    let serviceWorkerRegistration = null;
    let scanQueued = false;

    const excludedPrefixes = [
        "/admin",
        "/api",
        "/vendor",
        "/seller",
        "/customer",
        "/user-account",
        "/account",
        "/shop-cart",
        "/cart",
        "/checkout",
        "/payment",
        "/wishlists",
        "/compare",
        "/chat",
        "/messages",
        "/track-order",
        "/order",
        "/digital-product-download",
        "/login",
        "/logout",
    ];

    function supportsLinkPrefetch() {
        const link = document.createElement("link");
        return !!(link.relList && link.relList.supports && link.relList.supports("prefetch"));
    }

    function normalizeUrl(rawUrl) {
        try {
            const url = new URL(rawUrl, window.location.origin);
            if (url.origin !== window.location.origin) {
                return null;
            }

            if (url.hash && url.pathname === window.location.pathname && url.search === window.location.search) {
                return null;
            }

            if (excludedPrefixes.some((prefix) => url.pathname.startsWith(prefix))) {
                return null;
            }

            return url.toString();
        } catch (error) {
            return null;
        }
    }

    function getPrefetchUrl(target) {
        if (!(target instanceof Element)) {
            return null;
        }

        const clickableElement = target.closest("a[href], [data-prefetch-url], .get-view-by-onclick[data-link]");
        if (!clickableElement) {
            return null;
        }

        if (clickableElement.matches("a[href]")) {
            const targetValue = clickableElement.getAttribute("target");
            if (targetValue && targetValue !== "_self") {
                return null;
            }

            if (clickableElement.hasAttribute("download")) {
                return null;
            }

            return normalizeUrl(clickableElement.href);
        }

        return normalizeUrl(clickableElement.dataset.prefetchUrl || clickableElement.dataset.link || "");
    }

    function postMessageToServiceWorker(url) {
        const worker =
            serviceWorkerRegistration?.active ||
            serviceWorkerRegistration?.waiting ||
            serviceWorkerRegistration?.installing ||
            navigator.serviceWorker?.controller;

        if (!worker || typeof worker.postMessage !== "function") {
            return false;
        }

        worker.postMessage({
            type: "PREFETCH_URL",
            url: url,
        });
        return true;
    }

    function prefetchUrl(rawUrl, options) {
        const url = normalizeUrl(rawUrl);
        const highPriority = !!options?.highPriority;

        if (!url || prefetchedUrls.has(url)) {
            return;
        }

        if (!highPriority && totalPrefetched >= prefetchLimit) {
            return;
        }

        prefetchedUrls.add(url);
        totalPrefetched += 1;

        if (postMessageToServiceWorker(url)) {
            return;
        }

        if (supportsLinkPrefetch()) {
            const link = document.createElement("link");
            link.rel = "prefetch";
            link.as = "document";
            link.href = url;
            document.head.appendChild(link);
            return;
        }

        fetch(url, {
            credentials: "include",
            mode: "same-origin",
            headers: {
                "X-Zulors-Prefetch": "1",
            },
        }).catch(function () {
            prefetchedUrls.delete(url);
        });
    }

    function registerServiceWorker() {
        if (!("serviceWorker" in navigator) || !config.serviceWorkerUrl) {
            return;
        }

        navigator.serviceWorker
            .register(config.serviceWorkerUrl, { scope: "/" })
            .then(function (registration) {
                serviceWorkerRegistration = registration;
            })
            .catch(function () {
                serviceWorkerRegistration = null;
            });

        navigator.serviceWorker.ready
            .then(function (registration) {
                serviceWorkerRegistration = registration;
            })
            .catch(function () {
                serviceWorkerRegistration = null;
            });
    }

    function observeVisibleTargets() {
        const targets = document.querySelectorAll("a[href], .get-view-by-onclick[data-link], [data-prefetch-url]");

        targets.forEach(function (target) {
            if (target.dataset.prefetchObserved === "true") {
                return;
            }

            target.dataset.prefetchObserved = "true";

            if (visibilityObserver) {
                visibilityObserver.observe(target);
            } else if (totalPrefetched < prefetchLimit) {
                const rawUrl = target.matches("a[href]") ? target.href : (target.dataset.prefetchUrl || target.dataset.link || "");
                prefetchUrl(rawUrl);
            }
        });
    }

    function queueVisibleTargetScan() {
        if (scanQueued) {
            return;
        }

        scanQueued = true;
        window.requestAnimationFrame(function () {
            scanQueued = false;
            observeVisibleTargets();
        });
    }

    const visibilityObserver =
        "IntersectionObserver" in window
            ? new IntersectionObserver(
                  function (entries) {
                      entries.forEach(function (entry) {
                          if (!entry.isIntersecting) {
                              return;
                          }

                          const target = entry.target;
                          const rawUrl = target.matches("a[href]")
                              ? target.href
                              : target.dataset.prefetchUrl || target.dataset.link || "";

                          prefetchUrl(rawUrl);
                          visibilityObserver.unobserve(target);
                      });
                  },
                  {
                      rootMargin: "200px 0px",
                      threshold: 0.01,
                  }
              )
            : null;

    document.addEventListener(
        "pointerover",
        function (event) {
            const url = getPrefetchUrl(event.target);
            if (url) {
                prefetchUrl(url);
            }
        },
        { passive: true, capture: true }
    );

    document.addEventListener(
        "touchstart",
        function (event) {
            const url = getPrefetchUrl(event.target);
            if (url) {
                prefetchUrl(url, { highPriority: true });
            }
        },
        { passive: true, capture: true }
    );

    document.addEventListener(
        "mousedown",
        function (event) {
            const url = getPrefetchUrl(event.target);
            if (url) {
                prefetchUrl(url, { highPriority: true });
            }
        },
        { passive: true, capture: true }
    );

    document.addEventListener(
        "click",
        function (event) {
            const url = getPrefetchUrl(event.target);
            if (url) {
                prefetchUrl(url, { highPriority: true });
            }
        },
        { passive: true, capture: true }
    );

    if ("MutationObserver" in window) {
        const mutationObserver = new MutationObserver(function () {
            queueVisibleTargetScan();
        });

        document.addEventListener("DOMContentLoaded", function () {
            mutationObserver.observe(document.body, {
                childList: true,
                subtree: true,
            });
        });
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", function () {
            registerServiceWorker();
            queueVisibleTargetScan();
        });
    } else {
        registerServiceWorker();
        queueVisibleTargetScan();
    }

    window.addEventListener("load", function () {
        queueVisibleTargetScan();
    });

    document.addEventListener("visibilitychange", function () {
        if (!document.hidden) {
            queueVisibleTargetScan();
        }
    });
})();
