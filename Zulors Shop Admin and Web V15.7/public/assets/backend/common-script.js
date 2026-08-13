$(document).ready(function () {
    'use strict'
    let getChattingNewNotificationCheckRoute = $('#getChattingNewNotificationCheckRoute').data('route');
    let chattingNewNotificationAlert = $('#chatting-new-notification-check');
    let chattingNewNotificationAlertMsg = $('#chatting-new-notification-check-message');
    setInterval(function () {
        $.get({
            url: getChattingNewNotificationCheckRoute,
            dataType: 'json',
            success: function (response) {
                if (response.newMessagesExist !== 0 && response.message) {
                    chattingNewNotificationAlertMsg.html(response.message)
                    chattingNewNotificationAlert.addClass('active');
                    playAudio();
                    setTimeout(function () {
                        chattingNewNotificationAlert.removeClass('active')
                    }, 5000);
                }
            },
        });

    }, 20000);

    // ---- Text Collapse
    function shortenText(text, maxLength = 100) {
        return text.length > maxLength ?
            text.substring(0, maxLength).trim() + "... " :
            text;
    }

    $(".short_text").each(function () {
        const $textEl = $(this);
        const originalText = $textEl.text().replace(/\s+/g, " ").trim();
        const maxLength = parseInt($textEl.data("maxlength")) || 100;

        const croppedText = shortenText(originalText, maxLength);

        $textEl.data("full-text", originalText);
        $textEl.text(croppedText);
    });

    $(".see_more_btn").on("click", function () {
        const $wrapper = $(this).closest(".short_text_wrapper");
        const $textEl = $wrapper.find(".short_text");

        const fullText = $textEl.data("full-text");
        const maxLength = parseInt($textEl.data("maxlength")) || 100;
        const seeMoreText = $textEl.data("see-more-text") || "See More";
        const seeLessText = $textEl.data("see-less-text") || "See Less";

        const isExpanded = $textEl.hasClass("expanded");

        if (isExpanded) {
            // Collapse
            $textEl.text(shortenText(fullText, maxLength)).removeClass("expanded");
            $(this).text(seeMoreText);
        } else {
            // Expand
            $textEl.text(fullText).addClass("expanded");
            $(this).text(seeLessText);
        }
    });

    // ---- swipper slider and zoom
    function initSliderWithZoom() {
        $(".easyzoom").each(function () {
            $(this).easyZoom();
        });

        new Swiper(".quickviewSlider2", {
            slidesPerView: 1,
            spaceBetween: 10,
            loop: false,
            thumbs: {
                swiper: new Swiper(".quickviewSliderThumb2", {
                    spaceBetween: 10,
                    slidesPerView: 'auto',
                    watchSlidesProgress: true,
                    navigation: {
                        nextEl: ".swiper-quickview-button-next",
                        prevEl: ".swiper-quickview-button-prev",
                    },
                }),
            },
        });
    }

    initSliderWithZoom();
})

document.addEventListener("DOMContentLoaded", function () {
    document.addEventListener("input", function (event) {
        const input = event.target;
        if (input.matches('input[type="number"], .no-negative-input')) {
            if (input.value < 0) {
                input.value = input.value.replace(/^-/, ""); // Remove minus sign
            }
        }
    });

    document.addEventListener("keydown", function (event) {
        const input = event.target;
        if (input.matches('input[type="number"], .no-negative-input')) {
            if (event.key === "-" || event.key === "Subtract") {
                event.preventDefault();
            }
        }
    });

    document.addEventListener("keydown", function (event) {
        const input = event.target;
        if (input.classList.contains("only-number-input")) {
            if (
                event.key === "+" ||
                event.key === "-" ||
                event.key === "Subtract" ||
                event.key === "Add" ||
                event.key === "." ||  // block decimal point
                event.key === ","     // block comma (if user tries)
            ) {
                event.preventDefault();
            }
        }
    });

    document.addEventListener("input", function (event) {
        const input = event.target;
        if (input.classList.contains("only-number-input")) {
            input.value = input.value.replace(/[^0-9]/g, "");
        }
    });

    document.addEventListener("keydown", function (event) {
        const input = event.target;

        if (input.classList.contains("no-first-space")) {
            if (event.key === " " && input.selectionStart === 0) {
                event.preventDefault();
            }
        }
    });

    document.addEventListener("input", function (event) {
        const input = event.target;
        if (input.classList.contains("no-first-space")) {
            input.value = input.value.replace(/^\s+/, "");
        }
    });
});

