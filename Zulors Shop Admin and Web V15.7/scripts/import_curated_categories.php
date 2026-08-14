<?php

declare(strict_types=1);

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
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

function normalizeLabel(string $value): string
{
    return preg_replace('/\s+/u', ' ', trim($value)) ?? trim($value);
}

function summarizeTree(array $tree): array
{
    $rootCount = count($tree);
    $subCategoryCount = 0;
    $subSubCategoryCount = 0;

    foreach ($tree as $root) {
        $subCategoryCount += count($root['children']);

        foreach ($root['children'] as $subCategory) {
            $subSubCategoryCount += count($subCategory['children']);
        }
    }

    return [
        'roots' => $rootCount,
        'sub_categories' => $subCategoryCount,
        'sub_sub_categories' => $subSubCategoryCount,
        'total_categories' => $rootCount + $subCategoryCount + $subSubCategoryCount,
    ];
}

function parseCatalog(string $catalogText): array
{
    $roots = [];
    $currentRoot = null;
    $rawRootCount = 0;
    $rawSubCategoryCount = 0;
    $rawSubSubCategoryCount = 0;

    $lines = preg_split('/\R/u', trim($catalogText)) ?: [];

    foreach ($lines as $lineNumber => $line) {
        $line = rtrim($line);

        if ($line === '') {
            continue;
        }

        if (!str_starts_with($line, '  ')) {
            $currentRoot = normalizeLabel($line);
            $rawRootCount++;

            if (!isset($roots[$currentRoot])) {
                $roots[$currentRoot] = [];
            }

            continue;
        }

        if ($currentRoot === null) {
            throw new RuntimeException('Subcategory found before any root category on line ' . ($lineNumber + 1) . '.');
        }

        $parts = explode(':', trim($line), 2);

        if (count($parts) !== 2) {
            throw new RuntimeException('Invalid subcategory line on line ' . ($lineNumber + 1) . ': ' . $line);
        }

        $subCategoryName = normalizeLabel($parts[0]);
        $subSubCategoryNames = array_values(array_filter(array_map(
            static fn(string $item): string => normalizeLabel($item),
            explode('|', $parts[1])
        )));

        $rawSubCategoryCount++;
        $rawSubSubCategoryCount += count($subSubCategoryNames);

        if (!isset($roots[$currentRoot][$subCategoryName])) {
            $roots[$currentRoot][$subCategoryName] = [];
        }

        $existingLeafNames = [];
        foreach ($roots[$currentRoot][$subCategoryName] as $existingName) {
            $existingLeafNames[Str::lower($existingName)] = true;
        }

        foreach ($subSubCategoryNames as $subSubCategoryName) {
            $dedupeKey = Str::lower($subSubCategoryName);

            if (!isset($existingLeafNames[$dedupeKey])) {
                $roots[$currentRoot][$subCategoryName][] = $subSubCategoryName;
                $existingLeafNames[$dedupeKey] = true;
            }
        }
    }

    $tree = [];

    foreach ($roots as $rootName => $subCategories) {
        $children = [];

        foreach ($subCategories as $subCategoryName => $subSubCategoryNames) {
            $children[] = [
                'name' => $subCategoryName,
                'children' => $subSubCategoryNames,
            ];
        }

        $tree[] = [
            'name' => $rootName,
            'children' => $children,
        ];
    }

    return [
        'tree' => $tree,
        'stats' => array_merge([
            'raw_roots' => $rawRootCount,
            'raw_sub_categories' => $rawSubCategoryCount,
            'raw_sub_sub_categories' => $rawSubSubCategoryCount,
        ], summarizeTree($tree)),
    ];
}

function makeUniqueSlug(array &$usedSlugs, array $parts): string
{
    $base = Str::slug(implode(' ', array_filter($parts, static fn(?string $part): bool => !empty($part))));
    $base = $base !== '' ? $base : 'category';
    $slug = $base;
    $suffix = 2;

    while (isset($usedSlugs[$slug])) {
        $slug = $base . '-' . $suffix;
        $suffix++;
    }

    $usedSlugs[$slug] = true;

    return $slug;
}

function tableSnapshot(string $tableName, ?callable $queryCallback = null): array
{
    if (!Schema::hasTable($tableName)) {
        return [];
    }

    $query = DB::table($tableName);

    if ($queryCallback !== null) {
        $queryCallback($query);
    }

    return $query->orderBy('id')->get()->map(static fn($row) => (array)$row)->all();
}

