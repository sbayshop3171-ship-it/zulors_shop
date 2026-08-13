'use strict';
$('.search-product').on('keyup',function (){
    let name = $(this).val();
    if (name.length > 0) {
        $.get($('#get-search-product-route').data('action'), {searchValue: name}, (response) => {
            $('.search-result-box').empty().html(response.result);
        })
    }
})
$('.search-all-type-product').on('focus click keyup',function (){
    let name = $(this).val();
    let data = { searchValue: name };
    let $input = $(this);
    let $wrapper = $input.closest('.dropdown');
    let $dropdown = $wrapper.find('.dropdown-menu');
    $dropdown.addClass('show');
    $.get($('#get-search-product-route').data('action'), {searchValue: name}, (response) => {
        $('.search-result-box').empty().html(response.result);
    })
})

let selectProductSearch = $('.select-product-search');
selectProductSearch.on('click', '.select-product-item', function () {
    let productName = $(this).find('.product-name').text();
    let productId = $(this).find('.product-id').text();
    selectProductSearch.find('button.dropdown-toggle').text(productName);
    $('.product_id').val(productId);
})
