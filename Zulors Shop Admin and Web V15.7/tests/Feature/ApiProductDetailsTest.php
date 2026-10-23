<?php

namespace Tests\Feature;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class ApiProductDetailsTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        Schema::create('products', function (Blueprint $table): void {
            $table->id();
            $table->string('slug')->index();
            $table->unsignedBigInteger('brand_id')->nullable();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('added_by')->nullable();
            $table->string('product_type')->default('physical');
            $table->unsignedTinyInteger('status')->default(1);
            $table->unsignedTinyInteger('request_status')->default(1);
        });

        Schema::create('sellers', function (Blueprint $table): void {
            $table->id();
            $table->string('status')->nullable();
        });

        Schema::create('wishlists', function (Blueprint $table): void {
            $table->id();
            $table->unsignedBigInteger('product_id');
            $table->unsignedBigInteger('customer_id')->nullable();
        });

        Cache::put('product_brand', false);
        Cache::put('digital_product', false);
        Cache::put('business_mode', 'multi');
    }

    public function test_unknown_product_slug_returns_a_json_404(): void
    {
        $response = $this->getJson(
            '/api/v1/products/details/zulors-test-product-that-does-not-exist?guest_id=1'
        );

        $response
            ->assertNotFound()
            ->assertJsonPath('errors.code', 'product-001')
            ->assertHeader('X-Request-Id');
    }
}
