"use strict";

const CACHE_VERSION = "2026-10-28-02";
const STATIC_CACHE = "zulors-static-" + CACHE_VERSION;
const NAVIGATION_CACHE = "zulors-navigation-" + CACHE_VERSION;
const NAVIGATION_TTL_MS = 60 * 1000;
const NAVIGATION_CACHE_MAX_ENTRIES = 40;
const SAME_ORIGIN = self.location.origin;
const STATIC_ASSET_PATTERN = /\.(?:css|js|mjs|png|jpg|jpeg|gif|svg|webp|avif|ico|woff2?|ttf|otf|eot)$/i;
const ALLOWED_NAVIGATION_PATTERNS = [
    /^\/$/,
    /^\/product\/[^/]+\/?$/,
    /^\/products\/?$/,
    /^\/brand\/[^/]+\/?$/,
    /^\/category\/[^/]+\/?$/,
    /^\/(?:featured-products|featured-deal-products|latest-products|best-selling-products|top-rated-products|discounted-products|clearance-sale-products|brands|categories|vendors)\/?$/,
    /^\/flash-deals\/\d+\/?$/,
];
const clientPartitions = new Map();
const partitionCacheEpochs = new Map();
let lastNavigationPruneAt = 0;
let navigationPrunePromise = null;

self.addEventListener("install", function (event) {
    event.waitUntil(self.skipWaiting());
});

self.addEventListener("activate", function (event) {
    event.waitUntil(
        caches.keys().then(function (keys) {
            return Promise.all(
                keys
                    .filter(function (key) {
                        return key.startsWith("zulors-") && key !== STATIC_CACHE && key !== NAVIGATION_CACHE;
                    })
                    .map(function (key) { return caches.delete(key); })
            );
        }).then(function () {
            return self.clients.claim();
        })
    );
});

self.addEventListener("message", function (event) {
    const data = event.data || {};
    const clientId = event.source && event.source.id;

    if (data.type === "SET_CACHE_PARTITION" && clientId && /^[a-f0-9]{64}$/.test(data.partition || "")) {
        clientPartitions.set(clientId, data.partition);
        return;
    }

    if (data.type === "PREFETCH_URL" && typeof data.url === "string" && clientId) {
        const partition = clientPartitions.get(clientId)
            || (/^[a-f0-9]{64}$/.test(data.partition || "") ? data.partition : null);
        if (partition) clientPartitions.set(clientId, partition);
        if (partition) {
            const epoch = getPartitionCacheEpoch(partition);
            event.waitUntil(prefetchNavigationUrl(data.url, partition, epoch).finally(function () {
                event.source.postMessage({ type: "PREFETCH_DONE", id: data.id });
            }));
        }
        return;
    }

    if (data.type === "CLEAR_PARTITION_CACHE" && clientId) {
        const partition = /^[a-f0-9]{64}$/.test(data.partition || "")
            ? data.partition
            : clientPartitions.get(clientId);
        if (partition) {
            partitionCacheEpochs.set(partition, getPartitionCacheEpoch(partition) + 1);
            event.waitUntil(clearPartitionCache(partition));
        }
    }
});

self.addEventListener("fetch", function (event) {
    const request = event.request;
    if (request.method !== "GET") return;

    const url = new URL(request.url);
    if (url.origin !== SAME_ORIGIN) return;

    if (request.mode === "navigate") {
        if (!shouldCacheNavigation(url)) return;

        // No partition has been provided yet (for example, a first visit or
        // a new tab): bypass HTML caching and let Laravel serve the response.
        const partition = clientPartitions.get(event.clientId);
        if (!partition) return;

        event.respondWith(handleNavigationRequest(request, partition, event));
        return;
    }

    if (STATIC_ASSET_PATTERN.test(url.pathname)) {
        event.respondWith(handleStaticAssetRequest(request, event));
    }
});

async function handleStaticAssetRequest(request, event) {
    const cache = await caches.open(STATIC_CACHE);
    const cachedResponse = await cache.match(request);
    if (cachedResponse) {
        event.waitUntil(refreshStaticAsset(request, cache));
        return cachedResponse;
    }

    const response = await fetch(request);
    if (response.ok && isCacheableStaticAsset(response)) {
        await cache.put(request, response.clone());
    }
    return response;
}

function refreshStaticAsset(request, cache) {
    fetch(request).then(function (response) {
        if (response.ok && isCacheableStaticAsset(response)) return cache.put(request, response.clone());
        return null;
    }).catch(function () { return null; });
}

async function handleNavigationRequest(request, partition, event) {
    const cache = await caches.open(NAVIGATION_CACHE);
    await pruneNavigationCache(cache);
    const epoch = getPartitionCacheEpoch(partition);
    const cacheKey = navigationCacheKey(request.url, partition, epoch);
    const cachedResponse = await cache.match(cacheKey);

    if (cachedResponse && isNavigationCacheFresh(cachedResponse)) {
        event.waitUntil(refreshNavigationCache(request, partition, cacheKey, epoch));
        return cachedResponse;
    }

    try {
        const response = await fetchNavigation(request, partition);
        if (getPartitionCacheEpoch(partition) === epoch && isCacheableNavigationResponse(response, partition)) {
            await cache.put(cacheKey, await createTimestampedResponse(response.clone()));
        }
        return response;
    } catch (error) {
        throw error;
    }
}

