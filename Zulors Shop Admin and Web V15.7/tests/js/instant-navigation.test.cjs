const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const navigationScript = fs.readFileSync(
    path.join(__dirname, '../../public/assets/front-end/js/instant-navigation.js'),
    'utf8'
);
const serviceWorkerScript = fs.readFileSync(
    path.join(__dirname, '../../public/zulors-sw.js'),
    'utf8'
);

class FakeElement {
    constructor(href) {
        this.href = href;
        this.target = '';
        this.dataset = {};
    }

    closest() {
        return this;
    }

    matches(selector) {
        return selector === 'a[href]';
    }

    hasAttribute() {
        return false;
    }
}

function bootNavigation({ saveData = false, effectiveType = '4g', nextPartition = 'a'.repeat(64), storedPartition = null, storageAvailable = true } = {}) {
    const links = Array.from({ length: 10 }, (_, index) => new FakeElement(
        `https://shop.zulors.com/product/performance-test-${index}`
    ));
    const documentListeners = new Map();
    const serviceWorkerListeners = new Map();
    const windowListeners = new Map();
    const workerMessages = [];
    const localStorageValues = new Map(storedPartition ? [['zulors-storefront-cache-partition', storedPartition]] : []);
    let visibilityObserver;
    let activeRequests = 0;
    let maxActiveRequests = 0;
    let activePartition = 'a'.repeat(64);
    let cartRefreshes = 0;
    const prefetchMessages = [];

    const serviceWorker = {
        postMessage(message) {
            workerMessages.push(message);
            if (message.type === 'SET_CACHE_PARTITION') activePartition = message.partition;
            if (message.type !== 'PREFETCH_URL') return;
            prefetchMessages.push(message);
            activeRequests += 1;
            maxActiveRequests = Math.max(maxActiveRequests, activeRequests);
            setTimeout(function () {
                activeRequests -= 1;
                const listeners = serviceWorkerListeners.get('message') || [];
                listeners.forEach(function (listener) {
                    listener({ data: { type: 'PREFETCH_DONE', id: message.id } });
                });
            }, 5);
        },
    };

    const registration = {
        active: serviceWorker,
        addEventListener() {},
    };

    const serviceWorkerContainer = {
        controller: serviceWorker,
        ready: Promise.resolve(registration),
        register: async function () { return registration; },
        addEventListener(type, listener) {
            const listeners = serviceWorkerListeners.get(type) || [];
            listeners.push(listener);
            serviceWorkerListeners.set(type, listeners);
        },
    };

    class FakeIntersectionObserver {
        constructor(callback) {
            this.callback = callback;
            this.targets = [];
            visibilityObserver = this;
        }

        observe(target) {
            this.targets.push(target);
        }

        unobserve() {}
    }

    const document = {
        visibilityState: 'visible',
        readyState: 'complete',
        body: {},
        querySelectorAll() { return links; },
        addEventListener(type, listener) {
            const listeners = documentListeners.get(type) || [];
            listeners.push(listener);
            documentListeners.set(type, listeners);
        },
        getElementById(id) { return id === 'route-cart-nav-cart' ? {} : null; },
        createElement() { return { classList: { add() {}, remove() {} }, setAttribute() {}, appendChild() {} }; },
        dispatch(type, event) {
            (documentListeners.get(type) || []).forEach(function (listener) { listener(event); });
        },
    };

    const window = {
        zulorsInstantNavigationConfig: {
            enabled: true,
            prefetchLimit: 8,
            maxConcurrentPrefetch: 2,
            cachePartition: 'a'.repeat(64),
            partitionUrl: '/storefront/navigation-context',
            serviceWorkerUrl: '/zulors-sw.js',
        },
        location: { origin: 'https://shop.zulors.com', pathname: '/', search: '' },
        requestAnimationFrame(callback) { callback(); },
        IntersectionObserver: FakeIntersectionObserver,
        get localStorage() {
            if (!storageAvailable) throw new Error('Storage access is blocked');
            return {
                getItem(key) { return localStorageValues.get(key) || null; },
                setItem(key, value) { localStorageValues.set(key, value); },
            };
        },
        fetch() {
            return Promise.resolve({
                ok: true,
                json() { return Promise.resolve({ partition: nextPartition }); },
            });
        },
        jQuery() { return { on() {} }; },
        updateNavCart() { cartRefreshes += 1; },
        setTimeout,
        clearTimeout,
        addEventListener(type, listener) {
            const listeners = windowListeners.get(type) || [];
            listeners.push(listener);
            windowListeners.set(type, listeners);
        },
        dispatch(type, event) {
            (windowListeners.get(type) || []).forEach(listener => listener(event));
        },
    };

    vm.runInNewContext(navigationScript, {
        window,
        document,
        navigator: {
            connection: { saveData, effectiveType },
            serviceWorker: serviceWorkerContainer,
        },
        Element: FakeElement,
        jQuery: window.jQuery,
        IntersectionObserver: FakeIntersectionObserver,
        URL,
        setTimeout,
        clearTimeout,
    });

    return {
        window,
        links,
        document,
        get observer() { return visibilityObserver; },
        prefetchMessages,
        workerMessages,
        get activePartition() { return activePartition; },
        get cartRefreshes() { return cartRefreshes; },
        get maxActiveRequests() { return maxActiveRequests; },
    };
}