function backupExistingCategoryState(array $catalogStats): string
{
    $backupDir = storage_path('app/backups/category-imports');
    ensureDirectory($backupDir);

    $timestamp = now()->format('Ymd_His');
    $backupFile = $backupDir . '/category-import-backup-' . $timestamp . '.json';

    $payload = [
        'created_at' => now()->toDateTimeString(),
        'catalog_stats' => $catalogStats,
        'database_counts' => [
            'categories' => Schema::hasTable('categories') ? DB::table('categories')->count() : 0,
            'products' => Schema::hasTable('products') ? DB::table('products')->count() : 0,
            'category_translations' => Schema::hasTable('translations')
                ? DB::table('translations')->where('translationable_type', 'App\Models\Category')->count()
                : 0,
            'category_seo' => Schema::hasTable('seo_meta_info')
                ? DB::table('seo_meta_info')->where('seoable_type', 'App\Models\Category')->count()
                : 0,
            'category_taxables' => Schema::hasTable('taxables')
                ? DB::table('taxables')->where('taxable_type', 'App\Models\Category')->count()
                : 0,
            'category_shipping_costs' => Schema::hasTable('category_shipping_costs')
                ? DB::table('category_shipping_costs')->count()
                : 0,
        ],
        'categories' => tableSnapshot('categories'),
        'translations' => tableSnapshot('translations', static function ($query): void {
            $query->where('translationable_type', 'App\Models\Category');
        }),
        'seo_meta_info' => tableSnapshot('seo_meta_info', static function ($query): void {
            $query->where('seoable_type', 'App\Models\Category');
        }),
        'taxables' => tableSnapshot('taxables', static function ($query): void {
            $query->where('taxable_type', 'App\Models\Category');
        }),
        'category_shipping_costs' => tableSnapshot('category_shipping_costs'),
    ];

    file_put_contents(
        $backupFile,
        json_encode($payload, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
    );

    return $backupFile;
}

$catalogText = <<<'CATALOG'
Electronics & Gadgets
  Mobile Phones & Accessories: Smartphones | Feature Phones | Mobile Cases | Power Banks
  Laptops & Computers: Laptops | Desktops | PC Components | Monitors
  Audio & Headphones: Wireless Earbuds | Headphones | Bluetooth Speakers | Soundbars
  Cameras & Photography: DSLR Cameras | Action Cameras | Drones | Camera Lenses
  Wearable Technology: Smartwatches | Fitness Trackers | VR Headsets | Smart Glasses
Home & Kitchen Appliances
  Large Appliances: Refrigerators | Washing Machines | Air Conditioners | Dishwashers
  Small Kitchen Appliances: Air Fryers | Microwaves | Blenders & Mixers | Electric Kettles
  Home Comfort & Cleaning: Vacuum Cleaners | Water Purifiers | Air Purifiers | Electric Fans
  Cooking Utensils: Cookware Sets | Frying Pans | Pressure Cookers | Baking Trays
  Dining & Tableware: Dinnerware Sets | Glassware | Cutlery | Water Bottles
Men's Fashion
  Top Wear: T-Shirts | Casual Shirts | Formal Shirts | Polo Shirts
  Bottom Wear: Jeans | Chinos | Trousers | Shorts
  Outerwear & Winter Wear: Jackets | Hoodies | Blazers | Coats
  Innerwear & Sleepwear: Boxers | Briefs | Vests | Pajamas
  Men's Footwear: Sneakers | Formal Shoes | Sandals | Boots
Women's Fashion
  Ethnic & Traditional: Sarees | Salwar Kameez | Lehengas | Kurtis
  Western Wear: Dresses | Tops & Blouses | Skirts | Jeans
  Lingerie & Sleepwear: Bras | Panties | Nightwear | Shapewear
  Outerwear & Cardigans: Jackets | Shrugs | Sweaters | Coats
  Women's Footwear: Heels | Flats | Sandals | Sports Shoes
Kids & Baby Fashion
  Boys' Clothing: T-shirts | Shirts | Pants | Shorts
  Girls' Clothing: Frocks | Party Dresses | Tops | Leggings
  Baby Clothing (0-2 Yrs): Rompers | Onesies | Baby Sleepsuits | Bibs
  Kids' Footwear: School Shoes | Sandals | Light-up Shoes | Booties
  Baby Care Accessories: Baby Caps | Mittens | Socks | Hairbands
Beauty & Personal Care
  Skincare: Face Wash | Moisturizers | Serums | Sunscreens
  Hair Care: Shampoos | Conditioners | Hair Oils | Hair Masks
  Makeup: Lipsticks | Foundations | Mascaras | Eyeliners
  Fragrances: Perfumes | Body Sprays | Deodorants | Attar
  Personal Grooming: Trimmers | Hair Dryers | Straighteners | Shavers
Health & Wellness
  Medical Equipment: BP Monitors | Thermometers | Oximeters | Nebulizers
  Supplements & Vitamins: Protein Powders | Multivitamins | Fish Oil | Immunity Boosters
  Sexual Wellness: Condoms | Lubricants | Sexual Health Supplements
  First Aid & Care: Bandages | Antiseptics | Pain Relief Sprays | Hot Water Bags
  Mobility Aids: Wheelchairs | Walking Sticks | Knee Supports | Braces
Groceries & Daily Essentials
  Fresh Produce: Fresh Vegetables | Fruits | Herbs | Organic Produce
  Dairy & Bakery: Milk | Butter | Cheese | Bread | Eggs
  Staples & Grains: Rice | Flour (Atta) | Pulses (Dal) | Cooking Oils
  Beverages: Tea | Coffee | Juices | Energy Drinks
  Snacks & Branded Foods: Biscuits | Chocolates | Chips | Noodles
Home Decor & Furniture
  Living Room Furniture: Sofas | Coffee Tables | TV Cabinets | Recliners
  Bedroom Furniture: Beds | Wardrobes | Mattresses | Dressing Tables
  Home Lighting: Wall Lamps | Ceiling Lights | LED Strips | Table Lamps
  Wall & Floor Decor: Wall Art | Mirrors | Rugs & Carpets | Wallpapers
  Home Furnishings: Curtains | Bed Sheets | Cushion Covers | Blankets
Sports & Outdoors
  Fitness Equipment: Dumbbells | Treadmills | Exercise Bikes | Yoga Mats
  Team Sports: Footballs | Cricket Bats & Balls | Basketballs | Volleyballs
  Racket Sports: Badminton Rackets | Tennis Rackets | Shuttlecocks | Table Tennis
  Outdoor & Camping: Tents | Sleeping Bags | Camping Lights | Trekking Bags
  Water Sports: Swimming Goggles | Life Jackets | Swimsuits | Diving Gear
Books & Literature
  Academic & Textbooks: School Textbooks | College Books | Engineering | Medical
  Exam Preparation: BCS Prep | Bank Exam Books | IELTS Prep | Admission Test Books
  Fiction & Novels: Sci-Fi | Mystery | Romance | Thriller
  Non-Fiction: Self-Help | Biographies | Business Books | History
  Islamic & Religious: Quran | Hadith Books | Islamic History | Spiritual Guides
Stationery & Office Supplies
  Writing Instruments: Gel Pens | Ballpoint Pens | Fountain Pens | Markers
  Paper Products: Notebooks | Diaries | A4 Papers | Sticky Notes
  Desk Accessories: Organizers | Pen Stands | Calculators | Staplers
  Filing & Storage: Files | Folders | Document Bags | Clipboards
  School Supplies: School Bags | Geometry Boxes | Water Bottles | Tiffin Boxes
Toys, Games & Hobbies
  Educational Toys: Puzzles | Building Blocks | STEM Kits | Science Toys
  Action & Pretend Play: Action Figures | Dollhouses | Toy Cars | Superhero Toys
  Board Games & Cards: Chess | Ludo | Monopoly | Playing Cards
  Remote Control Toys: RC Cars | Drones | RC Helicopters | Boats
  Soft Toys: Teddy Bears | Plush Animals | Cartoon Cushions
Baby Care & Essentials
  Diapering & Wipes: Baby Diapers | Wet Wipes | Diaper Rash Creams
  Baby Feeding: Nursing Bottles | Pacifiers | Breast Pumps | High Chairs
  Baby Bath & Skin: Baby Soap | Baby Shampoo | Baby Lotion | Baby Oil
  Baby Gear: Strollers | Prams | Baby Carriers | Walkers
  Nursery & Bedding: Baby Cots | Mosquito Nets | Baby Pillows | Sleeping Bags
Automotive & Motorbikes
  Car Accessories: Car Seat Covers | GPS Navigators | Car Fresheners | Car Dash Cams
  Motorbike Accessories: Helmets | Riding Jackets | Motorbike Locks | Gloves
  Car & Bike Care: Car Wash Shampoos | Polishes | Microfiber Cloths | Engine Oils
  Vehicle Spare Parts: Brake Pads | Spark Plugs | LED Lights | Tyres
  Tools & Repair Kits: Puncture Repair Kits | Jack Sets | Tool Sets | Air Compressors
Jewelry & Luxury Goods
  Fine Jewelry: Diamond Rings | Gold Chains | Platinum Bands | Pearl Earrings
  Fashion Jewelry: Necklaces | Bangles | Anklets | Brooches
  Watches: Analog Watches | Automatic Watches | Chronograph Watches | Pocket Watches
  Eyewear: Sunglasses | Reading Glasses | Computer Glasses | Eyeglass Frames
  Precious Stones: Gemstones | Birthstones | Rough Stones | Beads
Bags & Luggage
  Travel Bags: Trolley Suitcases | Duffel Bags | Travel Backpacks | Garment Bags
  Everyday Bags: Laptop Backpacks | Messenger Bags | Sling Bags | Tote Bags
  Women's Handbags: Shoulder Bags | Clutches | Wallets | Crossbody Bags
  Specialty Bags: Gym Bags | Camera Bags | Picnic Bags | Hiking Rucksacks
  Small Leather Goods: Men's Wallets | Key Holders | Passport Cover | Card Holders
Musical Instruments
  String Instruments: Acoustic Guitars | Electric Guitars | Ukuleles | Violins
  Keyboards & Pianos: Digital Pianos | Synthesizers | MIDI Keyboards | Organs
  Drums & Percussion: Drum Sets | Cajons | Cymbals | Tablas
  Wind Instruments: Flutes | Saxophones | Harmonicas | Trumpets
  Audio & Studio Gear: Microphones | Audio Interfaces | Studio Monitors | Headphones
Digital Products & Software
  Software: Operating Systems | Antivirus | Video Editing Software | Office Apps
  Video Games: PC Games | PlayStation Games | Xbox Games | Nintendo Games
  E-Books & Audiobooks: Digital Books | Course PDFs | Audiobooks | Study Guides
  Digital Courses: Programming Courses | Graphic Design | Marketing | Skill Courses
  Subscriptions: Gift Cards | Streaming Memberships | Cloud Storage Plans
Pet Supplies
  Dog Supplies: Dog Food | Leashes & Collars | Dog Toys | Grooming Shampoos
  Cat Supplies: Cat Food | Litter Sand | Scratching Posts | Cat Beds
  Fish & Aquariums: Fish Food | Aquarium Tanks | Water Filters | Aquarium Lights
  Bird Supplies: Bird Seeds | Cages | Bird Toys | Water Feeders
  Small Animal Care: Rabbit Food | Hamster Cages | Grooming Brushes | Treats
Industrial & B2B Supplies
  Safety Equipment: Safety Helmets | Safety Shoes | Gloves | Goggles
  Packaging Materials: Bubble Wraps | Carton Boxes | Poly Mailers | Tapes
  Hardware & Fasteners: Screws | Nuts & Bolts | Hinges | Door Handles
  Power Tools: Drills | Angle Grinders | Welding Machines | Saw Machines
  Measuring Tools: Laser Distance Meters | Calipers | Measuring Tapes | Level Gauges
Garden & Outdoor Living
  Plants & Seeds: Flower Seeds | Vegetable Seeds | Indoor Plants | Succulents
  Pots & Planters: Plastic Pots | Ceramic Pots | Hanging Baskets | Plant Stands
  Gardening Tools: Pruning Shears | Watering Hoses | Lawn Mowers | Shovels
  Fertilizers & Soil: Organic Compost | Chemical Fertilizers | Coco Peat | Pesticides
  Outdoor Decor: Garden Lights | Solar Lamps | Fountains | Patio Benches
Arts, Crafts & Sewing
  Painting Supplies: Acrylic Paints | Canvas Boards | Paint Brushes | Easels
  Craft Materials: Craft Paper | Glue Guns | Resin Kits | Clay
  Sewing & Knitting: Sewing Machines | Threads | Yarns | Knitting Needles
  Calligraphy & Sketching: Sketchbooks | Charcoal Pencils | Calligraphy Pens | Inks
  Jewelry Making: Beads | Wires | Pliers | Jewelry Charms
Food & Beverages (Gourmet)
  Gourmet Food: Imported Chocolates | Specialty Cheese | Olive Oil | Truffles
  Organic Food: Organic Honey | Chia Seeds | Oats | Brown Rice
  Specialty Tea & Coffee: Green Tea | Matcha | Roasted Coffee Beans | Herbal Tea
  Baking Ingredients: Cocoa Powder | Chocolate Chips | Baking Soda | Vanilla Extract
  International Foods: Korean Ramen | Mexican Salsa | Italian Pasta | Japanese Snacks
Security & Surveillance
  CCTV Systems: IP Cameras | Dome Cameras | Wireless Security Cameras | DVRs
  Smart Home Locks: Fingerprint Locks | Password Locks | Video Doorbells
  Alarms & Sensors: Smoke Detectors | Motion Sensors | Burglar Alarms
  Access Control: Biometric Attendance Systems | RFID Cards | Door Access
  Safes & Vaults: Digital Safes | Fireproof Safes | Key Lockers
Office Furniture & Setup
  Office Chairs: Ergonomic Chairs | Executive Chairs | Mesh Chairs | Stools
  Office Desks: Executive Desks | Standing Desks | Computer Tables | Conference Tables
  Storage Units: Filing Cabinets | Bookshelves | Mobile Pedestals | Lockers
  Workstation Accessories: Monitor Arms | Cable Management | Footrests | Desk Mats
  Partition & Panels: Acoustic Panels | Office Dividers | Whiteboards
Travel & Outdoor Accessories
  Travel Comfort: Neck Pillows | Eye Masks | Earplugs | Luggage Tags
  Travel Electronics: Universal Adapters | Portable Fans | Luggage Scales
  Travel Bottles & Organizers: Toiletry Bags | Packing Cubes | Shoe Bags
  Outdoor Cooking: Portable Gas Stoves | Barbecue Grills | Camping Cookware
  Hydration: Thermos Flasks | Hydration Packs | Water Purification Straws
Party & Event Supplies
  Party Decorations: Balloons | Banners | LED Fairy Lights | Photobooth Props
  Tableware & Disposable: Paper Plates | Cups | Napkins | Cake Stands
  Costumes & Masks: Party Masks | Fancy Dress Costumes | Wigs | Caps
  Gift Wrapping: Gift Bags | Wrapping Paper | Ribbon Rolls | Gift Boxes
  Event Lighting: Strobe Lights | Fog Machines | Party Laser Lights
Cleaning & Household Supplies
  Laundry Care: Detergent Powders | Liquid Detergents | Fabric Conditioners
  Surface Cleaners: Floor Cleaners | Toilet Cleaners | Glass Cleaners | Disinfectants
  Cleaning Tools: Brooms | Mops | Wiping Cloths | Scrubbers
  Paper & Wipes: Tissue Papers | Kitchen Towels | Toilet Rolls
  Pest Control: Insect Sprays | Mosquito Nets | Rat Traps | Cockroach Gels
Religious & Spiritual Items
  Prayer Items: Prayer Mats (Jainamaz) | Tasbih | Puja Brassware | Incense Sticks (Agarbatti)
  Religious Attire: Ihram | Prayer Caps (Topi) | Hijabs | Festival Clothes
  Spiritual Decor: Wall Hanging Frames | Brass Idols | Islamic Calligraphy | Feng Shui Items
  Festive Supplies: Eid Decor | Diwali Lights | Christmas Trees & Ornaments | Puja Kits
  Books & Audio: Spiritual Books | Audio Players with Religious Chants/Recitations
Renewable Energy & Solar
  Solar Panels: Monocrystalline Panels | Polycrystalline Panels | Portable Solar Panels
  Solar Inverters & Controllers: MPPT Charge Controllers | Off-Grid Inverters | On-Grid Inverters
  Solar Lighting: Solar Street Lights | Solar Garden Lights | Solar Lanterns
  Solar Batteries: Gel Batteries | Lithium-ion Solar Batteries | Deep Cycle Batteries
  Solar Accessories: Solar Cables | Connectors (MC4) | Mounting Structure
Electrical Tools & Wiring
  Wires & Cables: Copper Wires | Coaxial Cables | Network Cables (Cat6) | Flexible Wires
  Switches & Sockets: Modular Switches | Smart Switches | Multi-plugs | Extension Sockets
  Circuit Breakers: MCB | RCCB | Distribution Boxes | Main Switches
  Transformers & Stabilizers: Voltage Stabilizers | Step-down Transformers | Inverters
  Conduits & Fittings: PVC Pipes | Junction Boxes | Cable Trays | Wire Clips
Plumbing & Bathroom Fittings
  Faucets & Taps: Kitchen Faucets | Basin Mixers | Shower Taps | Sensor Taps
  Showers & Enclosures: Overhead Showers | Hand Showers | Shower Panels | Glass Cubicles
  Sanitaryware: Toilets (Commode) | Wash Basins | Urinals | Cisterns
  Pipes & Fittings: PVC Pipes | CPVC Pipes | Ball Valves | Pipe Connectors
  Bathroom Accessories: Towel Racks | Soap Dispensers | Toothbrush Holders | Mirrors
Construction Materials
  Building Supplies: Cement | Steel Rods | Bricks | Sand
  Tiles & Flooring: Ceramic Floor Tiles | Wall Tiles | Wooden Laminate | Marble
  Paints & Wall Finishes: Interior Emulsion | Exterior Paints | Wall Putty | Primers
  Roofing & Insulation: Roofing Sheets | Heat Insulation Foam | Waterproofing Chemicals
  Glass & Polycarbonate: Toughened Glass | Acrylic Sheets | Polycarbonate Sheets
Commercial Kitchen Equipment
  Cooking Ranges: Commercial Gas Stoves | Deep Fryers | Tandoors | Griddles
  Refrigeration: Display Chillers | Chest Freezers | Ice Makers | Cold Room Units
  Food Prep Machines: Dough Mixers | Meat Grinders | Vegetable Cutters | Slicers
  Display & Counter: Bain Marie | Food Warmers | Bakery Display Counters
  Dishwashing & Cleaning: Commercial Dishwashers | Stainless Steel Sinks | Drain Racks
Scientific & Lab Equipment
  Microscopes & Optics: Compound Microscopes | Stereo Microscopes | Magnifiers
  Lab Glassware: Beakers | Flasks | Test Tubes | Graduated Cylinders
  Measuring & Testing: pH Meters | Digital Scales | Spectrophotometers | Centrifuges
  Chemicals & Reagents: Laboratory Grade Chemicals | Stains | Test Strips
  Lab Safety: Fume Hoods | Eyewash Stations | Lab Coats | Nitrile Gloves
Heavy Machinery & Equipment
  Earthmoving Equipment: Mini Excavators | Loaders | Compactors | Trenchers
  Material Handling: Forklifts | Pallet Jacks | Crane Hoists | Conveyor Belts
  Generators & Engines: Diesel Generators | Gasoline Generators | Industrial Engines
  Agricultural Machinery: Power Tillers | Tractors | Seeders | Irrigation Pumps
  Compressors & Blowers: Air Compressors | Industrial Blowers | Vacuum Pumps
Gaming Equipment & Accessories
  Consoles & VR: PlayStation Consoles | Xbox Consoles | Nintendo Switch | VR Headsets
  Gaming Peripherals: Mechanical Gaming Keyboards | Gaming Mice | Controllers | Flight Sticks
  Gaming Audio: Gaming Headsets | Streaming Microphones | Sound Cards
  Gaming Chairs & Desks: Ergonomic Gaming Chairs | RGB Gaming Desks | Floor Mats
  Gaming Components: Graphics Cards | Liquid Coolers | RGB Fans | PC Cases
Smart Home & Automation
  Smart Lighting: Smart Bulbs | RGB Light Bars | Smart Switches | Motion Sensors
  Smart Assistants: Smart Speakers (Echo, Nest) | Smart Displays | Hubs
  Smart Climate Control: Smart Thermostats | Smart AC Controllers | IR Blasters
  Smart Security: Video Doorbells | Smart Locks | Window Sensors | Siren Alarms
  Smart Cleaning: Robot Vacuum Cleaners | Automated Mops | Window Cleaners
Print & Publishing Supplies
  Commercial Printers: Offset Printers | Large Format Plotters | 3D Printers
  Printing Inks & Toners: Laser Printer Toners | Inkjet Inks | Sublimation Inks
  Print Media: Glossy Photo Paper | Vinyl Sheets | Canvas Rolls | Banner Media
  Binding & Finishing: Laminating Machines | Binding Machines | Paper Cutters
  3D Printing Supplies: PLA Filaments | ABS Filaments | Resin Bottles | Nozzles
Optometry & Eye Care
  Contact Lenses: Daily Disposable Lenses | Monthly Lenses | Color Lenses
  Lens Care: Contact Lens Solutions | Lens Cases | Eye Drops
  Reading Glasses: Blue Light Blocking Glasses | Bi-focal Glasses | Folding Readers
  Eyeglass Accessories: Glasses Cases | Microfiber Cleaning Cloths | Chains & Cords
  Vision Testing: Snellen Charts | Trial Lens Sets | Ophthalmoscopes
Orthopedic & Rehabilitative Care
  Supports & Braces: Ankle Braces | Wrist Supports | Cervical Collars | Lumbar Belts
  Compression Garments: Compression Socks | Arm Sleeves | Post-Surgery Wear
  Physiotherapy Equipment: TENS Units | Muscle Stimulators | Heat Therapy Pads | Resistance Bands
  Ergonomic Cushions: Memory Foam Seat Cushions | Lumbar Support Pillows | Donut Cushions
  Mobility Accessories: Wheelchair Cushions | Ramp Slopes | Crutch Pads
Vintage & Antiques
  Antique Furniture: Vintage Wooden Chairs | Antique Chests | Brass Tables
  Collectibles: Old Coins & Currency | Vintage Stamps | Pocket Watches | Gramophones
  Vintage Decor: Brass Statues | Retro Clocks | Antique Oil Lamps | Vintage Mirrors
  Retro Electronics: Tube Radios | Vinyl Record Players | Vintage Cameras | Typewriters
  Antique Fine Art: Oil Paintings | Classic Tapestries | Sculptures
Firearms & Tactical Gear (Regulated)
  Tactical Clothing: Cargo Pants | Tactical Boots | Camouflage Jackets | Combat Shirts
  Holsters & Pouches: Gun Holsters | Ammo Pouches | Utility Belts | Vest Carriers
  Optical Sights: Red Dot Sights | Rifle Scopes | Night Vision Goggles | Rangefinders
  Knives & Multi-tools: Tactical Knives | Folding Pocket Knives | Multi-tool Pliers
  Gun Care: Cleaning Rods | Gun Oils | Solvents | Hard Gun Cases
Marine & Boating
  Boat Electronics: Fish Finders | Marine GPS | Marine Radios | Depth Sounders
  Safety Gear: Life Jackets | Throw Buoys | Flare Guns | Bilge Pumps
  Boat Maintenance: Marine Paint | Boat Covers | Anchors | Ropes & Cleats
  Water Sports Gear: Kayaks | Paddleboards | Water Skis | Inflatable Boats
  Boat Hardware: Stainless Steel Cleats | Bimini Tops | Marine Switches
Commercial Signage & Displays
  Digital Signage: Commercial Display Screens | LED Video Walls | Kiosks
  Display Stands: Roll-up Banners | A-Frame Signs | Brochure Holders | Pop-up Displays
  Lighting Signs: LED Neon Signs | Acrylic Light Boxes | Channel Letter Signs
  Retail Fixtures: Clothes Racks | Mannequins | Gridwall Panels | Price Tag Holders
  Safety Signs: Fire Exit Signs | Caution Wet Floor Signs | Traffic Warning Signs
Vending & Self-Service
  Vending Machines: Snack Vending Machines | Beverage Vending Machines | Coffee Vending
  ATM & Payment Kiosks: Self-Service Kiosks | Card Swiping Terminals | Cash Acceptors
  Arcade & Crane Games: Claw Machines | Arcade Cabinets | Coin-operated Rides
  Vending Supplies: Coin Mechanisms | Bill Acceptors | Paper Cup Dispensers
  Ticket Dispensers: Queue Management Systems | Token Dispensers | Thermal Paper Rolls
Livestock & Farming Supplies
  Cattle & Poultry Care: Milking Machines | Cattle Feed | Poultry Waterers | Incubators
  Fencing & Enclosures: Electric Fencing | Barbed Wire | Chain Link Fences
  Veterinary Equipment: Syringes | Veterinary Thermometers | Castration Tools
  Feed & Nutrition: Animal Feed Supplements | Hay Bales | Mineral Licks
  Farm Storage: Grain Silos | Water Storage Tanks | Milk Cans
Rental & Event Logistics
  Event Tents & Canopies: Party Marquees | Pop-up Canopies | Exhibition Tents
  Stage & Trussing: Portable Stages | Aluminum Trussing | Stage Barriers
  Event Furniture Rental: Banquet Chairs | Folding Tables | Red Carpets
  Power & HVAC Rental: Portable Generators | Mobile AC Units | Industrial Fans
  Audio Visual Rental: PA Systems | LED Screens | Stage Lighting Rigs
Funeral & Memorial Supplies
  Caskets & Coffins: Wooden Caskets | Metal Coffins | Burial Vaults
  Memorial Products: Headstones | Urns | Grave Markers | Memorial Plaques
  Funeral Decor: Wreath Stands | Burial Drapes | Funeral Candles
  Grave Care: Flower Vases | Gravestone Cleaners | Memorial Solar Lights
  Stationery & Keepsakes: Memorial Guest Books | Prayer Cards | Remembrance Jewelry
CATALOG;

$dryRun = in_array('--dry-run', $argv, true);
$forceReplace = in_array('--force', $argv, true);
$parsedCatalog = parseCatalog($catalogText);
$catalogTree = $parsedCatalog['tree'];
$catalogStats = $parsedCatalog['stats'];
$existingProductCount = Schema::hasTable('products') ? DB::table('products')->count() : 0;

if ($existingProductCount > 0 && !$forceReplace) {
    fwrite(
        STDERR,
        "Aborted: products table contains {$existingProductCount} rows. Re-run with --force after confirming category replacement is safe.\n"
    );
    exit(1);
}

if ($dryRun) {
    fwrite(STDOUT, json_encode([
        'mode' => 'dry-run',
        'product_count' => $existingProductCount,
        'catalog_stats' => $catalogStats,
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
    exit(0);
}

$backupFile = backupExistingCategoryState($catalogStats);
$usedSlugs = [];
$rootHomeLimit = 18;

DB::beginTransaction();

try {
    if (Schema::hasTable('translations')) {
        DB::table('translations')->where('translationable_type', 'App\Models\Category')->delete();
    }

    if (Schema::hasTable('seo_meta_info')) {
        DB::table('seo_meta_info')->where('seoable_type', 'App\Models\Category')->delete();
    }

    if (Schema::hasTable('taxables')) {
        DB::table('taxables')->where('taxable_type', 'App\Models\Category')->delete();
    }

    if (Schema::hasTable('category_shipping_costs')) {
        DB::table('category_shipping_costs')->delete();
    }

    DB::table('categories')->delete();

    $now = now();

    foreach ($catalogTree as $rootIndex => $rootCategory) {
        $rootId = DB::table('categories')->insertGetId([
            'name' => $rootCategory['name'],
            'slug' => makeUniqueSlug($usedSlugs, [$rootCategory['name']]),
            'icon' => null,
            'icon_storage_type' => 'public',
            'parent_id' => 0,
            'position' => 0,
            'home_status' => $rootIndex < $rootHomeLimit ? 1 : 0,
            'priority' => $rootIndex + 1,
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        foreach ($rootCategory['children'] as $subIndex => $subCategory) {
            $subId = DB::table('categories')->insertGetId([
                'name' => $subCategory['name'],
                'slug' => makeUniqueSlug($usedSlugs, [$rootCategory['name'], $subCategory['name']]),
                'icon' => null,
                'icon_storage_type' => 'public',
                'parent_id' => $rootId,
                'position' => 1,
                'home_status' => 0,
                'priority' => $subIndex + 1,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            foreach ($subCategory['children'] as $subSubIndex => $subSubCategoryName) {
                DB::table('categories')->insert([
                    'name' => $subSubCategoryName,
                    'slug' => makeUniqueSlug($usedSlugs, [$rootCategory['name'], $subCategory['name'], $subSubCategoryName]),
                    'icon' => null,
                    'icon_storage_type' => 'public',
                    'parent_id' => $subId,
                    'position' => 2,
                    'home_status' => 0,
                    'priority' => $subSubIndex + 1,
                    'created_at' => $now,
                    'updated_at' => $now,
                ]);
            }
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
    'mode' => 'import',
    'backup_file' => $backupFile,
    'product_count' => $existingProductCount,
    'catalog_stats' => $catalogStats,
    'database_counts' => [
        'roots' => DB::table('categories')->where('position', 0)->count(),
        'sub_categories' => DB::table('categories')->where('position', 1)->count(),
        'sub_sub_categories' => DB::table('categories')->where('position', 2)->count(),
        'total_categories' => DB::table('categories')->count(),
    ],
], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . PHP_EOL);
