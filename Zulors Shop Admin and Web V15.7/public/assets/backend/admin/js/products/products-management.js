"use strict";

let getYesWord = $('#message-yes-word').data('text');
let getCancelWord = $('#message-cancel-word').data('text');
let messageAreYouSureDeleteThis = $('#message-are-you-sure-delete-this').data('text');
let messageYouWillNotAbleRevertThis = $('#message-you-will-not-be-able-to-revert-this').data('text');

$('.attribute-delete-button').on('click', function () {
    let attributeId = $(this).attr("id");
    Swal.fire({
        title: messageAreYouSureDeleteThis,
        text: messageYouWillNotAbleRevertThis,
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: getYesWord,
        cancelButtonText: getCancelWord,
        icon: 'warning',
        reverseButtons: true
    }).then((result) => {
        if (result.value) {
            $.ajaxSetup({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
                }
            });
            $.ajax({
                url: $('#route-admin-attribute-delete').data('url'),
                method: 'POST',
                data: {id: attributeId},
                success: function (response) {
                    toastMagic.success(response.message);
                    location.reload();
                }
            });
        }
    })
})

$('.delete-brand').on('click', function () {
    let brandId = $(this).attr("id");
    Swal.fire({
        title: messageAreYouSureDeleteThis,
        text: messageYouWillNotAbleRevertThis,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: getYesWord,
        cancelButtonText: getCancelWord,
        reverseButtons: true
    }).then((result) => {
        if (result.value) {
            let brands =$('#get-brands').data('brands').data
            brands = brands.filter(brands =>brands.id !== parseInt(brandId));
            let selectDropdown = $('.brand-option').empty();
            brands.forEach(brand => {
                let option = $('<option></option>').attr('value', brand.id).text(brand.name);
                selectDropdown.append(option);
            });
            $('input[name=id]').val(brandId)
            $('.brand-title-message').html($(this).data('text'))
            if($(this).data('product-count') > 0){
                $('#select-brand-modal').modal('show');
            }else{
                $('.product-brand-update-form-submit').submit();
            }
        }
    })
});

$('.delete-category').on('click', function () {
    let categoryId = $(this).attr("id");
    Swal.fire({
        title: messageAreYouSureDeleteThis,
        text: messageYouWillNotAbleRevertThis,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: getYesWord,
        cancelButtonText: getCancelWord,
        reverseButtons: true
    }).then((result) => {
        if (result.value) {
            let categories =$('#get-categories').data('categories').data
            categories = categories.filter(category =>category.id !== parseInt(categoryId));
            let selectDropdown = $('.category-option').empty();
            categories.forEach(category => {
                let option = $('<option></option>').attr('value', category.id).text(category.name);
                selectDropdown.append(option);
            });
            $('input[name=id]').val(categoryId)

            $('.category-title-message').html($(this).data('text'))
            if($(this).data('product-count') > 0){
                $('#select-category-modal').modal('show');
            }else{
                $('.product-category-update-form-submit').submit();
            }

        }
    })
});

$('.category-delete-button').on('click', function () {
    let categoryId = $(this).attr("id");
    Swal.fire({
        title: messageAreYouSureDeleteThis,
        text: messageYouWillNotAbleRevertThis,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: getYesWord,
        cancelButtonText: getCancelWord,
        reverseButtons: true
    }).then((result) => {
        if (result.value) {
            $.ajaxSetup({
                headers: {
                    'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
                }
            });
            $.ajax({
                url: $('#route-admin-category-delete').data('url'),
                method: 'POST',
                data: {id: categoryId},
                success: function (response) {
                    toastMagic.success(response.message);
                    location.reload();
                }
            });
        }
    })
});

$('.action-get-sub-category-onchange').on('change', function () {
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });
    $.ajax({
        type: 'POST',
        url: $(this).data('route'),
        data: {
            id: $(this).val()
        },
        success: function (response) {
            $("#parent_id").html(response.html);
        }
    });
});


let loadMoreParentCategoriesPage = 2;
$('.load-more-parent-categories').on('click', function () {
    $.ajaxSetup({
        headers: {
            'X-CSRF-TOKEN': $('meta[name="_token"]').attr('content')
        }
    });
    $.ajax({
        type: 'POST',
        url: $(this).data('route'),
        data: {
            page: loadMoreParentCategoriesPage,
            old_categories: $('[name="old_categories"]').val(),
        },
        beforeSend: function () {
            $('.load-more-categories-spinner').removeClass('d-none');
            $('.load-more-parent-categories').addClass('d-none');
        },
        success: function (response) {
            loadMoreParentCategoriesPage++;
            $("#load-more-categories-view").append(response.html);
            if (response.hiddenCount <= 0) {
                $('.load-more-categories-container').hide();
            }

            setTimeout(() => {
                $('.load-more-categories-spinner').addClass('d-none');
                $('.load-more-parent-categories').removeClass('d-none');
            }, 1000)
        },
        complete: function () {
            setTimeout(() => {
                $('.load-more-categories-spinner').addClass('d-none');
                $('.load-more-parent-categories').removeClass('d-none');
            }, 1000)
        },
    });
});


$(document).on('submit', '.admin-category-store', async function (event) {
    event.preventDefault();

    if (!await validateFormHelper($(this))) return false;

    $.ajaxSetup({
        headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }
    });

    const formData = new FormData(this);
    $.ajax({
        url: $(this).attr('action'),
        type: $(this).attr('method') || 'POST',
        data: formData,
        processData: false,
        contentType: false,
        beforeSend: function () {
            // Loader ON
        },
        success: function (response) {
            // Success handler
            ajaxResponseManager(response);
        },
        error: function (xhr) {
            xhrResponseManager(xhr);
        },
        complete: function () {
            formSubmitCleanup($(this));
        }
    });
});
