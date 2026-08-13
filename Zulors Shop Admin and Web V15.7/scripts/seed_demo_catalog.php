<?php

declare(strict_types=1);

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

require __DIR__ . '/../vendor/autoload.php';

$app = require __DIR__ . '/../bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

function ensureDirectory(string $path): void
{
    if (!is_dir($path) && !mkdir($path, 0755, true) && !is_dir($path)) {
        throw new RuntimeException("Unable to create directory: {$path}");
    }
}

function buildCategoryTrail(array $categoriesById, int $categoryId): array
{
    $trail = [];
    $cursor = $categoriesById[$categoryId] ?? null;

    while ($cursor) {
        array_unshift($trail, $cursor);

        if ((int)$cursor->parent_id === 0) {
            break;
        }

        $cursor = $categoriesById[(int)$cursor->parent_id] ?? null;
    }

    return $trail;
}

function resolveImageSource(array $trail, string $storageBase, array $fallbackImages): ?string
{
    foreach (array_reverse($trail) as $node) {
        if (!empty($node->icon)) {
            $candidate = $storageBase . '/category/' . $node->icon;
            if (is_file($candidate)) {
                return $candidate;
            }
        }
    }

    foreach ($fallbackImages as $candidate) {
        if (is_file($candidate)) {
            return $candidate;
        }
    }

    return null;
}

function buildProductName(array $trail): string
{
    $root = $trail[0]->name ?? 'Category';
    $leaf = $trail[count($trail) - 1]->name ?? 'Product';

    if (count($trail) === 1) {
        return $root . ' Collection';
    }

    return $root . ' - ' . $leaf;
}

$appendMode = in_array('--append', $argv, true);
$existingProductCount = DB::table('products')->count();

if ($existingProductCount > 0 && !$appendMode) {
    fwrite(STDOUT, "Skipped: products table already contains {$existingProductCount} rows. Re-run with --append if needed.\n");
    exit(0);
}

$storageBase = storage_path('app/public');
$productDir = $storageBase . '/product';
$thumbnailDir = $productDir . '/thumbnail';

ensureDirectory($productDir);
ensureDirectory($thumbnailDir);

$categoriesById = DB::table('categories')
    ->select('id', 'parent_id', 'position', 'name', 'slug', 'icon')
    ->get()
    ->keyBy('id')
    ->all();

$leafCategoryIds = DB::table('categories as c')
    ->leftJoin('categories as ch', 'ch.parent_id', '=', 'c.id')
    ->whereNull('ch.id')
    ->orderBy('c.priority')
    ->orderBy('c.id')
    ->pluck('c.id')
    ->all();

$brandIds = DB::table('brands')->orderBy('id')->pluck('id')->all();
$shopId = (int)(DB::table('shops')->where('seller_id', 0)->value('id') ?? 1);
$adminId = (int)(DB::table('admins')->min('id') ?? 1);
$now = now();

$fallbackImages = [
    $storageBase . '/banner/zulors-main-banner-01.webp',
    $storageBase . '/banner/zulors-main-banner-02.webp',
    $storageBase . '/banner/zulors-main-banner-03.webp',
];

$existingSeedCodes = array_flip(
    DB::table('products')
        ->where('code', 'like', 'ZULCAT-%')
        ->pluck('code')
        ->all()
);

$created = 0;
$skipped = 0;
$missingImages = 0;

DB::beginTransaction();

