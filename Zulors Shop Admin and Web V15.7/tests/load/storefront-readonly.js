import http from 'k6/http';
import { check, sleep } from 'k6';

const productionHosts = new Set([
    'shop.zulors.com',
    'zulors.com',
    'www.zulors.com',
    '5.189.168.13',
]);

const baseUrl = __ENV.STAGING_BASE_URL || '';
if (__ENV.STAGING_CONFIRMATION !== 'I_CONFIRMED_STAGING') {
    throw new Error('Set STAGING_CONFIRMATION=I_CONFIRMED_STAGING after verifying this is an isolated staging site.');
}
if (!baseUrl) throw new Error('Set STAGING_BASE_URL to the isolated staging site.');

let parsedBaseUrl;
try {
    parsedBaseUrl = new URL(baseUrl);
} catch (error) {
    throw new Error('STAGING_BASE_URL must be an absolute URL.');
}
if (parsedBaseUrl.protocol !== 'https:' || parsedBaseUrl.username || parsedBaseUrl.password) {
    throw new Error('STAGING_BASE_URL must use HTTPS and must not contain credentials.');
}
if (productionHosts.has(parsedBaseUrl.hostname.toLowerCase())) {
    throw new Error('Production hosts are blocked; this read-only load test must only run on staging.');
}

const pagePaths = {
    home: __ENV.STAGING_HOME_PATH || '/',
    category: __ENV.STAGING_CATEGORY_PATH || '',
    search: __ENV.STAGING_SEARCH_PATH || '',
    product: __ENV.STAGING_PRODUCT_PATH || '',
};
for (const [name, path] of Object.entries(pagePaths)) {
    if (!path.startsWith('/') || path.startsWith('//')) {
        throw new Error(`Set STAGING_${name.toUpperCase()}_PATH to a same-origin, read-only path beginning with /.`);
    }
    const target = new URL(path, parsedBaseUrl);
    if (target.origin !== parsedBaseUrl.origin || /\/(?:cart|checkout|payment|order|inbox|login|register)(?:\/|$)/i.test(target.pathname)) {
        throw new Error(`STAGING_${name.toUpperCase()}_PATH must be a same-origin public GET page.`);
    }
}

export const options = {
    scenarios: {
        staging_baseline: {
            executor: 'constant-vus',
            vus: 100,
            duration: '2m',
        },
    },
    thresholds: {
        http_req_failed: ['rate<0.01'],
        http_req_waiting: ['p(95)<1000'],
        checks: ['rate>0.99'],
    },
};

export default function () {
    for (const [page, path] of Object.entries(pagePaths)) {
        const response = http.get(new URL(path, parsedBaseUrl).toString(), {
            redirects: 5,
            timeout: '20s',
            tags: { page },
        });
        check(response, {
            [`${page} returns an HTML success response`]: result => result.status >= 200
                && result.status < 400
                && (result.headers['Content-Type'] || '').toLowerCase().includes('text/html'),
        });
        sleep(1);
    }
}

// Run only against isolated staging with valid public route paths:
// k6 run tests/load/storefront-readonly.js
