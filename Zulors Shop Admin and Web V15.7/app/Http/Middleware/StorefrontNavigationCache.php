<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class StorefrontNavigationCache
{
    private const CACHEABLE_ROUTE_NAMES = [
        'home',
        'product',
        'products',
        'brand-products',
        'category-products',
        'featured-products',
        'featured-deal-products',
        'latest-products',
        'best-selling-products',
        'top-rated-products',
        'discounted-products',
        'clearance-sale-products',
        'flash-deals',
        'brands',
        'categories',
        'vendors',
    ];

    public function handle(Request $request, Closure $next)
    {
        $session = $request->hasSession() ? $request->session() : null;
        $hadTransientPageState = $session && (
            $session->has('order_success_ids')
            || $session->has('isNewCustomerInSession')
            || !empty($session->get('_flash.new', []))
            || !empty($session->get('_flash.old', []))
        );
        $response = $next($request);
        $routeName = $request->route()?->getName();
        $contentType = (string) $response->headers->get('Content-Type', '');

        if (
            $request->isMethod('GET')
            && in_array($routeName, self::CACHEABLE_ROUTE_NAMES, true)
            && $response->getStatusCode() === 200
            && str_contains(strtolower($contentType), 'text/html')
        ) {
            $hasTransientPageState = $hadTransientPageState || $session->has('order_success_ids')
                || $session->has('isNewCustomerInSession')
                || !empty($session->get('_flash.new', []))
                || !empty($session->get('_flash.old', []));
            $homepagePopupHasNotBeenConsumed = $routeName === 'home'
                && $request->cookie('popup_banner') === null;

            // The service worker uses this opaque, per-session key. The HTML
            // remains non-cacheable to shared proxies and the browser HTTP cache.
            $response->headers->set('Cache-Control', 'private, no-store, max-age=0');

            if (!$hasTransientPageState && !$homepagePopupHasNotBeenConsumed) {
                $partition = hash_hmac(
                    'sha256',
                    $session->getId() . '|' . serialize($session->all()) . '|'
                        . (string) $request->user('customer')?->getAuthIdentifier() . '|'
                        . (string) getDefaultLanguage(),
                    (string) config('app.key')
                );

                $response->headers->set('X-Zulors-Cacheable', 'session');
                $response->headers->set('X-Zulors-Cache-Partition', $partition);
            } else {
                $response->headers->remove('X-Zulors-Cacheable');
                $response->headers->remove('X-Zulors-Cache-Partition');
            }
        }

        return $response;
    }
}