async function waitFor(predicate, timeoutMs = 2000) {
    const startedAt = Date.now();
    while (!predicate()) {
        if (Date.now() - startedAt > timeoutMs) throw new Error('Timed out waiting for prefetch');
        await new Promise(resolve => setTimeout(resolve, 5));
    }
}

test('user intent can prefetch a product after the automatic eight-link budget is used', async () => {
    const app = bootNavigation();
    app.observer.callback(app.links.map(target => ({ target, isIntersecting: true })));

    await waitFor(() => app.prefetchMessages.length === 8);
    assert.equal(app.prefetchMessages.length, 8);

    app.document.dispatch('pointerover', { target: app.links[8] });
    await waitFor(() => app.prefetchMessages.length === 9);

    assert.equal(new URL(app.prefetchMessages[8].url).pathname, '/product/performance-test-8');
    assert.ok(app.maxActiveRequests <= 2, 'prefetch concurrency stays bounded');
});

test('automatic and intent prefetch are disabled on Save-Data networks', async () => {
    const app = bootNavigation({ saveData: true });
    app.observer.callback(app.links.map(target => ({ target, isIntersecting: true })));
    app.document.dispatch('pointerover', { target: app.links[0] });

    await new Promise(resolve => setTimeout(resolve, 20));
    assert.equal(app.prefetchMessages.length, 0);
});

test('automatic and intent prefetch are disabled on 2G networks', async () => {
    const app = bootNavigation({ effectiveType: '2g' });
    app.observer.callback(app.links.map(target => ({ target, isIntersecting: true })));
    app.document.dispatch('pointerover', { target: app.links[0] });

    await new Promise(resolve => setTimeout(resolve, 20));
    assert.equal(app.prefetchMessages.length, 0);
});

test('checkout, cart, account and payment URLs are never prefetched', async () => {
    const app = bootNavigation();
    ['/shop-cart', '/checkout-details', '/checkout-payment', '/customer/auth/login', '/user-account'].forEach(path => {
        app.document.dispatch('pointerover', { target: new FakeElement(`https://shop.zulors.com${path}`) });
    });

    await new Promise(resolve => setTimeout(resolve, 20));
    assert.equal(app.prefetchMessages.length, 0);
});

test('BFCache restore refreshes the current session partition and nav cart', async () => {
    const app = bootNavigation({ nextPartition: 'b'.repeat(64) });
    app.window.dispatch('pageshow', { persisted: true });

    await waitFor(() => app.activePartition === 'b'.repeat(64));
    assert.ok(app.workerMessages.some(message => message.type === 'CLEAR_PARTITION_CACHE' && message.partition === 'a'.repeat(64)));
    assert.equal(app.cartRefreshes, 1);
});

test('session partition changes in another tab update this page cache key', async () => {
    const app = bootNavigation();
    app.window.dispatch('storage', {
        key: 'zulors-storefront-cache-partition',
        newValue: 'c'.repeat(64),
    });

    assert.equal(app.activePartition, 'c'.repeat(64));
    assert.ok(app.workerMessages.some(message => message.type === 'CLEAR_PARTITION_CACHE' && message.partition === 'a'.repeat(64)));
});

test('navigation remains available when browser storage is blocked', async () => {
    const app = bootNavigation({ storageAvailable: false, nextPartition: 'b'.repeat(64) });
    app.window.dispatch('pageshow', { persisted: true });

    await waitFor(() => app.activePartition === 'b'.repeat(64));
    assert.ok(app.workerMessages.some(message => message.type === 'SET_CACHE_PARTITION' && message.partition === 'b'.repeat(64)));
});

