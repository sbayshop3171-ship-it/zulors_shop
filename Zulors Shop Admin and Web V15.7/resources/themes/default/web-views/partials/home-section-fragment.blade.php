@switch($section)
    @case('featured-deals')
        @if($featuredDealProducts && count($featuredDealProducts) > 0)
            <section class="featured_deal pb-3">
                <div class="container">
                    <div class="__featured-deal-wrap bg--light px-0-mobile">
                        <div class="d-flex flex-wrap justify-content-between align-items-center align-items-sm-start gap-8 mb-3">
                            <div class="w-0 flex-grow-1">
                                <span class="featured_deal_title font-bold text-dark">{{ translate('featured_deal') }}</span>
                                <br>
                                <span class="text-left">{{ translate('see_the_latest_deals_and_exciting_new_offers') }}!</span>
                            </div>
                            <a class="text-capitalize view-all-text web-text-primary" href="{{ route('featured-deal-products') }}">
                                {{ translate('view_all') }}
                                <i class="czi-arrow-{{ Session::get('direction') === 'rtl' ? 'left mr-1 ml-n1 mt-1' : 'right ml-1' }}"></i>
                            </a>
                        </div>
                        <div class="owl-carousel owl-theme new-arrivals-product">
                            @foreach($featuredDealProducts as $key => $product)
                                @include('web-views.partials._product-card-1', ['product' => $product, 'decimal_point_settings' => $decimalPointSettings, 'prioritizeImage' => $key < 4])
                            @endforeach
                        </div>
                    </div>
                </div>
            </section>
        @endif
        @break

    @case('clearance-sale')
        @include('web-views.partials._clearance-sale-products', ['clearanceSaleProducts' => $clearanceSaleProducts])
        @break

    @case('main-section-banner')
        @if($bannerTypeMainSectionBanner)
            <div class="container rtl pt-0 px-0 px-md-3">
                <a href="{{ $bannerTypeMainSectionBanner->url }}" target="_blank" class="cursor-pointer d-block">
                    <img loading="lazy" decoding="async" width="1200" height="300" class="d-block footer_banner_img __inline-63" alt=""
                         src="{{ getStorageImages(path: $bannerTypeMainSectionBanner->photo_full_url, type: 'wide-banner') }}">
                </a>
            </div>
        @endif
        @break

    @case('top-sellers')
        @if(count($topVendorsList) > 0)
            @include('web-views.partials._top-sellers')
        @endif
        @break

    @case('deal-of-the-day')
        @include('web-views.partials._deal-of-the-day', ['decimal_point_settings' => $decimalPointSettings])
        @break

    @case('product-highlights')
        <section class="new-arrival-section">
            @if($newArrivalProducts->count() > 0)
                <div class="container rtl">
                    <div class="section-header">
                        <h2 class="arrival-title d-block mb-1">
                            <span class="text-capitalize">{{ translate('new_arrivals') }}</span>
                        </h2>
                    </div>
                </div>
                <div class="container rtl mb-3 overflow-hidden">
                    <div class="py-2">
                        <div class="new_arrival_product">
                            <div class="carousel-wrap">
                                <div class="owl-carousel owl-theme new-arrivals-product">
                                    @foreach($newArrivalProducts as $product)
                                        @include('web-views.partials._product-card-2', ['product' => $product, 'decimalPointSettings' => $decimalPointSettings])
                                    @endforeach
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            @endif
            <div class="container rtl px-0 px-md-3">
                <div class="row g-3 mx-max-md-0">
                    @if($bestSellProduct->count() > 0)
                        @include('web-views.partials._best-selling')
                    @endif
                    @if($topRatedProducts->count() > 0)
                        @include('web-views.partials._top-rated')
                    @endif
                </div>
            </div>
        </section>
        @break

    @case('brands-and-banners')
        @if(count($bannerTypeFooterBanner) > 1)
            <div class="container rtl">
                <div class="promotional-banner-slider owl-carousel owl-theme">
                    @foreach($bannerTypeFooterBanner as $banner)
                        <a href="{{ $banner['url'] }}" class="d-block" target="_blank">
                            <img loading="lazy" decoding="async" width="1200" height="300" class="footer_banner_img __inline-63" alt=""
                                 src="{{ getStorageImages(path: $banner->photo_full_url, type: 'banner') }}">
                        </a>
                    @endforeach
                </div>
            </div>
        @elseif(count($bannerTypeFooterBanner) === 1)
            <div class="container rtl">
                <div class="row">
                    @foreach($bannerTypeFooterBanner as $banner)
                        <div class="col-md-6">
                            <a href="{{ $banner['url'] }}" class="d-block" target="_blank">
                                <img loading="lazy" decoding="async" width="1200" height="300" class="footer_banner_img __inline-63" alt=""
                                     src="{{ getStorageImages(path: $banner->photo_full_url, type: 'banner') }}">
                            </a>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

        @if($brandSetting && $brands->count() > 0)
            <section class="container rtl">
                <div class="section-header align-items-center mb-1">
                    <h2 class="text-black font-bold __text-22px mb-0"><span>{{ translate('brands') }}</span></h2>
                    <div class="__mr-2px">
                        <a class="text-capitalize view-all-text web-text-primary" href="{{ route('brands') }}">
                            {{ translate('view_all') }}
                            <i class="czi-arrow-{{ Session::get('direction') === 'rtl' ? 'left mr-1 ml-n1 mt-1 float-left' : 'right ml-1 mr-n1' }}"></i>
                        </a>
                    </div>
                </div>
                <div class="mt-sm-3 mb-0 brand-slider">
                    <div class="owl-carousel owl-theme p-2 brands-slider">
                        @foreach($brands->take(15) as $brand)
                            <div class="text-center">
                                <a href="{{ route('brand-products', ['slug' => $brand['slug']]) }}" class="__brand-item">
                                    <img loading="lazy" decoding="async" width="120" height="120" alt="{{ $brand->image_alt_text }}"
                                         src="{{ getStorageImages(path: $brand->image_full_url, type: 'brand') }}">
                                </a>
                            </div>
                        @endforeach
                    </div>
                </div>
            </section>
        @endif
        @break

    @case('category-products')
        @include('web-views.partials._category-wise-product', ['category' => $category, 'decimalPointSettings' => $decimalPointSettings])
        @break

    @case('company-reliability')
        @if($companyReliability)
            @include('web-views.partials._company-reliability')
        @endif
        @break
@endswitch
