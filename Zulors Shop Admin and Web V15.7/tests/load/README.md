# Storefront staging load check

This read-only k6 scenario is for an isolated staging deployment. It runs 100 virtual users for two minutes across the homepage, one category, one search URL, and one product page. It fails when HTTP failures reach 1%, p95 server wait exceeds 1 second, or fewer than 99% of the HTML checks pass.

Use real public paths that exist in staging. For example, `STAGING_SEARCH_PATH` can be `/products?name=performance-check`; category and product paths must use real staging slugs. Do not use cart, account, order, checkout, or payment routes.

```sh
STAGING_CONFIRMATION=I_CONFIRMED_STAGING \
STAGING_BASE_URL=https://staging.example.test \
STAGING_HOME_PATH=/ \
STAGING_CATEGORY_PATH=/category/example-category \
STAGING_SEARCH_PATH='/products?name=performance-check' \
STAGING_PRODUCT_PATH=/product/example-product \
k6 run tests/load/storefront-readonly.js
```

The script refuses the known production domain and server IP. It is intentionally not wired to production CI. Run the browser journey checks separately against staging with Playwright; never send this load to `shop.zulors.com`.
