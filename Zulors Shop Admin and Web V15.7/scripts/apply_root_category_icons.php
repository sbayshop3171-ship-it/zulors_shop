<?php

declare(strict_types=1);

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
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

function fetchRemoteSvg(string $url): string
{
    if (function_exists('curl_init')) {
        $handle = curl_init($url);
        curl_setopt_array($handle, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_CONNECTTIMEOUT => 20,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_USERAGENT => 'ZulorsCategoryIconBot/1.0',
        ]);

        $body = curl_exec($handle);
        $statusCode = (int)curl_getinfo($handle, CURLINFO_HTTP_CODE);
        $error = curl_error($handle);
        curl_close($handle);

        if ($body !== false && $statusCode >= 200 && $statusCode < 300) {
            return $body;
        }

        throw new RuntimeException("Unable to fetch {$url}. HTTP {$statusCode}. {$error}");
    }

    $context = stream_context_create([
        'http' => [
            'method' => 'GET',
            'header' => "User-Agent: ZulorsCategoryIconBot/1.0\r\n",
            'timeout' => 30,
        ],
    ]);

    $body = @file_get_contents($url, false, $context);

    if ($body === false) {
        throw new RuntimeException("Unable to fetch {$url}.");
    }

    return $body;
}

function extractInnerSvg(string $svg): string
{
    if (!preg_match('/<svg[^>]*>(.*)<\/svg>/is', $svg, $matches)) {
        throw new RuntimeException('Invalid SVG payload received.');
    }

    return trim($matches[1]);
}

function buildCategoryBadgeSvg(string $iconMarkup, string $iconTitle, string $backgroundColor, string $strokeColor): string
{
    $safeTitle = htmlspecialchars($iconTitle, ENT_QUOTES, 'UTF-8');

    return <<<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 96 96" fill="none" role="img" aria-label="{$safeTitle}">
  <title>{$safeTitle}</title>
  <circle cx="48" cy="48" r="40" fill="{$backgroundColor}"/>
  <g transform="translate(24 24) scale(2)" stroke="{$strokeColor}" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" fill="none">
    {$iconMarkup}
  </g>
</svg>
SVG;
}

function backupCurrentRootCategoryIcons(): string
{
    $backupDir = storage_path('app/backups/category-icons');
    ensureDirectory($backupDir);

    $backupPath = $backupDir . '/root-category-icons-' . now()->format('Ymd_His') . '.json';
    $payload = DB::table('categories')
        ->where('position', 0)
        ->orderBy('priority')
        ->orderBy('id')
        ->get(['id', 'name', 'icon', 'icon_storage_type', 'updated_at'])
        ->map(static fn($row) => (array)$row)
        ->all();

    file_put_contents(
        $backupPath,
        json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
    );

    return $backupPath;
}

$rootCategoryIconMap = [
    'Electronics & Gadgets' => 'smartphone',
    'Home & Kitchen Appliances' => 'cooking-pot',
    "Men's Fashion" => 'shirt',
    "Women's Fashion" => 'handbag',
    'Kids & Baby Fashion' => 'baby',
    'Beauty & Personal Care' => 'sparkles',
    'Health & Wellness' => 'heart-pulse',
    'Groceries & Daily Essentials' => 'shopping-basket',
    'Home Decor & Furniture' => 'sofa',
    'Sports & Outdoors' => 'dumbbell',
    'Books & Literature' => 'book-open',
    'Stationery & Office Supplies' => 'notebook-pen',
    'Toys, Games & Hobbies' => 'puzzle',
    'Baby Care & Essentials' => 'milk',
    'Automotive & Motorbikes' => 'car-front',
    'Jewelry & Luxury Goods' => 'gem',
    'Bags & Luggage' => 'briefcase',
    'Musical Instruments' => 'guitar',
    'Digital Products & Software' => 'monitor-smartphone',
    'Pet Supplies' => 'paw-print',
    'Industrial & B2B Supplies' => 'factory',
    'Garden & Outdoor Living' => 'trees',
    'Arts, Crafts & Sewing' => 'palette',
    'Food & Beverages (Gourmet)' => 'croissant',
    'Security & Surveillance' => 'cctv',
    'Office Furniture & Setup' => 'briefcase-business',
    'Travel & Outdoor Accessories' => 'luggage',
    'Party & Event Supplies' => 'party-popper',
    'Cleaning & Household Supplies' => 'spray-can',
    'Religious & Spiritual Items' => 'book-heart',
    'Renewable Energy & Solar' => 'solar-panel',
    'Electrical Tools & Wiring' => 'plug',
    'Plumbing & Bathroom Fittings' => 'bath',
    'Construction Materials' => 'hammer',
    'Commercial Kitchen Equipment' => 'utensils-crossed',
    'Scientific & Lab Equipment' => 'microscope',
    'Heavy Machinery & Equipment' => 'forklift',
    'Gaming Equipment & Accessories' => 'gamepad-2',
    'Smart Home & Automation' => 'house-wifi',
    'Print & Publishing Supplies' => 'printer',
    'Optometry & Eye Care' => 'eye',
    'Orthopedic & Rehabilitative Care' => 'accessibility',
    'Vintage & Antiques' => 'scroll',
    'Firearms & Tactical Gear (Regulated)' => 'shield',
    'Marine & Boating' => 'sailboat',
    'Commercial Signage & Displays' => 'presentation',
    'Vending & Self-Service' => 'ticket',
    'Livestock & Farming Supplies' => 'tractor',
    'Rental & Event Logistics' => 'tent',
    'Funeral & Memorial Supplies' => 'flower-2',
];

