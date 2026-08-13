@php
 use App\Models\OrderDetail;
 use App\Utils\Helpers;
 use App\Utils\ProductManager;
 use function App\Utils\order_status_history;
@endphp
@extends('theme-views.layouts.app')

@section('title', translate('Track_Order_Result ').' | '.$web_config['company_name'].' '.translate('ecommerce'))

@section('content')
    <main class="main-content d-flex flex-column gap-3 py-3 mb-4">
        <div class="container">
            <div class="card h-100">
                <div class="card-body py-4 px-sm-4">
                    <div class=" px-xxl-2 pt-xxl-2">
                        <a href="{{ route('track-order.index') }}" class="d-flex align-items-center mb-4 fs-18 gap-2 text-primary">
                            <i class="bi bi-chevron-left fs-16"></i> {{ translate('Back') }}
                        </a>
                        <div class="d-flex flex-wrap align-items-center justify-content-between gap-md-3 gap-2 mb-4">
                            <div class="flex-grow-1">
                                <h5 class="mb-1 fs-16">{{translate('Order')}} #{{$orderDetails['id']}} </h5>
                                <p class="fs-14">{{date('d M, Y h:i A',strtotime($orderDetails->created_at))}}</p>
                            </div>
                            <div class="d-flex flex-column gap-2">
                                <div class="d-flex gap-3 align-items-center mt-1">
                                    <p class="text-capitalize m-0 fs-14 fw-medium">{{ translate('Order status') }} :</p>
                                    @if($orderDetails['order_status']=='failed' || $orderDetails['order_status']=='canceled')
                                        <span class="text-center badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
                                        {{translate($orderDetails['order_status'] =='failed' ? 'failed_to_deliver' : $orderDetails['order_status'])}}
                                    </span>
                                    @elseif($orderDetails['order_status']=='confirmed' || $orderDetails['order_status']=='processing' || $orderDetails['order_status']=='delivered')
                                        <span class="text-center badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
                                         {{translate($orderDetails['order_status']=='processing' ? 'packaging' : $orderDetails['order_status'])}}
                                    </span>
                                    @else
                                        <span class="text-center badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
                                          {{translate($orderDetails['order_status'])}}
                                    </span>
                                    @endif
                                </div>
                                <div class="d-flex gap-3 align-items-center mt-1">
                                    <p class="text-capitalize m-0 fs-14 fw-medium">{{ translate('Payment status') }} :</p>
                                    @if($orderDetails['payment_status']=="paid")
                                        <span class="text-center badge text-danger border-danger-1 text-bg-danger rounded-1 fw-normal fs-12 bg-opacity-10">
                                        {{ translate('paid') }}
                                    </span>
                                    @else
                                        <span class="text-center badge text-danger border-danger-1 text-bg-danger rounded-1 fw-normal fs-12 bg-opacity-10">
                                        {{ translate('unpaid') }}
                                    </span>
                                    @endif
                                </div>
                            </div>
                        </div>

                        <?php
                            $trackOrderArray = \App\Utils\OrderManager::getTrackOrderStatusHistory(
                                orderId: $orderDetails['id'],
                                isOrderOnlyDigital: $isOrderOnlyDigital
                            );

                            $statusIcons = [
                                'order_placed' => 'track-shopping-list.svg',
                                'order_confirmed' => 'track2.svg',
                                'preparing_for_shipment' => 'track3.svg',
                                'order_is_on_the_way' => 'track4.svg',
                                'order_delivered' => 'track8.svg',
                                'order_canceled' => null,
                                'order_returned' => null,
                                'order_failed' => null,
                            ];

                            $terminalStatuses = ['order_canceled', 'order_returned', 'order_failed'];
                            $activeTerminalStatus = null;

                            foreach ($terminalStatuses as $terminalStatus) {
                                if (isset($trackOrderArray['history'][$terminalStatus]) && $trackOrderArray['history'][$terminalStatus]['status']) {
                                    $activeTerminalStatus = $terminalStatus;
                                    break;
                                }
                            }

                            if ($trackOrderArray['is_digital_order']) {
                                $statusesToShow = ['order_placed', 'order_confirmed', 'order_delivered'];
                            } else {
                                $statusesToShow = ['order_placed', 'order_confirmed', 'preparing_for_shipment', 'order_is_on_the_way', 'order_delivered'];
                            }

                            if ($activeTerminalStatus) {
                                $statusesToShow[] = $activeTerminalStatus;
                            }
                        ?>

                        <div class="card py-2">
                            <div class="card-body p-4 ps-3">
                                <div class="traking-slide-wrap style-main">
                                    <ul class="traking-slide-nav nav d-flex flex-nowrap text-nowrap">
                                        @foreach($trackOrderArray['history'] as $statusKey => $statusData)
                                            @continue(!in_array($statusKey, $statusesToShow))

                                            <?php $isTerminalStatus = in_array($statusKey, $terminalStatuses); ?>

                                            <li class="traking-item {{ $statusData['status'] ? 'active' : '' }} text-center mx-auto w-240 position-relative z-1">
                                                <div class="state-img d-center rounded-10 w-40 h-40 section-bg-cmn2 mb-15 mx-auto">
                                                    @if($isTerminalStatus)
                                                        <i class="bi bi-x-circle-fill fs-20"></i>
                                                    @else
                                                        <img width="20" class="svg" src="{{ theme_asset('assets/img/icons/' . $statusIcons[$statusKey]) }}" alt="icon">
                                                    @endif
                                                </div>

                                                <div class="badge-check mb-15">
                                                    @if($isTerminalStatus)
                                                        <i class="bi bi-x-circle-fill fs-16"></i>
                                                    @else
                                                        <i class="bi bi-check-circle-fill fs-16"></i>
                                                    @endif
                                                </div>

                                                <div class="contents">
                                                    <h6 class="{{ $statusData['status'] ? 'text-dark' : 'text-muted' }} mb-1 fs-14">
                                                        {{ translate($statusData['label']) }}
                                                    </h6>

                                                    @if($statusData['date_time'])
                                                        <p class="fs-12 m-0">
                                                            {{ $statusData['date_time']->format('h:i A, d M Y') }}
                                                        </p>
                                                    @endif

                                                    @if($statusKey === 'order_is_on_the_way' && $statusData['status'] && !$trackOrderArray['is_digital_order'])
                                                        <p class="fs-12 mb-0 mt-1">{{ translate('Your deliveryman is coming') }}</p>
                                                    @endif

                                                    @if($isTerminalStatus && $statusData['status'])
                                                        <a href="#0" class="fs-12 text-primary mb-0 mt-1">
                                                            @if($statusKey === 'order_canceled')
                                                                {{ translate('Order has been canceled') }}
                                                            @elseif($statusKey === 'order_returned')
                                                                {{ translate('Order has been returned') }}
                                                            @elseif($statusKey === 'order_failed')
                                                                {{ translate('Order processing failed') }}
                                                            @endif
                                                        </a>
                                                    @endif
                                                </div>
                                            </li>
                                        @endforeach
                                    </ul>

                                    <div class="arrow-area">
                                        <div class="button-prev align-items-center">
                                            <button type="button"
                                                    class="btn btn-click-prev mr-auto border-0 btn-primary rounded-circle p-2 d-center">
                                                <i class="bi bi-chevron-left fs-14 lh-1"></i>
                                            </button>
                                        </div>
                                        <div class="button-next align-items-center">
                                            <button type="button"
                                                    class="btn btn-click-next ms-auto border-0 btn-primary rounded-circle p-2 d-center">
                                                <i class="bi bi-chevron-right fs-14 lh-1"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="text-center mt-4 pb-2">
                            <h4 class="text-center fs-18 text-uppercase mb-20">{{ translate('your_order') }}
                                #{{ $orderDetails['id'] }} {{ translate('is') }}
                                @if($orderDetails['order_status']=='failed' || $orderDetails['order_status']=='canceled')
                                    {{translate($orderDetails['order_status'] =='failed' ? 'Failed To Deliver' : $orderDetails['order_status'])}}
                                @elseif($orderDetails['order_status']=='confirmed' || $orderDetails['order_status']=='processing' || $orderDetails['order_status']=='delivered')
                                    {{translate($orderDetails['order_status']=='processing' ? 'packaging' : $orderDetails['order_status'])}}
                                @else
                                    {{translate($orderDetails['order_status'])}}
                                @endif
                            </h4>
                            <button class="btn btn-primary mx-auto" data-bs-toggle="modal"
                                    data-bs-target="#order_details">
                                <span
                                    class="media-body text-nowrap">{{translate('view_order_details')}}</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        @php($order = OrderDetail::where('order_id', $orderDetails->id)->get())
        <div class="modal fade" id="order_details" tabindex="-1" aria-labelledby="order_details" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header align-items-start mx-3 border-0">
                        <div class="d-flex w-100 flex-wrap me-4 align-items-center justify-content-between gap-md-3 gap-2 mb-4">
                            <div class="flex-grow-1">
                                <div>
                                    <h6 class="modal-title fs-5" id="reviewModalLabel">{{translate('order')}}
                                        #{{ $orderDetails['id']  }}</h6>

                                    @if ($order_verification_status && $orderDetails->order_type == "default_type")
                                        <h5 class="small">{{translate('verification_code')}}
                                            : {{ $orderDetails['verification_code'] }}</h5>
                                    @endif
                                </div>
                                <p class="fs-14">{{date('D, d M, Y ',strtotime($orderDetails['created_at']))}}</p>
                            </div>
                            <div class="d-flex flex-column gap-2">
                                <div class="d-flex gap-3 align-items-center mt-1">
                                    <p class="text-capitalize m-0 fs-14 fw-medium">{{ translate('Order status') }} :</p>
                                    @if($orderDetails['order_status']=='failed' || $orderDetails['order_status']=='canceled')
                                        <span class="text-center badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
                                        {{translate($orderDetails['order_status'] =='failed' ? 'failed_to_deliver' : $orderDetails['order_status'])}}
                                    </span>
                                    @elseif($orderDetails['order_status']=='confirmed' || $orderDetails['order_status']=='processing' || $orderDetails['order_status']=='delivered')
                                        <span class="text-center badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
                                         {{translate($orderDetails['order_status']=='processing' ? 'packaging' : $orderDetails['order_status'])}}
                                    </span>
                                    @else
                                        <span class="text-center badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
                                          {{translate($orderDetails['order_status'])}}
                                    </span>
                                        @endif
                                </div>
                                <div class="d-flex gap-3 align-items-center mt-1">
                                    <p class="text-capitalize m-0 fs-14 fw-medium">{{ translate('Payment status') }} :</p>
                                    @if($orderDetails['payment_status']=="paid")
                                    <span class="text-center badge text-danger border-danger-1 text-bg-danger rounded-1 fw-normal fs-12 bg-opacity-10">
                                        {{ translate('paid') }}
                                    </span>
                                    @else
                                        <span class="text-center badge text-danger border-danger-1 text-bg-danger rounded-1 fw-normal fs-12 bg-opacity-10">
                                        {{ translate('unpaid') }}
                                    </span>
                                    @endif
                                </div>
                            </div>
                        </div>
                        <button class="close-custom-btn btn d-center border-0 fs-16 p-1 w-30 h-30 rounded-pill position-absolute top-0 end-0 m-2" type="button" data-bs-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                    </div>
                    <div class="modal-body pt-0 px-sm-4">
                        <div class="product-table-wrap rounded-2 overflow-hidden mb-20 border">
                            <div class="table-responsive">
                                <table class="table table-border m-0 text-capitalize text-start align-middle">
                                    <thead class="mb-3">
                                    <tr>
                                        <th class="min-w-300 section-bg-cmn2 text-nowrap">{{translate('product_details')}}</th>
                                        <th class="text-nowrap section-bg-cmn2">{{translate('QTY')}}</th>
                                        <th class="text-end text-nowrap section-bg-cmn2">{{translate('sub_total')}}</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    @php($sub_total=0)
                                    @php($total_shipping_cost=0)
                                    @php($total_discount_on_product=0)
                                    @php($extra_discount=0)
                                    @php($coupon_discount=0)
                                    @foreach($order as $key => $orderDetail)
                                        @php($productDetails = $orderDetails?->product ?? json_decode($orderDetail->product_details) )
                                        <tr>
                                            <td>
                                                <div class="media align-items-center gap-3">
                                                    <img class="rounded border" alt="{{ translate('product') }}"
                                                         src="{{ getStorageImages(path: $orderDetail?->productAllStatus?->thumbnail_full_url, type: 'product') }}"
                                                         width="100px">
                                                    <div class="get-view-by-onclick" data-link="{{route('product',$productDetails->slug)}}">
                                                        <a href="{{route('product',$productDetails->slug)}}">
                                                            <h6 class="title-color mb-2">{{Str::limit($productDetails->name,30)}}</h6>
                                                        </a>
                                                        <div class="d-flex flex-column">
                                                            <small>
                                                                <strong>{{translate('unit_price')}} :</strong>
                                                                {{ webCurrencyConverter($orderDetail['price']) }}
                                                            </small>
                                                            @if ($orderDetail->variant)
                                                                <small><strong>{{translate('variation')}}
                                                                        :</strong> {{$orderDetail['variant']}}</small>
                                                            @endif
                                                        </div>
                                                    </div>
                                                    <span class="d-none get-digital-product-download-url" data-action="{{ route('digital-product-download', $orderDetail->id) }}"></span>
                                                    @if($orderDetails->payment_status == 'paid' && $productDetails->digital_product_type == 'ready_product')
                                                        <a  href="javascript:"
                                                           class="btn btn-primary btn-sm rounded-pill mb-1 digital-product-download"
                                                           data-bs-toggle="tooltip"
                                                           data-bs-placement="bottom"
                                                           data-bs-title="{{translate('download')}}">
                                                            <i class="bi bi-download"></i>
                                                        </a>
                                                    @elseif($orderDetails->payment_status == 'paid' && $productDetails->digital_product_type == 'ready_after_sell')
                                                        @if($orderDetail->digital_file_after_sell)
                                                            <a  href="javascript:"
                                                               class="btn btn-primary btn-sm rounded-pill mb-1 digital-product-download"
                                                               data-bs-toggle="tooltip"
                                                               data-bs-placement="bottom"
                                                               data-bs-title="{{translate('download')}}">
                                                                <i class="bi bi-download"></i>
                                                            </a>
                                                        @else
                                                            <span class="btn btn-success btn-sm mb-1 opacity-half cursor-auto" data-bs-toggle="tooltip" data-bs-placement="bottom"
                                                                data-bs-title="{{translate('product_not_uploaded_yet')}}">
                                                                <i class="bi bi-download"></i>
                                                            </span>
                                                        @endif
                                                    @endif
                                                </div>
                                            </td>
                                            <td>
                                                {{$orderDetail->qty}}
                                            </td>
                                            <td class="text-end">
                                                {{webCurrencyConverter($orderDetail['price']*$orderDetail['qty'])}}
                                            </td>
                                        </tr>
                                        @php($sub_total+=$orderDetail['price']*$orderDetail['qty'])
                                        @php($total_discount_on_product+=$orderDetail['discount'])
                                    @endforeach
                                    </tbody>

                                </table>

                            </div>
                        </div>
                        @php($total_shipping_cost=$orderDetails['shipping_cost'])
                        <?php
                        if ($orderDetails['extra_discount_type'] == 'percent') {
                            $extra_discount = ($sub_total / 100) * $orderDetails['extra_discount'];
                        } else {
                            $extra_discount = $orderDetails['extra_discount'];
                        }
                        if (isset($orderDetails['discount_amount'])) {
                            $coupon_discount = $orderDetails['discount_amount'];
                        }
                        ?>
                        <div class="bg-light rounded border p3 mb-2">
                            <div class="table-responsive">
                                <table class="table __table table-borderless m-0 table-align-middle text-capitalize">
                                    <thead>
                                    <tr>
                                        <th class="text-dark text-nowrap fw-normal">{{translate('sub_total')}}</th>
                                        @if ($orderDetails['order_type'] == 'default_type')
                                            <th class="text-dark text-nowrap fw-normal">{{translate('shipping')}}</th>
                                        @endif
                                        @if($orderDetails['tax_model'] == 'exclude')
                                            <th class="text-dark text-nowrap fw-normal">{{ translate('tax') }}</th>
                                        @endif
                                        <th class="text-dark text-nowrap fw-normal">{{translate('discount')}}</th>
                                        <th class="text-dark text-nowrap fw-normal">{{translate('coupon_discount')}}</th>
                                        @if ($orderDetails['order_type'] == 'POS')
                                            <th class="text-dark text-nowrap fw-normal">{{translate('extra_discount')}}</th>
                                        @endif
                                        <th class="text-dark text-nowrap fw-normal">{{translate('total')}}
                                            @if ($orderDetails->tax_model =='include')
                                                <small> ({{translate('tax_incl.')}})</small>
                                            @endif
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr>
                                        <td class="text-dark text-nowrap fw-bold">
                                            {{webCurrencyConverter($sub_total)}}
                                        </td>
                                        @if ($orderDetails['order_type'] == 'default_type')
                                            <td class="text-dark text-nowrap fw-bold">
                                                {{webCurrencyConverter($orderDetails['is_shipping_free'] ? $total_shipping_cost-$orderDetails['extra_discount']:$total_shipping_cost)}}
                                            </td>

                                        @endif

                                        @if($orderDetails['tax_model'] == 'exclude')
                                            <td class="text-dark text-nowrap fw-bold">
                                                {{ webCurrencyConverter($orderDetails['total_tax_amount']) }}
                                            </td>
                                        @endif
                                        <td class="text-dark text-nowrap fw-bold">
                                            -{{webCurrencyConverter($total_discount_on_product)}}
                                        </td>
                                        <td class="text-dark text-nowrap fw-bold">
                                            - {{webCurrencyConverter($coupon_discount)}}
                                        </td>
                                        @if ($orderDetails['order_type'] == 'POS')
                                            <td class="text-dark text-nowrap fw-bold">
                                                - {{webCurrencyConverter($extra_discount)}}
                                            </td>
                                        @endif
                                        <td class="text-dark text-nowrap fw-bold">
                                            {{webCurrencyConverter($sub_total+$orderDetails['total_tax_amount']+$total_shipping_cost-($orderDetails->discount)-$total_discount_on_product - $coupon_discount - $extra_discount)}}
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <div class="modal fade __sign-in-modal" id="digital-product-order-otp-verify-modal" tabindex="-1"
         aria-labelledby="digital_product_order_otp_verifyLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0">
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script src="{{ theme_asset('assets/js/tracking-page.js') }}"></script>
@endpush
