const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const navigationScript = fs.readFileSync(
    path.join(__dirname, '../../public/assets/front-end/js/instant-navigation.js'),
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

function bootNavigation({ saveData = false, effectiveType = '4g' } = {}) {
    const links = Array.from({ length: 10 }, (_, index) => new FakeElement(
        `https://shop.zulors.com/product/performance-test-${index}`
    ));
    const documentListeners = new Map();
    const serviceWorkerListeners = new Map();
    let visibilityObserver;
    let activeRequests = 0;
    let maxActiveRequests = 0;
    const prefetchMessages = [];

    const serviceWorker = {
        postMessage(message) {
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
        getElementById() { return null; },
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
            serviceWorkerUrl: '/zulors-sw.js',
        },
        location: { origin: 'https://shop.zulors.com', pathname: '/', search: '' },
        requestAnimationFrame(callback) { callback(); },
        IntersectionObserver: FakeIntersectionObserver,
        setTimeout,
        clearTimeout,
        addEventListener() {},
    };

    vm.runInNewContext(navigationScript, {
        window,
        document,
        navigator: {
            connection: { saveData, effectiveType },
            serviceWorker: serviceWorkerContainer,
        },
        Element: FakeElement,
        IntersectionObserver: FakeIntersectionObserver,
        URL,
        setTimeout,
        clearTimeout,
    });

    return {
        links,
        document,
        get observer() { return visibilityObserver; },
        prefetchMessages,
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