test('clearing a session partition prevents an older in-flight prefetch from being cached', async () => {
    const handlers = new Map();
    const entries = new Map();
    const partition = 'b'.repeat(64);
    let resolveFetch;
    let fetchStarted;
    const fetchStartedPromise = new Promise(resolve => { fetchStarted = resolve; });

    const cache = {
        async keys() {
            return Array.from(entries.keys(), url => new Request(url));
        },
        async match(request) {
            return entries.get(request.url);
        },
        async put(request, response) {
            entries.set(request.url, response);
        },
        async delete(request) {
            return entries.delete(request.url);
        },
    };

    const self = {
        location: { origin: 'https://shop.zulors.com' },
        clients: { async claim() {} },
        skipWaiting: async function () {},
        addEventListener(type, listener) { handlers.set(type, listener); },
    };

    vm.runInNewContext(fs.readFileSync(
        path.join(__dirname, '../../public/zulors-sw.js'),
        'utf8'
    ), {
        self,
        caches: {
            async keys() { return []; },
            async open() { return cache; },
            async delete() { return true; },
        },
        Request,
        Response,
        Headers,
        URL,
        fetch(request) {
            if (request.headers.get('x-zulors-prefetch') === '1') {
                fetchStarted();
                return new Promise(resolve => { resolveFetch = resolve; });
            }
            throw new Error('Unexpected service worker request');
        },
    });

    handlers.get('message')({
        data: { type: 'SET_CACHE_PARTITION', partition },
        source: { id: 'client-a' },
    });

    let prefetchWait;
    handlers.get('message')({
        data: { type: 'PREFETCH_URL', url: 'https://shop.zulors.com/product/stale', partition, id: 1 },
        source: { id: 'client-a', postMessage() {} },
        waitUntil(promise) { prefetchWait = promise; },
    });

    await fetchStartedPromise;

    let clearWait;
    handlers.get('message')({
        data: { type: 'CLEAR_PARTITION_CACHE' },
        source: { id: 'client-a' },
        waitUntil(promise) { clearWait = promise; },
    });

    resolveFetch(new Response('<html>stale</html>', {
        status: 200,
        headers: {
            'Content-Type': 'text/html',
            'X-Zulors-Cacheable': 'session',
            'X-Zulors-Cache-Partition': partition,
        },
    }));

    await Promise.all([prefetchWait, clearWait]);
    assert.equal(entries.size, 0);
});

test('service worker cache policy accepts public storefront pages and rejects private routes', () => {
    const handlers = new Map();
    const sandbox = {
        self: {
            location: { origin: 'https://shop.zulors.com' },
            clients: { async claim() {} },
            skipWaiting: async function () {},
            addEventListener(type, listener) { handlers.set(type, listener); },
        },
        caches: {
            async keys() { return []; },
            async open() { throw new Error('Unexpected cache access'); },
            async delete() { return true; },
        },
        Request,
        Response,
        Headers,
        URL,
        fetch: async function () { throw new Error('Unexpected network access'); },
    };
    vm.runInNewContext(serviceWorkerScript, sandbox);

    ['/','/product/example-item','/category/electronics','/flash-deals/12','/brands']
        .forEach(pathname => assert.equal(sandbox.shouldCacheNavigation(new URL(pathname, 'https://shop.zulors.com')), true));
    ['/shop-cart','/checkout-details','/checkout-payment','/searched-products','/customer/auth/login','/inbox','/user-account','/order-details']
        .forEach(pathname => assert.equal(sandbox.shouldCacheNavigation(new URL(pathname, 'https://shop.zulors.com')), false));

    const partition = 'd'.repeat(64);
    const matchingResponse = new Response('<html>public</html>', {
        status: 200,
        headers: {
            'Content-Type': 'text/html',
            'X-Zulors-Cacheable': 'session',
            'X-Zulors-Cache-Partition': partition,
        },
    });
    assert.equal(sandbox.isCacheableNavigationResponse(matchingResponse, partition), true);
    assert.equal(sandbox.isCacheableNavigationResponse(matchingResponse, 'e'.repeat(64)), false);
    assert.equal(sandbox.isCacheableNavigationResponse(new Response('<html>private</html>', {
        status: 200,
        headers: { 'Content-Type': 'text/html' },
    }), partition), false);
});
