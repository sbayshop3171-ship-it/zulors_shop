@extends('layouts.admin.app')

@section('title', translate('review_List'))

@section('content')
    <div class="content container-fluid">
        <div class="mb-3">
            <h2 class="h1 mb-0 text-capitalize d-flex gap-2 align-items-center">
                <img width="20" src="{{dynamicAsset(path: 'public/assets/back-end/img/customer_review.png')}}" alt="">
                {{translate('customer_reviews')}}
                <span class="badge badge-info text-bg-info">{{ $reviews->total() }}</span>
            </h2>
        </div>

        <div class="card card-body">
            <form action="{{ url()->current() }}" method="GET">
                <div class="row g-3 align-items-end">
                    <div class="col-xl-4 col-lg-6">
                        <label for="name" class="form-label mb-2">{{ translate('products')}}</label>
                        <div class="dropdown select-product-search w-100">
                            <input type="text" class="product_id" name="product_id" value="{{request('product_id')}}" hidden>
                            <button class="form-control d-flex justify-content-between align-items-center gap-2 text-start dropdown-toggle text-truncate select-product-button"
                                    data-bs-toggle="dropdown" type="button">
                                {{request('product_id') !=null ? $product['name']: translate('select_Product')}}
                            </button>
                            <div class="dropdown-menu w-100 px-2">
                                <div class="input-group">
                                    <input type="search" class="js-form-search form-control search-bar-input search-product" placeholder="{{translate('search_product').'...'}}">
                                    <div class="input-group-append search-submit">
                                        <button type="submit">
                                            <i class="fi fi-rr-search"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="d-flex flex-column gap-3 max-h-40vh overflow-y-auto overflow-x-hidden search-result-box">
                                    @include('admin-views.partials._search-product',['products' => $products])
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6">
                        <label for="name" class="form-label mb-2">{{ translate('vendor')}}</label>
                        <div class="dropdown select-vendor-search w-100">
                            <input type="hidden" class="vendor_id" name="vendor_id" value="{{ request('vendor_id') }}" hidden>
                            <button class="form-control d-flex justify-content-between align-items-center gap-2 text-start dropdown-toggle text-truncate select-vendor-button"
                                    data-bs-toggle="dropdown" type="button">
                                    @if(request('vendor_id') != null)
                                        {{ request('vendor_id') == 0 ? getInHouseShopConfig(key: 'name') : ($vendor?->name ?? translate('select_Vendor')) }}
                                    @else
                                        {{ translate('select_Vendor') }}
                                    @endif
                            </button>
                            <div class="dropdown-menu w-100 px-2">
                                <div class="input-group">
                                    <input type="search" data-route="{{ route('admin.reviews.search-vendor') }}"
                                           class="js-form-search form-control search-bar-input search-review-vendor"
                                           placeholder="{{translate('search_vendor').'...'}}">
                                    <div class="input-group-append search-submit">
                                        <button type="submit">
                                            <i class="fi fi-rr-search"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="d-flex flex-column max-h-200 overflow-y-auto overflow-x-hidden search-review-vendor-result-box">
                                    @include('admin-views.reviews._review-vendors', ['shopList' => $shopList])
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6">
                        <label class="form-label mb-2" for="customer">{{translate('customer')}}</label>
                        <input type="hidden" id='customer_id' name="customer_id"
                               value="{{request('customer_id') ? request('customer_id') : 'all'}}">
                        <select data-placeholder="
                                        @if($customer == 'all')
                                            {{translate('All_Customer')}}
                                        @else
                                            {{$customer['name'] ?? $customer['f_name'].' '.$customer['l_name'].' '.'('.$customer['phone'].')'}}
                                        @endif"
                                class="get-customer-list-by-ajax-request form-select form-ellipsis set-customer-value">
                            <option value="all">{{translate('All_Customer')}}</option>
                        </select>
                    </div>
                    <div class="col-xl-4 col-lg-6">
                        <div>
                            <label for="status" class="form-label mb-2">
                                {{ translate('status') }}</label>
                            <div class="select-wrapper">
                                <select class="form-select" name="status">
                                    <option value="" selected> {{ '---'.translate('select_status').'---' }} </option>
                                    <option value="1" {{ !is_null($status) && $status == 1 ? 'selected' : '' }}>
                                        {{ translate('active') }}</option>
                                    <option value="0" {{ !is_null($status) && $status == 0 ? 'selected' : '' }}>
                                        {{ translate('inactive') }}</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6">
                        <div>
                            <label for="from" class="form-label mb-2">{{ translate('Date_Wise_Filter') }}</label>
                            <input type="text" name="from" id="start-date-time" value="{{ $from }}" title="{{ $from }}"
                                   class="form-control date-range-js line-1"
                                   title="{{ translate('Date_Wise_Filter') }}" autocomplete="off">
                        </div>
                    </div>

                    <div class="col-xl-4 col-lg-6">
                        <div class="d-flex gap-3 justify-content-end">
                            <a href="{{ route('admin.reviews.list') }}"
                               class="btn btn-secondary">
                                {{ translate('reset') }}
                            </a>
                            <button type="submit" class="btn btn-primary">{{translate('Filter')}}</button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
        <div class="card mt-20">
            <div class="card-body">
                <div class="d-flex justify-content-between flex-wrap gap-3 align-items-center mb-4">
                    <h3 class="mb-0">
                        {{translate('Customer_Reviews_List')}}
                        <span class="badge badge-info text-bg-info">{{ $reviews->total() }}</span>
                    </h3>

                    <div class="d-flex gap-3 flex-wrap">
                        <form action="{{ url()->current() }}" method="GET">
                            <div class="form-group">
                                <div class="input-group">
                                    <input id="datatableSearch_" type="search" name="searchValue" class="form-control"
                                           placeholder="{{ translate('search_by_Product_or_Customer') }}"
                                           aria-label="Search orders" value="{{ request('searchValue') }}" >
                                    <div class="input-group-append search-submit">
                                        <button type="submit">
                                            <i class="fi fi-rr-search"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>

                        <a type="button" class="btn btn-outline-primary" href="{{ route('admin.reviews.export', ['searchValue'=>$searchValue, 'product_id' => $product_id, 'vendor_id' => $vendor_id, 'customer_id' => $customer_id, 'status' => $status, 'from' => $from, 'to' => $to]) }}">
                            <i class="fi fi-sr-inbox-in"></i>
                            <span class="fs-12">{{ translate('export') }}</span>
                        </a>
                    </div>
                </div>

                <div class="table-responsive datatable-custom">
                    <table class="table table-hover table-borderless table-thead-bordered table-nowrap align-middle card-table w-100">
                        <thead class="thead-light thead-50 text-capitalize">
                            <tr>
                                <th>{{ translate('SL') }}</th>
                                <th>{{ translate('Review_ID') }}</th>
                                <th>{{ translate('product') }}</th>
                                <th>{{ translate('customer') }}</th>
                                <th>{{ translate('rating') }}</th>
                                <th>{{ translate('review') }}</th>
                                <th>{{ translate('Reply') }}</th>
                                <th>{{ translate('date') }}</th>
                                <th class="text-center">{{ translate('status') }}</th>
                                <th class="text-center">{{ translate('action') }}</th>
                            </tr>
                        </thead>
                        <tbody>
                        @foreach ($reviews as $key => $review)
                            <tr>
                                <td>
                                    {{ $reviews->firstItem()+$key }}
                                </td>
                                <td class="text-center">
                                    {{ $review->id }}
                                </td>
                                <td>
                                    @if(isset($review->product))
                                        <a href="{{$review['product_id'] ? route('admin.products.view', ['addedBy'=>($review->product->added_by =='seller'?'vendor' : 'in-house'),'id'=>$review->product->id]) : 'javascript:'}}"
                                           class="text-dark text-hover-primary">
                                            {{ Str::limit($review->product['name'], 25) }}
                                        </a>
                                    @else
                                        <span class="text-dark">
                                            {{ translate('product_not_found') }}
                                        </span>
                                    @endif
                                </td>
                                <td>
                                    @if ($review->customer)
                                        <a href="{{ route('admin.customer.view', [$review->customer_id]) }}"
                                           class="text-dark text-hover-primary">
                                            {{ $review->customer->f_name . ' ' . $review->customer->l_name }}
                                        </a>
                                    @else
                                        <label class="badge badge-soft-danger">{{ translate('customer_removed') }}</label>
                                    @endif
                                </td>
                                <td>
                                    <label class="badge badge-info text-bg-info">
                                            <span class="fs-12 d-flex align-items-center gap-1">{{ $review->rating }}
                                                <i class="fi fi-sr-star"></i>
                                            </span>
                                    </label>
                                </td>
                                <td>
                                    <div class="gap-1">
                                        <div class="fs-12 mb-1">
                                            {{ $review->comment ? Str::limit($review->comment, 35) : translate('no_comment_found') }}
                                        </div>
                                        @if(count($review->attachment_full_url) > 0)
                                            <div class="d-flex flex-wrap gap-1 min-w-200">
                                                @foreach ($review->attachment_full_url as $img)
                                                    <a href="{{ $img['path'] }}"
                                                       data-lightbox="mygallery-{{ $review->id }}">
                                                        <img width="60" height="60"
                                                             class="aspect-1 rounded object-fit-cover"
                                                             src="{{ getStorageImages(path: $img, type: 'backend-basic') }}"
                                                             alt="{{translate('image')}}">
                                                    </a>
                                                @endforeach
                                            </div>
                                        @endif
                                    </div>
                                </td>
                                <td>
                                    <div class="line-2 word-break">
                                        {{Str::limit( $review?->reply?->reply_text , 180)?? '-' }}
                                    </div>
                                </td>
                                <td>{{ date('d M Y', strtotime($review->updated_at)) }}</td>
                                <td>
                                    <form action="{{ route('admin.reviews.status') }}"
                                          method="post" id="reviews-status{{$review['id']}}-form"
                                          class="no-reload-form">
                                        <input type="hidden" name="id" value="{{$review['id']}}">
                                        <label class="switcher mx-auto" for="reviews-status{{$review['id']}}">
                                            <input
                                                class="switcher_input custom-modal-plugin"
                                                type="checkbox" value="1" name="status"
                                                id="reviews-status{{$review['id']}}"
                                                {{ $review->status ? 'checked' : '' }}
                                                data-modal-type="input-change-form"
                                                data-modal-form="#reviews-status{{$review['id']}}-form"
                                                data-on-image="{{ dynamicAsset(path: 'public/assets/new/back-end/img/modal/customer-reviews-on.png') }}"
                                                data-off-image="{{ dynamicAsset(path: 'public/assets/new/back-end/img/modal/customer-reviews-off.png') }}"
                                                data-on-title = "{{translate('Want_to_Turn_ON_Customer_Reviews').'?'}}"
                                                data-off-title = "{{translate('Want_to_Turn_OFF_Customer_Reviews').'?'}}"
                                                data-on-message = "<p>{{translate('if_enabled_anyone_can_see_this_review_on_the_user_website_and_customer_app')}}</p>"
                                                data-off-message = "<p>{{translate('if_disabled_this_review_will_be_hidden_from_the_user_website_and_customer_app')}}</p>"
                                                data-on-button-text="{{ translate('turn_on') }}"
                                                data-off-button-text="{{ translate('turn_off') }}">
                                            <span class="switcher_control"></span>
                                        </label>
                                    </form>
                                </td>
                                <td>
                                    <div class="d-flex gap-2 justify-content-center">
                                        <div data-bs-toggle="modal" data-bs-target="#review-view-for-{{ $review['id'] }}">
                                            <a class="btn btn-outline-info icon-btn" title="{{ translate('View') }}" data-bs-toggle="tooltip">
                                                <i class="fi fi-rr-eye"></i>
                                            </a>
                                        </div>

                                        @if(isset($review->product) && $review?->product?->added_by == 'admin')
                                            <div data-bs-toggle="modal" data-bs-target="#review-update-for-{{ $review['id'] }}">
                                                @if($review?->reply)
                                                    <a class="btn btn-outline-primary icon-btn" title="{{ translate('Update_Review') }}" data-bs-toggle="tooltip">
                                                        <i class="fi fi-rr-pencil"></i>
                                                    </a>
                                                @else
                                                    <div class="btn btn-outline-primary icon-btn" title="{{ translate('Review_Reply') }}" data-bs-toggle="tooltip">
                                                        <i class="fi fi-rr-reply-all"></i>
                                                    </div>
                                                @endif
                                            </div>
                                        @elseif($review?->product?->added_by == 'seller')
                                            <div>
                                                <a class="btn btn-outline-primary icon-btn" title="{{ translate('Admin_can_not_reply_to_vendor_product_review') }}" data-bs-toggle="tooltip">
                                                    @if($review?->reply)
                                                        <i class="fi fi-rr-pencil"></i>
                                                    @else
                                                    <i class="fi fi-rr-reply-all"></i>
                                                    @endif
                                                </a>
                                            </div>
                                        @else
                                            <div>
                                                <a class="btn btn-outline-primary icon-btn" title="{{ translate('product_not_found') }}" data-bs-toggle="tooltip">
                                                    @if($review?->reply)
                                                    <i class="fi fi-rr-pencil"></i>
                                                    @else
                                                    <i class="fi fi-rr-reply-all"></i>
                                                    @endif
                                                </a>
                                            </div>
                                        @endif
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                        </tbody>
                    </table>
                </div>

                @foreach($reviews as $key => $review)
                    @if(isset($review->customer))
                        <div class="modal fade" id="review-update-for-{{ $review['id'] }}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header border-0 d-flex justify-content-end">
                                        <button type="button" class="btn btn-circle border-0 fs-12 text-body bg-section2 shadow-none"
                                                style="--size: 2rem;" data-bs-dismiss="modal" aria-label="Close">
                                            <i class="fi fi-sr-cross"></i>
                                        </button>
                                    </div>
                                    <form method="POST" action="{{ route('admin.reviews.add-review-reply') }}">
                                        @csrf
                                        <div class="modal-body pt-0">
                                            <div class="d-flex flex-wrap align-items-center gap-3 mb-3">
                                                @if(isset($review->product))
                                                    <img src="{{ getStorageImages(path: $review->product->thumbnail_full_url, type: 'backend-product') }}"
                                                         width="60" class="rounded aspect-1 border" alt="{{ translate('Product') }}">
                                                    <div class="flex-grow-1">
                                                        <h5 class="mb-1 fs-14 text-dark">{{ $review->product['name'] }}</h5>
                                                        @if($review['order_id'])
                                                            <span class="fs-12 text-muted">{{ translate('Order_ID') }} #{{ $review['order_id'] }}</span>
                                                        @endif
                                                    </div>
                                                @else
                                                    <span class="text-dark">{{ translate('product_not_found') }}</span>
                                                @endif
                                            </div>

                                            <div class="bg-section p-3 rounded border mb-3">
                                                <div class="d-flex gap-2 align-items-center mb-2">
                                                    <img class="h-30 aspect-1 rounded-circle"
                                                         src="{{ getStorageImages(path: $review->customer?->image_full_url, type: 'backend-profile') }}"
                                                         alt="{{ translate('Customer') }}">
                                                    <span class="fs-14 fw-medium text-dark">
                                    {{ $review->customer?->f_name ?? translate('Customer') }}
                                </span>
                                                </div>
                                                <p class="mb-0 fs-14">{{ $review['comment'] ?? translate('No comment found') }}</p>
                                            </div>

                                            @if(count($review->attachment_full_url) > 0)
                                                <div class="d-flex flex-wrap gap-2 mb-3">
                                                    @foreach ($review->attachment_full_url as $img)
                                                        <a href="{{ getStorageImages(path: $img, type: 'backend-basic') }}"
                                                           data-lightbox="review-gallery-modal{{ $review['id'] }}">
                                                            <img width="45" class="rounded aspect-1 border"
                                                                 src="{{ getStorageImages(path: $img, type: 'backend-basic') }}"
                                                                 alt="{{ translate('review_image') }}">
                                                        </a>
                                                    @endforeach
                                                </div>
                                            @endif

                                            <label class="form-label fw-bold">
                                                {{ translate('Reply') }}
                                            </label>
                                            <input type="hidden" name="review_id" value="{{ $review['id'] }}">
                                            <textarea class="form-control text-area-max-min" rows="3" name="reply_text"
                                                      placeholder="{{ translate('Write_the_reply_of_the_product_review') }}...">{{ $review?->reply?->reply_text ?? '' }}</textarea>

                                            <div class="text-end mt-4">
                                                <button type="submit" class="btn btn-primary">
                                                    {{ $review?->reply?->reply_text ? translate('Update') : translate('submit') }}
                                                </button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    @endif



                    @include("admin-views.reviews._review-modal", ['review' => $review])
                @endforeach

                <div class="table-responsive mt-4">
                    <div class="px-4 d-flex justify-content-lg-end">
                        {!! $reviews->links() !!}
                    </div>
                </div>
                @if(count($reviews)==0)
                    @include('layouts.admin.partials._empty-state',['text'=>'no_review_found'],['image'=>'default'])
                @endif
            </div>
        </div>
    </div>

    {{-- review modal --}}
    <div class="modal fade" id="review-modal" tabindex="-1" aria-labelledby="review-modal" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header border-0 pb-0 d-flex justify-content-end">
                    <button type="button" class="btn btn-circle border-0 fs-12 text-body bg-section2 shadow-none" style="--size: 2rem;"  data-bs-dismiss="modal" aria-label="Close">
                        <i class="fi fi-sr-cross"></i>
                    </button>
                </div>
                <div class="modal-body px-20 py-0 mb-30">
                    <h3 class="mb-2">Review #403</h3>
                    <div
                        class="d-flex gap-3 flex-wrap flex-sm-nowrap justify-content-between align-items-center border-bottom mb-4 pb-4">
                        <div class="d-flex gap-2 align-items-center">
                            <img class="h-50px aspect-1 rounded border"
                                src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                            <span class="fs-14 text-dark">Premium Brown Leather Shoulder Bag for Women – Classic, Chic &
                                Everyday Ready</span>
                        </div>
                        <div
                            class="bg-section h-50px w-120 rounded-10 text-dark fs-20 fw-medium d-flex gap-2 align-items-center justify-content-center lh-1">
                            <span>4.5</span>
                            <span class="lh-1"><i class="fi fi-sr-star text-warning"></i></span>
                        </div>
                    </div>
                    <div class="mb-20">
                        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-2">
                            <h4 class="mb-0">Review</h4>
                            <div class="d-flex flex-sm-no-wrap flex-wrap gap-2 align-items-center">
                                <span>12 Jan, 2024</span>
                                <span class="d-none d-sm-block">|</span>
                                <span>12:10 PM</span>
                            </div>
                        </div>
                        <div class="bg-section p-3 p-sm-20 rounded-10">
                            <div class="d-flex gap-2 align-items-center mb-2">
                                <img class="h-30 aspect-1 rounded-circle"
                                    src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                                <span class="fs-14 text-dark fw-medium">Devid Jack</span>
                            </div>
                            <p class="short_text_wrapper mb-0">
                                <span class="short_text" data-maxlength="298"
                                    data-see-more-text="{{ translate('See_More') }}"
                                    data-see-less-text="{{ translate('See_Less') }}">
                                    It is a long established fact that a reader will be distracted the
                                    readable content of a page when looking at its layout. The point of
                                    using Lorem Ipsum is that it has a more-or-less normal distribution of
                                    letters, as opposed to using 'Content here, content here. It is a long established fact
                                    that a reader will be distracted the
                                    readable content of a page when looking at its layout. The point of
                                    using Lorem Ipsum is that it has a more-or-less normal distribution of
                                    letters, as opposed to using 'Content here, content here.
                                </span>
                                <a href="javascript:"
                                    class="see_more_btn text-underline text-nowrap">{{ translate('See_More') }}</a>
                            </p>
                            <div class="d-flex flex-wrap gap-3 align-items-center mt-2">
                                <img class="w-50px aspect-1 rounded"
                                     src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                                <img class="w-50px aspect-1 rounded"
                                     src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                            </div>
                        </div>
                    </div>
                    <div>
                        <div class="d-flex flex-wrap justify-content-between align-items-center gap-3 mb-2">
                            <h4 class="mb-0">Reply</h4>
                            <div class="d-flex flex-sm-no-wrap flex-wrap gap-2 align-items-center">
                                <span>12 Jan, 2024</span>
                                <span class="d-none d-sm-block">|</span>
                                <span>12:10 PM</span>
                            </div>
                        </div>
                        <div class="bg-section p-3 p-sm-20 rounded-10">
                            <div class="d-flex gap-2 align-items-center mb-2">
                                <img class="h-30 aspect-1 rounded-circle"
                                    src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                                <span class="fs-14 text-dark fw-medium">Equator Shop</span>
                            </div>
                            <p class="short_text_wrapper mb-0">
                                <span class="short_text" data-maxlength="298"
                                    data-see-more-text="{{ translate('See_More') }}"
                                    data-see-less-text="{{ translate('See_Less') }}">
                                    It is a long established fact that a reader will be distracted the
                                    readable content of a page when looking at its layout. The point of
                                    using Lorem Ipsum is that it has a more-or-less normal distribution of
                                    letters, as opposed to using 'Content here, content here. It is a long established fact
                                    that a reader will be distracted the
                                    readable content of a page when looking at its layout. The point of
                                    using Lorem Ipsum is that it has a more-or-less normal distribution of
                                    letters, as opposed to using 'Content here, content here.
                                </span>
                                <a href="javascript:"
                                    class="see_more_btn text-underline text-nowrap">{{ translate('See_More') }}</a>
                            </p>
                            <div class="d-flex flex-wrap gap-3 align-items-center mt-2">
                                <img class="w-50px aspect-1 rounded"
                                    src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                                <img class="w-50px aspect-1 rounded"
                                    src="{{ dynamicAsset( path: 'public/assets/back-end/img/160x160/img2.jpg') }}" alt="">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection

@push('script')
    <script src="{{dynamicAsset(path: 'public/assets/new/back-end/js/search-product.js')}}"></script>
@endpush
