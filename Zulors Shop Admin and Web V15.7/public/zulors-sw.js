"use strict";

const CACHE_VERSION = "2026-08-14-01";
const STATIC_CACHE = "zulors-static-" + CACHE_VERSION;
const NAVIGATION_CACHE = "zulors-navigation-" + CACHE_VERSION;
const NAVIGATION_TTL_MS = 5 * 60 * 1000;
const SAME_ORIGIN = self.location.origin;
const STATIC_ASSET_PATTERN = /\.(?:css|js|mjs|png|jpg|jpeg|gif|svg|webp|avif|ico|woff2?|ttf|otf|eot)$/i;
const EXCLUDED_NAVIGATION_PREFIXES = [
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

self.addEventListener("install", function () {
    self.skipWaiting();
});

self.addEventListener("activate", function (event) {
    event.waitUntil(
        caches.keys().then(function (keys) {
            return Promise.all(
                keys
                    .filter(function (key) {
                        return key.startsWith("zulors-") && key !== STATIC_CACHE && key !== NAVIGATION_CACHE;
                    })
                    .map(function (key) {
                        return caches.delete(key);
                    })
            );
        }).then(function () {
            return self.clients.claim();
        })
    );
});

self.addEventListener("message", function (event) {
    const data = event.data || {};
    if (data.type === "PREFETCH_URL" && typeof data.url === "string") {
        event.waitUntil(prefetchNavigationUrl(data.url));
    }
});

self.addEventListener("fetch", function (event) {
    const request = event.request;
    if (request.method !== "GET") {
        return;
    }

    const url = new URL(request.url);
    if (url.origin !== SAME_ORIGIN) {
        return;
    }

    if (request.mode === "navigate") {
        if (!shouldCacheNavigation(url)) {
            return;
        }

        event.respondWith(handleNavigationRequest(request));
        return;
    }

    if (STATIC_ASSET_PATTERN.test(url.pathname)) {
        event.respondWith(handleStaticAssetRequest(request));
    }
});

async function handleStaticAssetRequest(request) {
    const cache = await caches.open(STATIC_CACHE);
    const cachedResponse = await cache.match(request);

    const networkFetch = fetch(request)
        .then(function (response) {
            if (response.ok) {
                cache.put(request, response.clone());
            }
            return response;
        })
        .catch(function () {
            return cachedResponse;
        });

    return cachedResponse || networkFetch;
}

async function handleNavigationRequest(request) {
    const cache = await caches.open(NAVIGATION_CACHE);
    const cachedResponse = await cache.match(request);

    if (cachedResponse && isNavigationCacheFresh(cachedResponse)) {
        refreshNavigationCache(request);
        return cachedResponse;
    }

    try {
        const networkResponse = await fetch(request);
        if (networkResponse.ok && isHtmlResponse(networkResponse)) {
            await cache.put(request, await createTimestampedResponse(networkResponse.clone()));
        }
        return networkResponse;
    } catch (error) {
        if (cachedResponse) {
            return cachedResponse;
        }
        throw error;
    }
}

async function refreshNavigationCache(request) {
    try {
        const response = await fetch(request);
        if (response.ok && isHtmlResponse(response)) {
            const cache = await caches.open(NAVIGATION_CACHE);
            await cache.put(request, await createTimestampedResponse(response.clone()));
        }
    } catch (error) {
        return null;
    }

    return null;
}

async function prefetchNavigationUrl(rawUrl) {
    const url = new URL(rawUrl, SAME_ORIGIN);
    if (url.origin !== SAME_ORIGIN || !shouldCacheNavigation(url)) {
        return;
    }

    const request = new Request(url.toString(), {
        method: "GET",
        credentials: "include",
        mode: "same-origin",
        headers: {
            "X-Zulors-Prefetch": "1",
        },
    });

    const cache = await caches.open(NAVIGATION_CACHE);
    const cachedResponse = await cache.match(request);
    if (cachedResponse && isNavigationCacheFresh(cachedResponse)) {
        return;
    }

    const networkResponse = await fetch(request);
    if (networkResponse.ok && isHtmlResponse(networkResponse)) {
        await cache.put(request, await createTimestampedResponse(networkResponse.clone()));
    }
}

function shouldCacheNavigation(url) {
    return !EXCLUDED_NAVIGATION_PREFIXES.some(function (prefix) {
        return url.pathname.startsWith(prefix);
    });
}

function isHtmlResponse(response) {
    const contentType = response.headers.get("content-type") || "";
    return contentType.indexOf("text/html") !== -1;
}

function isNavigationCacheFresh(response) {
    const cachedAt = Number(response.headers.get("x-zulors-cache-time"));
    return Number.isFinite(cachedAt) && Date.now() - cachedAt < NAVIGATION_TTL_MS;
}

async function createTimestampedResponse(response) {
    const headers = new Headers(response.headers);
    headers.set("x-zulors-cache-time", Date.now().toString());
    const body = await response.blob();

    return new Response(body, {
        status: response.status,
        statusText: response.statusText,
        headers: headers,
    });
}
