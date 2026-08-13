"use strict";

$(document).ready(function () {
    let checkIsOffcanvasSetupDataValue = $('#check-offcanvas-setup-guide').data('value')?.toString();
    let checkIsOffcanvasSetupGuideEnable = checkIsOffcanvasSetupDataValue === 'true' || checkIsOffcanvasSetupDataValue === '1';

    if (checkIsOffcanvasSetupGuideEnable) {
        setTimeout(() => {
            const url = new URL(window.location.href);
            url.searchParams.delete('offcanvasShow');
            window.history.replaceState({}, document.title, url.toString());
        }, 3000);
    }

    try {
        $(".js-daterangepicker_till_current").daterangepicker({ maxDate: moment() });
    } catch (e) {}
});


$(".show-delete-data-alert").on("click", function () {
    let getText = $("#get-confirm-and-cancel-button-text-for-delete");
    Swal.fire({
        title: $(this).data('alert-title') ?? getText.data("sure"),
        text: $(this).data('alert-text') ?? getText.data("text"),
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        cancelButtonText: getText.data("cancel"),
        confirmButtonText: getText.data("confirm"),
        reverseButtons: true,
    }).then((result) => {
        if (result.value) {
            $("#" + $(this).data("id")).submit();
        }
    });
});

function checkPasswordMatch() {
    const password = $('#newPassword').val();
    const confirmPassword = $('#confirmNewPasswordLabel').val();

    if (confirmPassword.length > 0 && password !== confirmPassword) {
        $('.confirm-password-error').text('Password and confirm password does not match.');
    } else {
        $('.confirm-password-error').text('');
    }
}
$('#newPassword, #confirmNewPasswordLabel').on('keyup change', function () {
    checkPasswordMatch();
});
