@extends('layouts.front-end.app')

@section('title', $web_config['meta_title'])

@push('css_or_js')
    <link rel="stylesheet" href="{{ theme_asset(path: 'public/assets/front-end/css/home.css') }}"/>
    <link rel="stylesheet" href="{{ theme_asset(path: 'public/assets/front-end/css/owl.carousel.min.css') }}">
    <link rel="stylesheet" href="{{ theme_asset(path: 'public/assets/front-end/css/owl.theme.default.min.css') }}">
    @php($heroBanner = $bannerTypeMainBanner[0] ?? null)
    @if($heroBanner)
        <link rel="preload" as="image" href="{{ getStorageImages(path: $heroBanner->photo_full_url, type: 'banner') }}" fetchpriority="high">
    @endif
@endpush

@section('content')
    @php
        $isPrefetchRequest = request()->header('X-Zulors-Prefetch') === '1';
        $orderSuccessIds = $isPrefetchRequest ? null : session('order_success_ids');
        $isNewCustomerInSession = $isPrefetchRequest ? null : session('isNewCustomerInSession');
        if (!$isPrefetchRequest) {
            session()->forget('order_success_ids');
            session()->forget('isNewCustomerInSession');
        }
        $decimalPointSettings = !empty(getWebConfig(name: 'decimal_point_settings')) ? getWebConfig(name: 'decimal_point_settings') : 0;
    @endphp

    @include('web-views.partials._order-success-modal', ['orderSuccessIds' => $orderSuccessIds, 'isNewCustomerInSession' => $isNewCustomerInSession])

    <div class="__inline-61 d-flex flex-column gap-20">
        @include('web-views.partials._home-top-slider', ['bannerTypeMainBanner' => $bannerTypeMainBanner])

        @if($flashDeal['flashDeal'] && $flashDeal['flashDealProducts'] && count($flashDeal['flashDealProducts']) > 0)
            @include('web-views.partials._flash-deal', ['decimal_point_settings' => $decimalPointSettings])
        @endif

        @if($featuredProductsList->count() > 0)
            <div class="container">
                <div class="__inline-62 section-card-margin">
                    <h2 class="feature-product-title pt-3 web-text-primary mt-0 mb-0 letter-spacing-0">{{ translate('featured_products') }}</h2>
                    <div class="text-end px-3 d-none d-md-block">
                        <a class="text-capitalize view-all-text web-text-primary" href="{{ route('featured-products') }}">
                            {{ translate('view_all') }}
                            <i class="czi-arrow-{{ Session::get('direction') === 'rtl' ? 'left mr-1 ml-n1 mt-1' : 'right ml-1' }}"></i>
                        </a>
                    </div>
                    <div class="feature-product">
                        <div class="carousel-wrap p-1">
                            <div class="owl-carousel owl-theme" id="featured_products_list" data-loop="{{ count($featuredProductsList) > 6 ? 'true' : 'false' }}">
                                @foreach($featuredProductsList as $key => $product)
                                    <div>
                                        @include('web-views.partials._feature-product', [
                                            'product' => $product,
                                            'decimal_point_settings' => $decimalPointSettings,
                                            'prioritizeImage' => $key < 4,
                                        ])
                                    </div>
                                @endforeach
                            </div>
                        </div>
                        <div class="text-center pt-2 d-md-none">
                            <a class="text-capitalize view-all-text web-text-primary" href="{{ route('featured-products') }}">
                                {{ translate('view_all') }}
                                <i class="czi-arrow-{{ Session::get('direction') === 'rtl' ? 'left mr-1 ml-n1 mt-1' : 'right ml-1' }}"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        @endif

        @include('web-views.partials._category-section-home')

        <div class="home-section-placeholder home-section-placeholder--featured-deals" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'featured-deals']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        <div class="home-section-placeholder home-section-placeholder--clearance" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'clearance-sale']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        <div class="home-section-placeholder home-section-placeholder--banner" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'main-section-banner']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>

        @if(getWebConfig(name: 'business_mode') === 'multi')
            <div class="home-section-placeholder home-section-placeholder--sellers" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'top-sellers']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        @endif

        <div class="home-section-placeholder home-section-placeholder--deal" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'deal-of-the-day']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        <div class="home-section-placeholder home-section-placeholder--products" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'product-highlights']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        <div class="home-section-placeholder home-section-placeholder--brands" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'brands-and-banners']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>

        @foreach($homeCategories as $category)
            <div class="home-section-placeholder home-section-placeholder--category-products" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'category-products', 'id' => $category->id]) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        @endforeach

        @if(getWebConfig(name: 'company_reliability'))
            <div class="home-section-placeholder home-section-placeholder--reliability" data-home-section data-home-section-url="{{ route('home-section', ['section' => 'company-reliability']) }}" role="status" aria-busy="true" aria-label="{{ translate('loading') }}"></div>
        @endif
    </div>

    <span id="direction-from-session" data-value="{{ session()->get('direction') }}"></span>
@endsection

@push('script')
    @if($orderSuccessIds)
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                var modalEl = document.getElementById('order_successfully');
                var orderModal = new bootstrap.Modal(modalEl, { backdrop: 'static', keyboard: false });
                orderModal.show();

                document.querySelectorAll('.copy-order-id').forEach(function (copyBtn) {
                    copyBtn.addEventListener('click', function () {
                        var orderTextEl = this.closest('tr')?.querySelector('.order-id-text') || this.parentElement.querySelector('.order-id-text');
                        var orderText = orderTextEl?.textContent.trim();
                        if (!orderText) return;
                        navigator.clipboard.writeText(orderText).then(function () {
                            toastr.success('Order ID copied successfully!');
                        }).catch(function () {
                            toastr.warning('Unable to copy. Clipboard requires HTTPS or localhost.');
                        });
                    });
                });
                document.getElementById('modal-close-btn')?.addEventListener('click', function () {
                    setTimeout(function () { orderModal.hide(); }, 600);
                });
            });
        </script>
    @endif

    @if(!$isPrefetchRequest && Request::is('/') && \Illuminate\Support\Facades\Cookie::has('popup_banner') == false && empty($orderSuccessIds))
        <script>
            $(document).ready(function () { $('#popup-modal').modal('show'); });
        </script>
        @php(\Illuminate\Support\Facades\Cookie::queue('popup_banner', 'off', 1))
    @endif

    <script src="{{ theme_asset(path: 'public/assets/front-end/js/owl.carousel.min.js') }}"></script>
    <script src="{{ theme_asset(path: 'public/assets/front-end/js/home.js') }}?v={{ file_exists(public_path('assets/front-end/js/home.js')) ? filemtime(public_path('assets/front-end/js/home.js')) : time() }}"></script>
    <script src="{{ theme_asset(path: 'public/assets/front-end/js/home-sections.js') }}?v={{ file_exists(public_path('assets/front-end/js/home-sections.js')) ? filemtime(public_path('assets/front-end/js/home-sections.js')) : time() }}"></script>
@endpush
