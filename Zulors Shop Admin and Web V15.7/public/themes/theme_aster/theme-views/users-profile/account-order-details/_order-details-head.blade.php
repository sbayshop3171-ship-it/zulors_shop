
<?php
$isOrderOnlyDigital = true;
if($order->details) {
    foreach ($order->details as $detail) {
        $product = json_decode($detail->product_details);
        if (isset($product->product_type) && $product->product_type == 'physical') {
            $isOrderOnlyDigital = false;
        }
    }
}
use Carbon\Carbon;
$isEligibleForRefundButtonShow = 0;
$refund_day_limit = getWebConfig(name: 'refund_day_limit');
$current = Carbon::now();
foreach ($order->details as $key => $detail) {
    $product = $detail?->productAllStatus ?? json_decode($detail->product_details, true);
    if ($product) {
        $length = $detail?->refund_started_at?->diffInDays($current);
        if ($order->order_type == 'default_type' && $order->order_status == 'delivered') {
            if ($detail->refund_request != 0) {
                $isEligibleForRefundButtonShow++;
            }
            if ($refund_day_limit > 0 && !is_null($length) && $length <= $refund_day_limit && $detail->refund_request == 0) {
                $isEligibleForRefundButtonShow++;
            }
        }
    }
}
?>


<div class="border-bottom d-flex align-items-center justify-content-between flex-wrap gap-3 pb-20 mb-20">
    <div class="d-flex align-items-center gap-2 flex-wrap">
        <div class="d-flex align-items-center gap-2">
            <img class="svg svg-dark-support" src="{{theme_asset(path: "/assets/img/icons/home-icon.svg")}}" alt="icon">
            <h6 class="text-capitalize fs-14">{{ $order?->seller?->shop?->name ?? '' }}</h6>
        </div>
        @if($order['order_status']=='failed' || $order['order_status']=='canceled')
            <span class="badge text-danger border-danger-1 text-bg-danger rounded-1 fw-normal fs-12 bg-opacity-10">
            {{ translate($order['order_status']=='failed' ? 'Failed To Deliver' : $order['order_status']) }}
        </span>
        @elseif($order['order_status']=='confirmed' || $order['order_status']=='processing' || $order['order_status']=='delivered')
            <span class="badge text-success border-success-1 text-bg-success rounded-1 fw-normal fs-12 bg-opacity-10">
            {{ translate($order['order_status']=='processing' ? 'packaging' : $order['order_status']) }}
        </span>
        @else
            <span class="badge text-primary border-primary-1 text-bg-primary rounded-1 fw-normal fs-12 bg-opacity-10">
            {{ translate($order['order_status']) }}
        </span>
        @endif

    </div>
    <div class="d-flex align-items-center gap-xl-2 gap-2">
        @if($isEligibleForRefundButtonShow > 0)
        <button class="btn btn-outline-primary rounded-2 py-2 px-3" data-bs-toggle="modal" data-bs-target="#refund-modal">{{ translate('refund') }}</button>
        @endif
        @if($order->order_status=='delivered' &&  $order->order_type == 'default_type')
            <a href="javascript:" class="btn btn-primary rounded-2 py-2 px-3 order-again" data-action="{{route('cart.order-again')}}"  data-order-id="{{$order['id']}}">{{ translate('reorder') }}</a>
        @endif
        <a target="_blank" href="{{route('generate-invoice',[$order->id])}}" class="btn btn-primary rounded-1  w-36 h-36 p-1 d-center"
           data-bs-toggle="tooltip"
           data-bs-placement="bottom"
           data-bs-title="{{ translate('download_invoice') }}">
            <i class="bi bi-file-earmark-arrow-down fs-18"></i>
        </a>
    </div>
</div>
@php
    $showVerificationCode = $order->order_type == 'default_type' && getWebConfig(name: 'order_verification');
@endphp
<div>
    <div class="row g-4">
        <div class="{{ $showVerificationCode ? 'col-md-6' : 'col-md-12' }}">
            <div class="d-flex section-bg-cmn rounded-2 py-2 px-3 flex-wrap align-items-center justify-content-between gap-md-3 gap-2 h-100">
                <div class="flex-grow-1">
                    <h5 class="mb-1 fs-16">{{translate('order').'#'}}{{$order['id']}} </h5>
                    <p class="fs-14">{{date('d M, Y h:i A',strtotime($order->created_at))}}</p>
                </div>
                <div class="">
                  <div class="d-flex gap-3 align-items-center mt-1">
                        <h6 class="text-capitalize fs-14 fw-medium">{{translate('payment_status')}}</h6>
                        <div
                            class="fw-bold {{ $order['payment_status']=='unpaid' ? 'text-danger':'text-success' }}"> {{ translate($order['payment_status']) }}</div>
                    </div>
                    <div class="d-flex gap-3 align-items-center mt-1">
                        <h6 class="text-capitalize fs-14 fw-medium">{{translate('Payment_by')}}</h6>
                        <div
                            class="text-primary fw-bold"> {{ translate($order['payment_method']) }}</div>
                    </div>
                    @if(isset($order->offlinePayments->payment_info))
                        <div class="d-flex flex-column gap-1 mt-1">
                            @foreach ($order->offlinePayments->payment_info as $key => $item)
                                @if($key == 'date')@continue @endif
                                @if ($key != 'method_id' && $key != 'method_name')
                                    <div class="d-flex align-items-center gap-1 fs-12 title-clr">
                                        {{ translate(ucwords(str_replace('_', ' ', $key))) }} :
                                        <span class="">{{ $item ?? 'N/a' }}</span>
                                    </div>
                                @endif
                            @endforeach
                        </div>
                    @endif
                </div>
            </div>
        </div>
        @if($showVerificationCode)
        <div class="col-md-6">
            <div class="d-flex section-bg-cmn rounded-2 py-2 px-3 flex-wrap align-items-center justify-content-between gap-md-3 gap-2 h-100">
                <h5 class="m-0">{{translate('Order verification code')}}</h5>
                <h3 class="text-primary m-0 fw-bold">{{$order['verification_code']}}</h3>
            </div>
        </div>
        @endif
    </div>
</div>


<div class="mt-4">
    <nav>
        <div class="nav nav-nowrap gap-3 gap-xl-4 nav--tabs hide-scrollbar">
            <a href="{{ route('account-order-details', ['id'=>$order->id]) }}"
               class="{{Request::is('account-order-details')  ? 'active' :''}} text-capitalize">{{translate('order_summary')}}</a>
            <a href="{{ route('account-order-details-vendor-info', ['id'=>$order->id]) }}"
               class="{{Request::is('account-order-details-vendor-info')  ? 'active' :''}} text-capitalize">{{translate('vendor_info')}}</a>
            @if($order->order_type != 'POS')
                <a href="{{ route('account-order-details-delivery-man-info', ['id'=>$order->id]) }}"
                   class="{{Request::is('account-order-details-delivery-man-info')  ? 'active' :''}} text-capitalize">{{translate('delivery_man_info')}}</a>
                <a href="{{ route('account-order-details-reviews', ['id'=>$order->id]) }}"
                   class="{{ Request::is('account-order-details-reviews')  ? 'active' :''}} text-capitalize">
                    {{ translate('reviews') }}
                </a>
                <a href="{{route('track-order.order-wise-result-view',['order_id'=>$order['id']])}}"
                   class="{{Request::is('track-order/order-wise-result-view*')  ? 'active' :''}} text-capitalize">
                    {{ translate('track_order') }}
                </a>
            @endif
        </div>
    </nav>
</div>
