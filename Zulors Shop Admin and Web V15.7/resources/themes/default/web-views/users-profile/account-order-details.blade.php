@extends('layouts.front-end.app')

@section('title', translate('order_Details'))

@section('content')
    <div class="container pb-5 mb-2 mb-md-4 mt-3 rtl __inline-47 text-align-direction">
        <div class="row g-3">
            @include('web-views.partials._profile-aside')

            <section class="col-lg-9">
                @include('web-views.users-profile.account-details.partial')
                <?php $digitalProduct = false;?>
                @foreach ($order->details as $key=>$detail)
                    @if(isset($detail->product->digital_product_type))
                        <?php
                            $digitalProduct = $detail->product->product_type === 'digital' ? true : false;
                        ?>
                        @if($digitalProduct === true)
                            @break
                        @else
                            @continue
                        @endif
                    @endif
                @endforeach
                <div class="bg-white cus-shadow rounded-10 mobile-full">
                    <div class="p-xxl-4 p-lg-3 p-0">
                        @if($order['payment_method'] == 'cash_on_delivery' && $order['bring_change_amount'] > 0)
                            <div class="__badge soft-primary py-2 px-xxl-4 px-3 fs-14 text-dark rounded mb-15px">
                                {{ translate('Please bring') }} <strong> {{ $order['bring_change_amount'] }} {{ $order['bring_change_amount_currency'] ?? '' }}</strong> {{ translate('in change when making the delivery') }}
                            </div>
                        @endif

                        @if($order['order_type'] === "POS")
                        <div class="p--20 mb-15px light-box rounded-8 d-flex align-items-center gap-2 justify-content-between flex-wrap">
                            <h6 class="m-0 fs-14 text-dark fw-semibold">{{ translate('Order info') }}</h6>
                            <div class="d-flex align-items-center flex-wrap order_info-top">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="m-0 fs-12 title-semidark lh-1">{{ translate('Order Type') }} :</span>
                                    <h6 class="m-0 fs-12 web-text-primary fw-semibold lh-1">{{ translate($order['order_type'] == "POS" ? "POS" : "Default" )}}</h6>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="m-0 fs-12 title-semidark lh-1">{{ translate('payment_status') }} :</span>
                                    <h6 class="m-0 fs-12 text-success fw-semibold lh-1">{{ $order['payment_status'] }}</h6>
                                </div>
                                <div class="d-flex align-items-center gap-2">
                                    <span class="m-0 fs-12 title-semidark lh-1">{{ translate('Payment method') }} :</span>
                                    <h6 class="m-0 fs-12 text-dark fw-semibold lh-1">{{ translate(str_replace('_',' ',$order['payment_method'])) }}</h6>
                                </div>
                            </div>
                        </div>
                        @endif
                            <?php
                                $showReorderBox = $order->order_status == 'delivered' ||
                                    ($order->order_type == 'default_type' && getWebConfig(name: 'order_verification'));
                            ?>
                            @if($order['order_type'] === "default_type")
                                <div class="row g-3 mb-2">
                                    <div class=" {{ !$showReorderBox ? 'col-md-12 col-sm-12' : 'col-md-6 col-sm-6' }}">
                                        <div class="light-box rounded-8 p--20 h-100">
                                            <div class="d-flex justify-content-between gap-2 flex-wrap align-items-center">
                                                <div class="">
                                                    <h6 class="fs-13 fw-semibold text-capitalize">{{translate('payment_info')}}</h6>
                                                </div>
                                                <div>
                                                    <div class="fs-12 d-flex justify-content-end gap-2">
                                                        <span class="text-muted text-capitalize">{{translate('Order_Type')}} :</span>
                                                        <span class="text-primary text-capitalize fw-semibold">{{  translate('default')  }}</span>
                                                    </div> <div class="fs-12 d-flex justify-content-end gap-2">
                                                        <span class="text-muted text-capitalize">{{translate('payment_status')}} :</span>
                                                        <span class="text-{{$order['payment_status'] == 'paid' ? 'success' : 'danger'}} text-capitalize fw-semibold">{{$order['payment_status']}}</span>
                                                    </div>
                                                    <div class="fs-12 d-flex justify-content-end gap-2">
                                                        <span class="text-muted text-capitalize">{{translate('payment_method')}} :</span>
                                                        <span class="text-dark text-capitalize fw-semibold">{{translate($order['payment_method'])}}</span>
                                                    </div>
                                                    @if($order->payment_method == 'offline_payment' && isset($order->offlinePayments))
                                                        <div class="fs-12 d-flex justify-content-end gap-2">
                                                            <button type="button"
                                                                class="btn bg--secondary border border-primary-light mt-3 rounded-pill btn-sm text-capitalize fs-10 font-semi-bold"
                                                                data-toggle="modal"
                                                                data-target="#verifyViewModal">
                                                                {{ translate('see_payment_details') }}
                                                            </button>
                                                        </div>
                                                    @endif
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    @if($showReorderBox)
                                        <div class="col-md-6 col-sm-6">
                                            <div class="d-flex justify-content-between align-items-center h-100 light-box rounded-8 p--20 gap-2 flex-wrap mb-3">
                                                @if($order->order_status == 'delivered')
                                                    <p class="m-0 fs-14 text-dark fw-semibold">
                                                        {{ translate('Want to order the same items again') }}?
                                                    </p>
                                                @endif
                                                <div>
                                                    @if($order->order_status != "delivered" && $order->order_type == 'default_type' && getWebConfig(name: 'order_verification'))
                                                        <div class="d-flex align-items-center w-100 justify-content-between gap-1">
                                                            <div class="fs-14 text-dark fw-semibold text-capitalize">
                                                                {{ translate('order_verification_code') }} :
                                                            </div>
                                                            <div>
                                                                <strong class="text-dark">{{ $order['verification_code'] }}</strong>
                                                            </div>
                                                        </div>
                                                    @endif
                                                    @if($order->order_type == 'POS')
                                                        <div>
                                                            <span class="pos-btn hover-none">{{ translate('POS_Order') }}</span>
                                                        </div>
                                                    @endif
                                                    @if($order->order_status == "delivered")
                                                        <div class="d-flex align-items-center gap-2">
                                                            <button
                                                                class="btn btn--primary btn-sm h-40px rounded text_capitalize get-order-again-function"
                                                                data-id="{{ $order->id }}">
                                                                {{ translate('reorder') }}
                                                            </button>
                                                        </div>
                                                    @endif
                                                </div>
                                            </div>
                                        </div>
                                    @endif
                                    @if( $order->order_type == 'default_type')
                                        @php($shippingAddressShow = 0)
                                        @foreach($order->details as $details)
                                            @if(isset($details->product_details) && isset(json_decode($details->product_details)?->product_type) && json_decode($details->product_details)?->product_type == "physical")
                                                @php($shippingAddressShow = 1)
                                            @endif
                                        @endforeach
                                            <?php
                                            $shipping = isset($order->shipping_address_data)
                                                ? (is_string($order->shipping_address_data)
                                                    ? json_decode($order->shipping_address_data)
                                                    : $order->shipping_address_data)
                                                : null;

                                            $billing = isset($order->billing_address_data)
                                                ? (is_string($order->billing_address_data)
                                                    ? json_decode($order->billing_address_data)
                                                    : $order->billing_address_data)
                                                : null;

                                            $hasShipping = $shipping && $shippingAddressShow;
                                            $hasBilling = $billing;
                                            $colClass = ($hasShipping && $hasBilling) ? 'col-md-6 col-sm-6' : 'col-md-12 col-sm-12';
                                            ?>

                                        @php($shipping=$order['shipping_address_data'])
                                        @if($hasShipping)
                                            <div class="{{ $colClass }}">
                                                <div class="light-box rounded-8 p--20 h-100">
                                                    <div class="pb-1">
                                                        <h6 class="fs-13 fw-semibold text-capitalize">
                                                            {{ translate('shipping_address') }}:
                                                        </h6>
                                                    </div>
                                                    <div class="text-capitalize fs-12">
                                                        <span class="min-w-60px title-semidark">{{ translate('name') }}</span> : {{ $shipping->contact_person_name }}<br>
                                                        <span class="min-w-60px title-semidark">{{ translate('phone') }}</span> : {{ $shipping->phone }}<br>
                                                        <span class="min-w-60px title-semidark">{{ translate('city') }} / {{ translate('zip') }}</span> :
                                                        {{ $shipping->city }}, {{ $shipping->zip }}<br>
                                                        <span class="min-w-60px title-semidark">{{ translate('address') }}</span> :
                                                        {{ $shipping->address }}
                                                    </div>
                                                </div>
                                            </div>
                                        @endif
                                        @if($hasBilling)
                                            <div class="{{ $colClass }}">
                                                <div class="light-box rounded-8 p--20 h-100">
                                                    <div class="pb-1">
                                                        <h6 class="fs-13 fw-semibold text-capitalize">
                                                            {{ translate('billing_address') }}:
                                                        </h6>
                                                    </div>

                                                    <?php
                                                        $isSameAddress = $billing && $shipping &&
                                                            ($billing->address == $shipping->address) &&
                                                            ($billing->city == $shipping->city) &&
                                                            ($billing->zip == $shipping->zip);
                                                    ?>
                                                    @if($isSameAddress)
                                                        <div class="bg-white card">
                                                            <div class="d-center py-5 px-4">
                                                                <p class="fs-14 m-0">{{ translate('Same as shipping address') }}</p>
                                                            </div>
                                                        </div>
                                                    @else
                                                        <div class="text-capitalize fs-12">
                                                            <span class="min-w-60px title-semidark">{{ translate('name') }}</span> :
                                                            {{ $billing->contact_person_name }}<br>
                                                            <span class="min-w-60px title-semidark">{{ translate('phone') }}</span> :
                                                            {{ $billing->phone }}<br>
                                                            <span class="min-w-60px title-semidark">{{ translate('city') }} / {{ translate('zip') }}</span> :
                                                            {{ $billing->city }}, {{ $billing->zip }}<br>
                                                            <span class="min-w-60px title-semidark">{{ translate('address') }}</span> :
                                                            {{ $billing->address }}
                                                        </div>
                                                    @endif
                                                </div>
                                            </div>
                                        @endif
                                    @endif
                                </div>
                            @endif
                                <div class="border overflow-hidden rounded-10 mb-3">
                                    <div class="payment table-responsive d-nones d-lg-block">
                                        <table class="table table-border min-width-600px">
                                            <thead class="thead-light text-capitalize">
                                            <tr class="fs-13 font-semi-bold">
                                                <th class="fw-semibold fs-14 text-nowrap ">{{translate('Sl')}}</th>
                                                <th class="fw-semibold fs-14 text-nowrap ">{{translate('Item List')}}</th>
                                                <th class="fw-semibold fs-14 text-nowrap text-center">{{translate('qty')}}</th>
                                                <th class="fw-semibold fs-14 text-nowrap text-right">{{translate('price')}}</th>
                                                <th class="fw-semibold fs-14 text-nowrap text-right">{{translate('discount')}}</th>
                                                <th class="fw-semibold fs-14 text-nowrap text-right">{{translate('Total')}}</th>
                                                <th class="fw-semibold fs-14 text-nowrap text-center">{{translate('Action')}}</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <?php $orderDetailsIndex = 1;?>
                                            @foreach ($order->details as $key => $detail)
                                                @php($product = $detail?->productAllStatus ?? json_decode($detail->product_details, true))
                                                @if($product)
                                                    <tr>
                                                        <td class="align-middle">
                                                            {{ $orderDetailsIndex }}
                                                        </td>
                                                        <td class="for-tab-img">
                                                            <div class="media gap-3 min-w-200 align-items-center">
                                                                <div class="position-relative border h-70 w-60 min-w-60px rounded overflow-hidden">
                                                                    @if(getProductPriceByType(product: $product, type: 'discount', result: 'value') > 0)
                                                                        <span class="for-discount-value px-1 mx-1 fs-10 text-wrap overflow-wrap-anywhere direction-ltr">
                                                                            -{{ getProductPriceByType(product: $product, type: 'discount', result: 'string') }}
                                                                        </span>
                                                                    @endif
                                                                    <img class="d-block w-100 h-100 get-view-by-onclick"
                                                                         data-link="{{ route('product',$product['slug']) }}"
                                                                         src="{{ getStorageImages(path: $detail?->productAllStatus?->thumbnail_full_url, type: 'product') }}"
                                                                         alt="{{ translate('product') }}">
                                                                </div>

                                                                <div class="media-body">
                                                                    <a href="{{route('product',[$product['slug']])}}" class="fs-14 font-semi-bold mb-2 line--limit-2 max-w-200px">
                                                                        {{isset($product['name']) ? Str::limit($product['name'], 60) : ''}}
                                                                    </a>
                                                                    <div class="fs-12 text-capitalize mb-1">
                                                                        {{ translate('unit_price_:') }}
                                                                        {{ webCurrencyConverter($detail->price) }}
                                                                    </div>
                                                                    @if($detail->refund_request == 1)
                                                                        <small> ({{translate('refund_pending')}}) </small>
                                                                        <br>
                                                                    @elseif($detail->refund_request == 2)
                                                                        <small> ({{translate('refund_approved')}}) </small>
                                                                        <br>
                                                                    @elseif($detail->refund_request == 3)
                                                                        <small> ({{translate('refund_rejected')}}) </small>
                                                                        <br>
                                                                    @elseif($detail->refund_request == 4)
                                                                        <small> ({{translate('refund_refunded')}}) </small>
                                                                        <br>
                                                                    @endif

                                                                    @if($detail->variant)
                                                                        <small class="fs-12 text-secondary-50">
                                                                            <span class="font-bold">{{translate('variant')}} : </span>
                                                                            <span class="font-semi-bold">{{$detail->variant}}</span>
                                                                        </small>
                                                                    @endif

                                                                    <div class="d-flex flex-wrap gap-2 mt-2">
                                                                        <?php
                                                                            $refund_day_limit = getWebConfig(name: 'refund_day_limit');
                                                                            $current = \Carbon\Carbon::now();
                                                                            $length = $detail?->refund_started_at?->diffInDays($current);
                                                                        ?>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td class="align-middle">
                                                            <div class="pl-2">
                                                                <span class="word-nobreak">
                                                                    {{$detail->qty}}
                                                                </span>
                                                            </div>
                                                        </td>
                                                        <td class="text-right align-middle">
                                                            <span class="fw-semibold amount text-nowrap">
                                                                {{webCurrencyConverter($detail->price * $detail->qty)}}
                                                            </span>
                                                        </td>
                                                        <td class="text-right align-middle">
                                                            <span class="fw-semibold amount text-nowrap">
                                                                {{webCurrencyConverter($detail->discount)}}
                                                            </span>
                                                        </td>
                                                        <td class="text-right align-middle">
                                                            <span class="fw-semibold amount text-nowrap">
                                                                {{webCurrencyConverter(($detail->qty*$detail->price)-$detail->discount)}}
                                                            </span>
                                                        </td>
                                                        <td class="align-middle">
                                                            @if(
                                                              ($order->order_type == 'default_type' && ($order->order_status=='delivered' || (isset($digitalProduct) && ($order->payment_status == 'paid' && $digitalProduct)))) ||
                                                              ($order->order_type != 'default_type' && $order->order_status=='delivered')
                                                          )
                                                            <div class="d-flex align-items-center justify-content-center text-center gap-2">
                                                                @if($order->order_type == 'default_type' && $order->order_status=='delivered')
                                                                @if (isset($detail->product))
                                                                    <button type="button"
                                                                            class="btn web-text-primary p-0 m-0 fs-14"
                                                                            data-toggle="modal"
                                                                            data-target="#submitReviewModal{{$detail->id}}">
                                                                        @if (isset($detail->reviewData))
                                                                            {{translate('Update_Review')}}
                                                                        @else
                                                                            {{translate('Give Review')}}
                                                                        @endif
                                                                    </button>
                                                                @endif
                                                                @endif
                                                                @if($product && $order->payment_status == 'paid' && isset($product['digital_product_type']) && $product['digital_product_type'] == 'ready_product')
                                                                        <a href="javascript:" class="btn __badge h-30 py-1 px-2 rounded soft-primary action-digital-product-download"
                                                                                data-link="{{ route('digital-product-download', $detail->id) }}">
                                                                            <i class="fi fi-rr-download fs-12"></i>
                                                                        </a>
                                                                @elseif($product && $order->payment_status == 'paid' && isset($product['digital_product_type']) && $product['digital_product_type'] == 'ready_after_sell')
                                                                    @if($detail->digital_file_after_sell)
                                                                        <a href="javascript:"
                                                                           data-link="{{ route('digital-product-download', $detail->id) }}"
                                                                           class="btn __badge h-30 py-1 px-2 rounded soft-primary"
                                                                           data-toggle="tooltip"
                                                                           data-placement="top"
                                                                           data-bs-custom-class="custom-tooltip"
                                                                           data-title="Download"
                                                                           download>
                                                                            <i class="fi fi-rr-download fs-12"></i>
                                                                        </a>
                                                                    @else
                                                                        <a href="javascript:"
                                                                           class="btn __badge h-30 py-1 px-2 rounded soft-primary"
                                                                           data-placement="top" data-bs-custom-class="custom-tooltip" title="Admin hasn’t uploaded it yet"
                                                                           >
                                                                            <i class="fi fi-rr-download fs-12"></i>
                                                                        </a>
                                                                    @endif
                                                                @endif

                                                            </div>
                                                            @else
                                                                <div class="text-center text-muted">--</div>
                                                            @endif
                                                        </td>
                                                    </tr>
                                                    <?php $orderDetailsIndex++;?>
                                                @endif
                                            @endforeach

                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                        @php($orderTotalPriceSummary = \App\Utils\OrderManager::getOrderTotalPriceSummary(order: $order))
                        <div class="row d-flex justify-content-end mt-2">
                            <div class="col-md-8 col-lg-5">
                                <div class="bg-white border rounded">
                                    <div class="card-body p-2">
                                        <table class="calculation-table table table-borderless mb-0">
                                            <tbody class="totals">
                                            <tr>
                                                <td>
                                                    <div class="text-start">
                                                        <span class="product-qty title-semidark">{{translate('Total_Item')}}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="fs-15">
                                                            {{ $orderTotalPriceSummary['totalItemQuantity'] }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div class="text-start">
                                                        <span class="product-qty title-semidark">{{translate('item_price')}}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="fs-15">
                                                            {{ webCurrencyConverter(amount: $orderTotalPriceSummary['itemPrice']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <div class="text-start">
                                                        <span class="product-qty title-semidark">{{translate('item_discount')}}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="fs-15">
                                                            {{ webCurrencyConverter(amount: $orderTotalPriceSummary['itemDiscount']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>

                                            @if($order->order_type != 'default_type')
                                                <tr>
                                                    <td>
                                                        <div class="text-start">
                                                            <span class="product-qty title-semidark">
                                                                {{translate('extra_discount')}}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="text-end">
                                                            <span class="fs-15">
                                                                - {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['extraDiscount']) }}
                                                            </span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endif

                                            <tr>
                                                <td>
                                                    <div class="text-start">
                                                        <span class="product-qty title-semidark">{{translate('subtotal')}}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="fs-15">
                                                            {{ webCurrencyConverter(amount: $orderTotalPriceSummary['subTotal']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <div class="text-start">
                                                        <span class="product-qty title-semidark">
                                                            {{translate('coupon_discount')}}
                                                        </span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="fs-15">
                                                            - {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['couponDiscount']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>

                                            @if($orderTotalPriceSummary['referAndEarnDiscount'] > 0)
                                                <tr>
                                                    <td>
                                                        <div class="text-start">
                                                        <span class="product-qty title-semidark">
                                                            {{ translate('referral_discount') }}
                                                        </span>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="text-end">
                                                        <span class="fs-15">
                                                            - {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['referAndEarnDiscount']) }}
                                                        </span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endif

                                            <tr>
                                                <td>
                                                    <div class="text-start">
                                                        <span class="product-qty title-semidark">
                                                            {{translate('tax_fee')}}
                                                        </span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="fs-15">
                                                            {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['taxTotal']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>

                                            @if($order->order_type == 'default_type' && $order?->is_shipping_free == 0)
                                                <tr>
                                                    <td>
                                                        <div class="text-start">
                                                            <span class="product-qty title-semidark">
                                                                {{translate('shipping_Fee')}}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="text-end">
                                                            <span class="fs-15 ">
                                                                {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['shippingTotal']) }}
                                                            </span>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endif

                                            <tr class="border-top">
                                                <td>
                                                    <div class="text-start">
                                                        <span class="font-weight-bold">
                                                            <strong>{{translate('total')}}</strong>
                                                            <span class="fs-10 fw-medium">
                                                                {{ $orderTotalPriceSummary['tax_model'] == 'include' ? '('.translate('Tax_:_Inc.').')' : '' }}
                                                            </span>
                                                        </span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="font-weight-bold amount">
                                                            {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['totalAmount']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                            @if ($order->order_type == 'POS' || $order->order_type == 'pos')
                                                <tr class="border-top">
                                                    <td>
                                                        <div class="text-start">
                                                            <span class="font-weight-bold">
                                                                <strong>{{translate('paid_amount')}}</strong>
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="text-end">
                                                            <span class="font-weight-bold amount">
                                                                {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['paidAmount']) }}
                                                            </span>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr class="">
                                                <td>
                                                    <div class="text-start">
                                                        <span class="font-weight-bold">
                                                            <strong>{{translate('change_amount')}}</strong>
                                                        </span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="text-end">
                                                        <span class="font-weight-bold amount">
                                                            {{ webCurrencyConverter(amount:  $orderTotalPriceSummary['changeAmount']) }}
                                                        </span>
                                                    </div>
                                                </td>
                                            </tr>
                                            @endif
                                            </tbody>
                                        </table>

                                        @if ($order['order_status']=='pending')
                                            <button class="btn btn-soft-danger btn-soft-border w-100 btn-sm text-danger font-semi-bold text-capitalize mt-3 call-route-alert"
                                                    data-route="{{ route('order-cancel',[$order->id]) }}"
                                                    data-message="{{translate('want_to_cancel_this_order?')}}">
                                                {{translate('cancel_order')}}
                                            </button>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    </div>



    @if($order->order_status=='delivered')
        <div class="bottom-sticky_offset"></div>
        <div class="bottom-sticky_ele bg-white d-md-none p-3 ">
            <button class="btn btn--primary w-100 text_capitalize get-order-again-function" data-id="{{ $order->id }}">
                {{ translate('reorder') }}
            </button>
        </div>
    @endif

    @if($order->payment_method == 'offline_payment' && isset($order->offlinePayments))
        <div class="modal fade" id="verifyViewModal" tabindex="-1" aria-labelledby="verifyViewModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content rtl">
                    <div class="modal-header d-flex justify-content-end  border-0 pb-0">
                        <button type="button" class="close pe-0" data-dismiss="modal">
                            <span aria-hidden="true" class="tio-clear"></span>
                        </button>
                    </div>

                    <div class="modal-body pt-0">
                        <h5 class="mb-3 text-center text-capitalize fs-16 font-semi-bold">
                            {{ translate('payment_verification') }}
                        </h5>

                        <div class="shadow-sm rounded p-3">
                            <h6 class="mb-3 text-capitalize fs-16 font-semi-bold">
                                {{translate('customer_information')}}
                            </h6>

                            <div class="d-flex flex-column gap-2 fs-12 mb-4">
                                <div class="d-flex align-items-center gap-2">
                                    <span class=" min-w-120">{{translate('name')}}</span>
                                    <span>:</span>
                                    <span class="text-dark">
                                        <a class="font-weight-medium fs-12 text-capitalize" href="Javascript:">
                                            {{$order->customer->f_name ?? translate('name_not_found') }}&nbsp;{{$order->customer->l_name ?? ''}}
                                        </a>
                                    </span>
                                </div>

                                <div class="d-flex align-items-center gap-2">
                                    <span class=" min-w-120">{{translate('phone')}}</span>
                                    <span>:</span>
                                    <span class="text-dark">
                                        <a class="font-weight-medium fs-12 text-capitalize" href="{{ $order?->customer?->phone ? 'tel:'.$order?->customer?->phone : 'javascript:' }}">
                                            {{ $order->customer->phone ?? translate('number_not_found') }}
                                        </a>
                                    </span>
                                </div>
                            </div>

                            <div class="mt-3 border-top pt-4">
                                <h6 class="mb-3 text-capitalize fs-16 font-semi-bold">
                                    {{ translate('payment_information') }}
                                </h6>

                                <div class="d-flex flex-column gap-2 fs-12">

                                    @foreach ($order->offlinePayments->payment_info as $key=>$value)
                                        @if ($key != 'method_id')
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="text-capitalize min-w-120">{{translate($key)}}</span>
                                                <span>:</span>
                                                <span class="font-weight-medium fs-12 ">
                                                    {{$value ?? "N/a"}}
                                                </span>
                                            </div>
                                        @endif
                                    @endforeach

                                    @if($order->payment_note)
                                        <div class="d-flex align-items-start gap-2">
                                            <span class="text-capitalize min-w-120">{{ translate('payment_none') }}</span>
                                            <span>:</span>
                                            <span class="font-weight-medium fs-12 "> {{ $order->payment_note }}  </span>
                                        </div>
                                    @endif

                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    @endif


    <span id="message-ratingContent"
          data-poor="{{ translate('poor') }}"
          data-average="{{ translate('average') }}"
          data-good="{{ translate('good') }}"
          data-good-message="{{ translate('the_delivery_service_is_good') }}"
          data-good2="{{ translate('very_Good') }}"
          data-good2-message="{{ translate('this_delivery_service_is_very_good_I_am_highly_impressed') }}"
          data-excellent="{{ translate('excellent') }}"
          data-excellent-message="{{ translate('best_delivery_service_highly_recommended') }}"
    ></span>
@endsection


@push('script')
    <script src="{{ theme_asset(path: 'public/assets/front-end/js/spartan-multi-image-picker.js') }}"></script>
@endpush