// --- Dropdoown with select & search
document.addEventListener("DOMContentLoaded", () => {
    const debounce = (fn, delay = 300) => {
        let timer;
        return (...args) => {
            clearTimeout(timer);
            timer = setTimeout(() => fn(...args), delay);
        };
    };

    document.querySelectorAll(".custom_dropdown_wrapper").forEach(wrapper => {
        const control = wrapper.querySelector(".custom_dropdown_toggle");
        const menu = wrapper.querySelector(".custom_dropdown_menu");
        const searchInput = wrapper.querySelector(".custom_dropdown_search");
        const list = wrapper.querySelector(".custom_dropdown_list");
        const empty = wrapper.querySelector(".custom_dropdown_empty");
        const selectedText = wrapper.querySelector(".selected_text");
        const items = list.querySelectorAll(".custom_dropdown_item");

        const highlightSelected = () => {
            items.forEach(item => {
                if (item.textContent.trim() === selectedText.textContent.trim()) {
                    item.classList.add("text-primary");
                } else {
                    item.classList.remove("text-primary");
                }
            });
        };

        highlightSelected();

        menu.style.display = "none";
        list.style.display = "none";
        empty.style.display = "none";

        control.addEventListener("click", (e) => {
            const isVisible = menu.style.display === "block";
            menu.style.display = isVisible ? "none" : "block";
            searchInput.value = "";
            list.style.display = "none";
            empty.style.display = "none";
            if (!isVisible) {
                setTimeout(() => {
                    searchInput.focus();
                    searchInput.dispatchEvent(new Event("click"));
                }, 50);
            }
        });

        searchInput.addEventListener("focus", () => {
            list.style.display = "block";
            empty.style.display = "none";
            items.forEach(item => item.style.display = "block");
        });

        searchInput.addEventListener("click", (e) => {
            e.stopPropagation();
            list.style.display = "block";
            empty.style.display = "none";
            items.forEach(item => item.style.display = "block");
        });

        searchInput.addEventListener("input", debounce((e) => {
            const query = e.target.value.toLowerCase().trim();
            let hasMatch = false;

            if (!query) {
                list.style.display = "block";
                empty.style.display = "none";
                items.forEach(item => item.style.display = "block");
                highlightSelected();
                return;
            }

            items.forEach(item => {
                if (item.textContent.toLowerCase().includes(query)) {
                    item.style.display = "block";
                    hasMatch = true;
                } else {
                    item.style.display = "none";
                }
            });

            if (hasMatch) {
                list.style.display = "block";
                empty.style.display = "none";
            } else {
                list.style.display = "none";
                empty.style.display = "block";
            }

            highlightSelected();
        }, 300));

        items.forEach(item => {
            item.addEventListener("click", () => {
                selectedText.textContent = item.textContent;
                menu.style.display = "none";
                highlightSelected();
            });
        });

        document.addEventListener("click", (e) => {
            if (!wrapper.contains(e.target)) {
                menu.style.display = "none";
            }
        });
    });
});


// ---- Qty Count ---
$(document).ready(function () {
    $('.qty-input-group').each(function () {
        const $group = $(this);
        const $input = $group.find('.product-qty');
        const min = +$input.attr('min') || 1;
        const max = +$input.attr('max') || 99;

        $group.on('click', '.qty-count', function () {
            let val = +$input.val();
            const isAdd = $(this).data('action') === 'plus';
            val = isAdd ? Math.min(val + 1, max) : Math.max(val - 1, min);
            $input.val(val).trigger('change');
        });

        let typingTimer;
        $input.on('input', function () {
            clearTimeout(typingTimer);
            typingTimer = setTimeout(() => {
                let val = +$input.val();
                if (isNaN(val) || val < min) val = min;
                if (val > max) val = max;
                $input.val(val).trigger('change');
            }, 400);
        });

        $input.on('change', function () {
            const val = +$input.val();
            $group.find('.qty-count[data-action="minus"]').prop('disabled', val <= min);
            $group.find('.qty-count[data-action="plus"]').prop('disabled', val >= max);
        }).trigger('change');
    });
});


document.querySelectorAll('.action-preview-for-uploaded-image').forEach(input => {

    input.addEventListener('change', function () {
        const file = this.files?.[0];
        if (!file) return;

        const fileURL = URL.createObjectURL(file);
        const previewSelector = this.dataset.previewElements;
        const previewImages = document.querySelectorAll(previewSelector);

        previewImages.forEach(img => {
            setTimeout(() => {
                img.src = fileURL;
                img.style.display = "block";
                img.classList.remove("d-none");

                const uploadBox = img.closest('.upload-file');
                const textbox = uploadBox?.querySelector('.upload-file-textbox');
                if (textbox) textbox.classList.add('d-none');
            }, 20);
        });
    });

});