try {
    foreach ($leafCategoryIds as $index => $categoryId) {
        $categoryId = (int)$categoryId;
        $seedCode = 'ZULCAT-' . $categoryId;

        if (isset($existingSeedCodes[$seedCode])) {
            $skipped++;
            continue;
        }

        $trail = buildCategoryTrail($categoriesById, $categoryId);

        if (count($trail) === 0) {
            $skipped++;
            continue;
        }

        $root = $trail[0];
        $subCategory = $trail[1] ?? null;
        $subSubCategory = $trail[2] ?? null;

        $sourceImage = resolveImageSource($trail, $storageBase, $fallbackImages);
        $imageExtension = $sourceImage ? strtolower(pathinfo($sourceImage, PATHINFO_EXTENSION) ?: 'webp') : 'webp';
        $imageFilename = 'zulors-demo-product-' . $categoryId . '.' . $imageExtension;

        if ($sourceImage) {
            $targetProductImage = $productDir . '/' . $imageFilename;
            $targetThumbnailImage = $thumbnailDir . '/' . $imageFilename;

            if (!is_file($targetProductImage)) {
                copy($sourceImage, $targetProductImage);
            }

            if (!is_file($targetThumbnailImage)) {
                copy($sourceImage, $targetThumbnailImage);
            }
        } else {
            $missingImages++;
        }

        $productName = buildProductName($trail);
        $productCode = $seedCode;
        $unitPrice = 250 + (($categoryId * 37) % 5000);
        $stockQty = 8 + ($categoryId % 25);
        $discount = $categoryId % 3 === 0 ? 25 : 0;
        $brandId = count($brandIds) > 0 ? $brandIds[$index % count($brandIds)] : null;

        $categoryIds = [];
        foreach ($trail as $position => $node) {
            $categoryIds[] = [
                'id' => (string)$node->id,
                'position' => $position + 1,
            ];
        }

        $productId = DB::table('products')->insertGetId([
            'added_by' => 'admin',
            'user_id' => $adminId,
            'shop_id' => $shopId,
            'name' => $productName,
            'code' => $productCode,
            'slug' => Str::slug($productName) . '-' . strtolower(Str::random(6)),
            'product_type' => 'physical',
            'category_ids' => json_encode($categoryIds, JSON_UNESCAPED_UNICODE),
            'category_id' => (string)$root->id,
            'sub_category_id' => $subCategory ? (string)$subCategory->id : null,
            'sub_sub_category_id' => $subSubCategory ? (string)$subSubCategory->id : null,
            'brand_id' => $brandId,
            'unit' => 'pc',
            'min_qty' => 1,
            'refundable' => 1,
            'images' => json_encode([['image_name' => $imageFilename, 'storage' => 'public']]),
            'color_image' => json_encode([]),
            'thumbnail' => $imageFilename,
            'thumbnail_storage_type' => 'public',
            'featured' => 1,
            'flash_deal' => 0,
            'video_provider' => 'youtube',
            'video_url' => null,
            'colors' => json_encode([]),
            'variant_product' => 0,
            'attributes' => json_encode([]),
            'choice_options' => json_encode([]),
            'variation' => json_encode([]),
            'published' => 1,
            'unit_price' => $unitPrice,
            'purchase_price' => 0,
            'tax' => '0.00',
            'tax_type' => 'flat',
            'tax_model' => 'exclude',
            'discount' => (string)$discount,
            'discount_type' => 'flat',
            'current_stock' => $stockQty,
            'minimum_order_qty' => 1,
            'details' => '<p>Demo catalog item for ' . e($productName) . ' on Zulors Shop.</p>',
            'free_shipping' => 0,
            'created_at' => $now,
            'updated_at' => $now,
            'status' => 1,
            'featured_status' => 1,
            'request_status' => 1,
            'shipping_cost' => 0,
            'multiply_qty' => 0,
        ]);

        DB::table('product_stocks')->insert([
            'product_id' => $productId,
            'variant' => '',
            'sku' => $productCode,
            'price' => $unitPrice,
            'qty' => $stockQty,
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        $created++;
    }

    DB::commit();
} catch (Throwable $throwable) {
    DB::rollBack();
    fwrite(STDERR, $throwable->getMessage() . PHP_EOL);
    exit(1);
}

fwrite(STDOUT, json_encode([
    'created' => $created,
    'skipped' => $skipped,
    'missing_images' => $missingImages,
    'leaf_categories' => count($leafCategoryIds),
    'product_total' => DB::table('products')->count(),
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
