<div class="variation_wrapper mt-3 physical_product_show show-for-physical-product">
    <div class="outline-wrapper">
        <div class="card rest-part bg-animate">
            <div class="card-header d-flex justify-content-between align-items-center pc-header-ai-btn" >
                <div class="d-flex align-items-center gap-2">
                    <i class="fi fi-sr-user"></i>
                    <h3 class="mb-0">{{ translate('product_variation_setup') }}</h3>
                </div>
                <button type="button"
                    class="btn bg-white text-primary bg-transparent shadow-none border-0 opacity-1 generate_btn_wrapper p-0 variation_setup_auto_fill"
                    id="variation_setup_auto_fill" data-route="{{ route('admin.product.variation-setup-auto-fill') }}" data-lang="en">
                    <div class="btn-svg-wrapper">
                        <img width="18" height="18" class=""
                            src="{{ dynamicAsset(path: 'public/assets//back-end/img/ai/blink-right-small.svg') }}" alt="">
                    </div>
                    <span class="ai-text-animation d-none" role="status">
                        {{ translate('Just_a_second') }}
                    </span>
                    <span class="btn-text">{{ translate('Generate') }}</span>
                </button>
            </div>
            <div class="card-body">
                <div class="row gy-4 align-items-end">
                    <div class="col-md-6">
                        <div class="mb-3 d-flex align-items-center gap-2">
                            <label for="colors" class="text-dark mb-0">
                                {{ translate('select_colors') }} :
                            </label>
                            <label class="switcher">
                                <input type="checkbox" class="switcher_input" id="product-color-switcher"
                                       value="{{ old('colors_active') }}"
                                       name="colors_active">
                                <span class="switcher_control"></span>
                            </label>
                        </div>
                        <select class="custom-select color-var-select" name="colors[]" multiple="multiple"
                                id="colors-selector-input" disabled>
                            @foreach ($colors as $color)
                                <option value="{{ $color->code }}" data-color="{{ $color->code }}">
                                    {{ $color['name'] }}
                                </option>
                            @endforeach
                        </select>

                    </div>
                    <div class="col-md-6">
                        <label for="product-choice-attributes" class="form-label">
                            {{ translate('select_attributes') }} :
                        </label>
                        <select class="custom-select"
                                name="choice_attributes[]" id="product-choice-attributes" multiple="multiple"
                                data-placeholder="{{ translate('choose_attributes') }}">
                            <option></option>
                            @foreach ($attributes as $key => $a)
                                <option value="{{ $a['id'] }}">
                                    {{ $a['name'] }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    <div class="col-md-12 mt-2 mb-2">
                        <div class="row customer-choice-options-container my-0 gy-4" id="customer-choice-options-container"></div>
                        <div class="form-group sku_combination py-2" id="sku_combination"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card mt-3 rest-part show-for-digital-product">
    <div class="card-header d-flex justify-content-between align-items-center">
        <div class="d-flex gap-2">
            <i class="fi fi-sr-user"></i>
            <h3 class="mb-0">{{ translate('product_variation_setup') }}</h3>
        </div>
    </div>
    <div class="card-body">
        <div class="row g-2" id="digital-product-type-choice-section">
            <div class="col-sm-6 col-md-4 col-xxl-3">
                <div class="multi--select">
                    <label class="form-label">{{ translate('File_Type') }}</label>
                    <select class="custom-select" name="file-type" multiple
                            id="digital-product-type-select">
                        @foreach($digitalProductFileTypes as $FileType)
                            <option value="{{ $FileType }}">{{ translate($FileType) }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card mt-3 rest-part" id="digital-product-variation-section"></div>
