<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" dir="{{ Session::get('direction') }}">

<head>
    <meta charset="utf-8">
    <meta name="_token" content="{{ csrf_token() }}">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <meta name="robots" content="nofollow, noindex">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <title>@yield('title')</title>
    <link rel="shortcut icon" href="{{ getStorageImages(path: getWebConfig(name: 'company_fav_icon'), type: 'backend-logo') }}">

    @include("layouts.vendor.partials._style-partials")

    {!! ToastMagic::styles() !!}

    @stack('css_or_js')
</head>

<body class="footer-offset">
    <div class="row">
        <div class="col-12 position-fixed z-9999 mt-10rem">
            <div id="loading" class="d--none">
                <div id="loader"></div>
            </div>
        </div>
    </div>
    @include("layouts.vendor.partials._header")
    @include("layouts.vendor.partials._side-bar")

    <main id="content" role="main" class="main pointer-event">
        @yield("content")
        @include("layouts.vendor.partials._footer")
    </main>

    <span class="d-none" id="text-validate-translate"
        data-required="{{ translate('this_field_is_required') }}"
        data-file-size-larger="{{ translate('file_size_is_larger') }}"
        data-max-limit-crossed="{{ translate('max_limit_crossed') }}"
        data-something-went-wrong="{{ translate('something_went_wrong!') }}"
        data-passwords-do-not-match="{{ translate('passwords_do_not_match') }}"
        data-valid-email="{{ translate('please_enter_a_valid_email') }}"
        data-password-validation="{{ translate('password_must_be_8+_chars_with_upper,_lower,_number_&_symbol') }}"
        data-file-type-not-allowed="{{ translate('Invalid_file_type_selected') }}"
    ></span>

    @include("layouts.vendor.partials._modals")
    @include("layouts.vendor.partials._toggle-modal")
    @include("layouts.vendor.partials._sign-out-modal")
    @include("layouts.vendor.partials._alert-message")

    @include("layouts.vendor.partials._translator-for-js")
    @include("layouts.vendor.partials._translated-message-container")
    @include("layouts.vendor.partials._script-partials")

    @stack("script")
    @stack("script_2")
</body>

</html>
