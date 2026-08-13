@extends('layouts.vendor.app')

@section('title', translate('POS'))
@push('css_or_js')
    <meta name="csrf-token" content="{{ csrf_token() }}" />
    <link rel="stylesheet" href="{{ dynamicAsset(path: 'public/assets/back-end/plugins/intl-tel-input/css/intlTelInput.css') }}">
@endpush
@section('content')
    <div class="content container-fluid">
        <div class="row">
            <div class="col-lg-7 mb-4 mb-lg-0">
                <div class="card">
                    <div class="card-header border-0 bg-section2">
                        <h3 class="m-0">{{ translate('product_Section') }}</h3>
                    </div>
                    <div class="px-3 py-4">
                        <div class="row gy-1">
                            <div class="col-sm-6">
                                <div class="input-group d-flex justify-content-end">
                                    <select name="category" id="category"
                                            class="form-control js-select2-custom w-100 action-category-filter"
                                            title="select category">
                                        <option value="">{{ translate('all_categories') }}</option>
                                        @foreach ($categories as $item)
                                            <option value="{{$item->id}}" {{$categoryId==$item->id?'selected':''}}>
                                                {{ $item->defaultName }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <form class="">
                                    <div class="input-group-overlay input-group-merge input-group-custom">
                                        <div class="input-group-prepend">
                                            <div class="input-group-text">
                                                <i class="tio-search"></i>
                                            </div>
                                        </div>
                                        <input id="search" autocomplete="off" type="text"
                                                value="{{ $searchValue }}"
                                                name="searchValue" class="form-control search-bar-input"
                                                placeholder="{{ translate('search_by_name_or_sku') }}"
                                                aria-label="Search here">
                                        <diV class="card pos-search-card w-4 position-absolute z-index-1 w-100">
                                            <div id="pos-search-box" class="card-body search-result-box d--none">
                                            </div>
                                        </diV>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <div class="card-body pt-2" id="items">
                        @if(count($products) > 0)
                            <div class="pos-item-wrap">
                                @foreach($products as $product)
                                    @include('vendor-views.pos.partials._single-product', ['product'=>$product])
                                @endforeach
                            </div>
                        @else
                            <div class="p-4 bg-chat rounded text-center">
                                <div class="py-5">
                                    <img src="http://localhost/zulors-shop/public/assets/back-end/img/empty-product.png" width="64" alt="">
                                    <div class="mx-auto my-3 max-w-353px">
                                        {{ translate('Currently_no_product_available_by_this_name') }}
                                    </div>
                                </div>
                            </div>
                        @endif

                    </div>

                    <div class="table-responsive mt-4">
                        <div class="px-4 d-flex justify-content-lg-end">
                            {!!$products->withQueryString()->links()!!}
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="card billing-section-wrap overflow-hidden">
                     <div class="card-header border-0 bg-section2 p-2 d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <h3 class="px-3 m-0">{{ translate('Billing_Section') }}</h3>
                        <button type="button" class="btn text-primary bg-white border-0 d-flex align-items-center justify-content-center gap-2 action-view-all-hold-orders"
                            data-toggle="tooltip" data-title="{{ translate('please_resume_the_order_from_here') }}">
                            <span class="fw-medium">{{ translate('view_All_Hold_Orders') }}</span>
                            <span class="total_hold_orders btn bg-danger text-white fw-medium h-25px p-1 btn-circle" style="--size: 25px;">
                                {{ $totalHoldOrder}}
                            </span>
                        </button>
                    </div>
                    <div class="card-body d-flex flex-column gap-20 overflow-y-auto">
                        <div>
                            @php
                                $userId = 0;
                                if (Illuminate\Support\Str::contains(session('current_user'), 'saved-customer')) {
                                    $userId = explode('-', session('current_user'))[2];
                                }
                            @endphp

                            <div class="position-relative custom_dropdown_wrapper">
                                <div class="form-control custom_dropdown_toggle d-flex gap-2 justify-content-between align-items-center min-h-40 h-auto overflow-wrap-anywhere">
                                    <span class="selected_text">
                                        {{ $userId == 0 ? translate('Walk In Customer') : ($customers->firstWhere('id', $userId)->f_name ?? '') . ' ' . ($customers->firstWhere('id', $userId)->l_name ?? '') }}
                                    </span>
                                    <i class="fi fi-sr-angle-down fs-12"></i>
                                </div>
                                <div class="custom_dropdown_menu">
                                    <div class="card card-body p-3 shadow-popup">
                                        <div class="d-flex flex-column gap-2">
                                            <div class="position-relative d-flex form-control align-items-center gap-2 bg-section">
                                                <i class="fi fi-rr-search fs-16"></i>
                                                <input type="search" class="w-100 border-0 outline-none bg-transparent custom_dropdown_search" placeholder="{{ translate('Search_name_or_phone_number') }}">
                                            </div>
                                            <a class="text-primary fw-medium text-underline text-capitalize text-end" id="add_new_customer" type="button"
                                               data-toggle="modal" href="#add-customer" title="{{ translate('add_new_customer') }}">
                                                + {{ translate('add_New_Customer') }}
                                            </a>
                                            <div class="custom_dropdown_list">
                                                <div class="custom_dropdown_item action-customer-change fs-12 fw-medium" data-id="0">
                                                    {{ translate('Walk-In-Customer') }}
                                                </div>
                                                @foreach ($customers as $customer)
                                                    <div class="custom_dropdown_item action-customer-change fs-12 fw-medium" data-id="{{ $customer->id }}">
                                                        {{ $customer->f_name }} {{ $customer->l_name }}
                                                        ({{ env('APP_MODE') != 'demo' ? $customer->phone : '+88017'.rand(111, 999).'XXXXX' }})
                                                    </div>
                                                @endforeach
                                            </div>
                                            <div class="bg-section p-5 rounded custom_dropdown_empty">
                                                <div class="d-flex justify-content-center align-items-center">{{ translate('No_customer_found') }}</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <input type="hidden" name="customer_id" id="customer_id" value="{{ $userId }}">
                            @include('vendor-views.pos.partials._cart-summary')
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade pt-5" id="quick-view" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content" id="quick-view-modal"></div>
        </div>
    </div>
    <button class="d-none" id="hold-orders-modal-btn" type="button" data-toggle="modal"
            data-target="#hold-orders-modal">
    </button>

    @if($order)
        @include('vendor-views.pos.partials.modals._print-invoice')
    @endif

    @include('vendor-views.pos.partials.modals._add-customer')
    @include('vendor-views.pos.partials.modals._hold-orders-modal')
    @include('vendor-views.pos.partials.modals._add-coupon-discount')
    @include('vendor-views.pos.partials.modals._add-discount')
    @include('vendor-views.pos.partials.modals._short-cut-keys')

    <span id="route-vendor-pos-new-cart-id" data-url="{{ route('vendor.pos.new-cart-id') }}"></span>
    <span id="route-vendor-pos-clear-cart-ids" data-url="{{ route('vendor.pos.clear-cart-ids') }}"></span>
    <span id="route-vendor-pos-view-hold-orders" data-url="{{ route('vendor.pos.view-hold-orders') }}"></span>
    <span id="route-vendor-products-search-product" data-url="{{ route('vendor.pos.search-product') }}"></span>
    <span id="route-vendor-pos-change-customer" data-url="{{ route('vendor.pos.change-customer') }}"></span>
    <span id="route-vendor-pos-update-discount" data-url="{{ route('vendor.pos.update-discount') }}"></span>
    <span id="route-vendor-pos-coupon-discount" data-url="{{ route('vendor.pos.coupon-discount') }}"></span>
    <span id="route-vendor-pos-cancel-order" data-url="{{ route('vendor.pos.cancel-order') }}"></span>
    <span id="route-vendor-pos-quick-view" data-url="{{ route('vendor.pos.quick-view') }}"></span>
    <span id="route-vendor-pos-add-to-cart" data-url="{{ route('vendor.pos.add-to-cart') }}"></span>
    <span id="route-vendor-pos-remove-cart" data-url="{{ route('vendor.pos.cart-remove') }}"></span>
    <span id="route-vendor-pos-empty-cart" data-url="{{ route('vendor.pos.cart-empty') }}"></span>
    <span id="route-vendor-pos-update-quantity" data-url="{{ route('vendor.pos.quantity-update') }}"></span>
    <span id="route-vendor-pos-get-variant-price" data-url="{{ route('vendor.pos.get-variant-price') }}"></span>
    <span id="route-vendor-pos-change-cart-editable" data-url="{{ route('vendor.pos.change-cart').'/?cart_id=:value' }}"></span>

    <span id="message-cart-word" data-text="{{ translate('cart') }}"></span>
    <span id="message-stock-out" data-text="{{ translate('stock_out') }}"></span>
    <span id="message-stock-id" data-text="{{ translate('in_stock') }}"></span>
    <span id="message-add-to-cart" data-text="{{ translate('add_to_cart') }}"></span>
    <span id="message-cart-updated" data-text="{{ translate('cart_updated') }}"></span>
    <span id="message-update-to-cart" data-text="{{ translate('update_to_cart') }}"></span>
    <span id="message-cart-is-empty" data-text="{{ translate('cart_is_empty') }}"></span>
    <span id="message-coupon-is-invalid" data-text="{{ translate('coupon_is_invalid') }}"></span>
    <span id="message-product-quantity-updated" data-text="{{ translate('product_quantity_updated') }}"></span>
    <span id="message-coupon-added-successfully" data-text="{{ translate('coupon_added_successfully') }}"></span>
    <span id="message-sorry-stock-limit-exceeded" data-text="{{ translate('sorry_stock_limit_exceeded') }}"></span>
    <span id="message-please-choose-all-the-options" data-text="{{ translate('please_choose_all_the_options') }}"></span>
    <span id="message-item-has-been-removed-from-cart" data-text="{{ translate('item_has_been_removed_from_cart') }}"></span>
    <span id="message-you-want-to-remove-all-items-from-cart" data-text="{{ translate('you_want_to_remove_all_items_from_cart') }}"></span>
    <span id="message-you-want-to-create-new-order" data-text="{{ translate('Want_to_create_new_order_for_another_customer') }}"></span>
    <span id="message-product-quantity-is-not-enough" data-text="{{ translate('product_quantity_is_not_enough') }}"></span>
    <span id="message-sorry-product-is-out-of-stock" data-text="{{ translate('sorry_product_is_out_of_stock') }}"></span>
    <span id="message-item-has-been-added-in-your-cart" data-text="{{ translate('item_has_been_added_in_your_cart') }}"></span>
    <span id="message-extra-discount-added-successfully" data-text="{{ translate('extra_discount_added_successfully') }}"></span>
    <span id="message-amount-can-not-be-negative-or-zero" data-text="{{ translate('amount_can_not_be_negative_or_zero') }}"></span>
    <span id="message-sorry-the-minimum-value-was-reached" data-text="{{ translate('sorry_the_minimum_value_was_reached') }}"></span>
    <span id="message-this-discount-is-not-applied-for-this-amount" data-text="{{ translate('this_discount_is_not_applied_for_this_amount') }}"></span>
    <span id="message-product-quantity-cannot-be-zero-in-cart" data-text="{{ translate('product_quantity_can_not_be_zero_or_less_than_zero_in_cart') }}"></span>
    <span id="message-enter-valid-amount" data-text="{{ translate('please_enter_a_valid_amount') }}"></span>
    <span id="message-less-than-total-amount" data-text="{{ translate('paid_amount_is_less_than_total_amount') }}"></span>
        <span id="message-product-quantity-cannot-be-less-then-one" data-text="{{ translate('product_quantity_can_not_be_less_then_one') }}"></span>

@endsection

@push('script_2')
    <script src="{{ dynamicAsset(path: 'public/assets/back-end/libs/printThis/printThis.js') }}"></script>
    <script src="{{ dynamicAsset(path: 'public/assets/back-end/js/vendor/pos-script.js') }}"></script>

    <script>
        "use strict";
        $(document).on('ready', function () {
            @if($order)
            $('#print-invoice').modal('show');
            @endif
        });
    </script>
@endpush
