<?php

namespace Tests\Feature;

use Illuminate\Support\Facades\Route;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     *
     * @return void
     */
    public function test_homepage_route_is_registered(): void
    {
        $this->assertNotNull(Route::getRoutes()->getByName('home'));
    }
}