$palette = [
    ['#E8F0FE', '#1D4ED8'],
    ['#FFF7ED', '#EA580C'],
    ['#ECFDF5', '#059669'],
    ['#F5F3FF', '#7C3AED'],
    ['#FEF3C7', '#D97706'],
    ['#FCE7F3', '#DB2777'],
    ['#E0F2FE', '#0284C7'],
    ['#F3E8FF', '#9333EA'],
    ['#DCFCE7', '#16A34A'],
    ['#FEE2E2', '#DC2626'],
];

$backupPath = backupCurrentRootCategoryIcons();
$storageDirectory = storage_path('app/public/category');
ensureDirectory($storageDirectory);

$generatedFiles = [];
$missingCategories = [];
$now = now();

foreach (array_values($rootCategoryIconMap) as $index => $iconName) {
    $categoryName = array_keys($rootCategoryIconMap)[$index];
    $categorySlug = Str::slug($categoryName);
    $filename = 'zulors-root-category-' . $categorySlug . '.svg';
    $svgUrl = 'https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/' . $iconName . '.svg';
    $svgMarkup = fetchRemoteSvg($svgUrl);
    $innerMarkup = extractInnerSvg($svgMarkup);
    [$backgroundColor, $strokeColor] = $palette[$index % count($palette)];
    $badgeSvg = buildCategoryBadgeSvg(
        iconMarkup: $innerMarkup,
        iconTitle: $categoryName . ' category icon',
        backgroundColor: $backgroundColor,
        strokeColor: $strokeColor,
    );

    file_put_contents($storageDirectory . '/' . $filename, $badgeSvg);
    $generatedFiles[$categoryName] = $filename;
}

DB::beginTransaction();

try {
    foreach ($rootCategoryIconMap as $categoryName => $iconName) {
        $filename = $generatedFiles[$categoryName];
        $updated = DB::table('categories')
            ->where('position', 0)
            ->where('name', $categoryName)
            ->update([
                'icon' => $filename,
                'icon_storage_type' => 'public',
                'updated_at' => $now,
            ]);

        if ($updated === 0) {
            $missingCategories[] = $categoryName;
        }
    }

    DB::commit();
} catch (Throwable $throwable) {
    DB::rollBack();
    fwrite(STDERR, $throwable->getMessage() . PHP_EOL);
    exit(1);
}

if (function_exists('cacheRemoveByType')) {
    cacheRemoveByType(type: 'categories');
}

fwrite(STDOUT, json_encode([
    'backup_path' => $backupPath,
    'source' => [
        'provider' => 'Lucide',
        'repository' => 'https://github.com/lucide-icons/lucide',
        'license' => 'ISC',
    ],
    'generated_icons' => count($generatedFiles),
    'updated_root_categories' => count($generatedFiles) - count($missingCategories),
    'missing_categories' => $missingCategories,
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
