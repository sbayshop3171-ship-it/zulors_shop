<?php

namespace Tests\Feature;

use App\Http\Middleware\GuestMiddleware;
use App\Http\Middleware\MaintenanceModeMiddleware;
use Tests\TestCase;

class StorefrontNavigationContextTest extends TestCase
{
    public function test_navigation_context_is_private_and_returns_an_opaque_session_partition(): void
    {
        $response = $this->withoutMiddleware([
            GuestMiddleware::class,
            MaintenanceModeMiddleware::class,
        ])->withSession(['local' => 'en'])->getJson(route('storefront.navigation-context'));

        $response->assertOk()
            ->assertHeaderMissing('X-Zulors-Cacheable')
            ->assertJsonStructure(['partition']);

        $cacheDirectives = array_map('trim', explode(',', $response->headers->get('Cache-Control')));
        sort($cacheDirectives);
        $this->assertSame(['max-age=0', 'no-store', 'private'], $cacheDirectives);

        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $response->json('partition'));
    }
}