async function refreshNavigationCache(request, partition, cacheKey, epoch) {
    try {
        const response = await fetchNavigation(request, partition);
        if (getPartitionCacheEpoch(partition) === epoch && isCacheableNavigationResponse(response, partition)) {
            const cache = await caches.open(NAVIGATION_CACHE);
            await cache.put(cacheKey, await createTimestampedResponse(response.clone()));
        }
    } catch (error) {
        return null;
    }
    return null;
}

async function prefetchNavigationUrl(rawUrl, partition, epoch) {
    let url;
    try {
        url = new URL(rawUrl, SAME_ORIGIN);
    } catch (error) {
        return;
    }

    if (url.origin !== SAME_ORIGIN || !shouldCacheNavigation(url)) return;

    const cache = await caches.open(NAVIGATION_CACHE);
    await pruneNavigationCache(cache);
    const cacheKey = navigationCacheKey(url.toString(), partition, epoch);
    const cachedResponse = await cache.match(cacheKey);
    if (cachedResponse && isNavigationCacheFresh(cachedResponse)) return;

    try {
        const request = new Request(url.toString(), {
            method: "GET",
            credentials: "include",
            mode: "same-origin",
            headers: {
                "Accept": "text/html",
                "X-Zulors-Prefetch": "1",
                "X-Zulors-Cache-Partition": partition,
            },
        });
        const response = await fetch(request);
        if (getPartitionCacheEpoch(partition) === epoch && isCacheableNavigationResponse(response, partition)) {
            await cache.put(cacheKey, await createTimestampedResponse(response.clone()));
        }
    } catch (error) {
        return null;
    }
}

function getPartitionCacheEpoch(partition) {
    return partitionCacheEpochs.get(partition) || 0;
}

function fetchNavigation(request, partition) {
    const headers = new Headers(request.headers);
    headers.set("X-Zulors-Cache-Partition", partition);
    headers.set("X-Zulors-Navigation", "1");
    return fetch(new Request(request, { headers: headers, cache: "no-store" }));
}

async function clearPartitionCache(partition) {
    const cache = await caches.open(NAVIGATION_CACHE);
    const keys = await cache.keys();
    return Promise.all(keys.filter(function (request) {
        return new URL(request.url).searchParams.get("__zulors_partition") === partition;
    }).map(function (request) { return cache.delete(request); }));
}

async function pruneNavigationCache(cache) {
    if (navigationPrunePromise) return navigationPrunePromise;
    if (Date.now() - lastNavigationPruneAt < 10000) return;

    navigationPrunePromise = pruneNavigationCacheEntries(cache).finally(function () {
        lastNavigationPruneAt = Date.now();
        navigationPrunePromise = null;
    });
    return navigationPrunePromise;
}

async function pruneNavigationCacheEntries(cache) {
    const keys = await cache.keys();
    const entries = await Promise.all(keys.map(async function (request) {
        const response = await cache.match(request);
        const cachedAt = Number(response && response.headers.get("x-zulors-cache-time"));
        return { request: request, cachedAt: Number.isFinite(cachedAt) ? cachedAt : 0 };
    }));
    const expired = entries.filter(function (entry) {
        return !entry.cachedAt || Date.now() - entry.cachedAt >= NAVIGATION_TTL_MS;
    });
    await Promise.all(expired.map(function (entry) { return cache.delete(entry.request); }));

    const live = entries.filter(function (entry) { return entry.cachedAt && Date.now() - entry.cachedAt < NAVIGATION_TTL_MS; })
        .sort(function (a, b) { return b.cachedAt - a.cachedAt; });
    const excess = live.slice(NAVIGATION_CACHE_MAX_ENTRIES);
    await Promise.all(excess.map(function (entry) { return cache.delete(entry.request); }));
}

function navigationCacheKey(rawUrl, partition, epoch) {
    const keyUrl = new URL(rawUrl, SAME_ORIGIN);
    keyUrl.searchParams.set("__zulors_partition", partition);
    keyUrl.searchParams.set("__zulors_epoch", String(epoch));
    return new Request(keyUrl.toString(), { method: "GET", credentials: "same-origin" });
}

function shouldCacheNavigation(url) {
    return ALLOWED_NAVIGATION_PATTERNS.some(function (pattern) { return pattern.test(url.pathname); });
}

function isCacheableStaticAsset(response) {
    const cacheControl = (response.headers.get("cache-control") || "").toLowerCase();
    return response.ok && !cacheControl.includes("no-store");
}

function isCacheableNavigationResponse(response, partition) {
    const contentType = (response.headers.get("content-type") || "").toLowerCase();
    return response.ok
        && response.redirected !== true
        && contentType.includes("text/html")
        && response.headers.get("x-zulors-cacheable") === "session"
        && response.headers.get("x-zulors-cache-partition") === partition;
}

function isNavigationCacheFresh(response) {
    const cachedAt = Number(response.headers.get("x-zulors-cache-time"));
    return Number.isFinite(cachedAt) && Date.now() - cachedAt < NAVIGATION_TTL_MS;
}

async function createTimestampedResponse(response) {
    const headers = new Headers(response.headers);
    headers.set("x-zulors-cache-time", Date.now().toString());
    const body = await response.blob();
    return new Response(body, { status: response.status, statusText: response.statusText, headers: headers });
}
