$(document).ready(function () {
    let hasFileSizeError = false;

    window.hasFileSizeError = function () {
        return hasFileSizeError;
    };

    window.validateRequiredImages = function () {
        let isValid = true;

        $(".multi_image_picker[data-required='true']").each(function () {
            const $picker = $(this);
            const hasImage = $picker.find(".spartan_item").length > 0 || $picker.find('input[type="file"]').val();

            if (!hasImage) {
                isValid = false;

                toastMagic.error($picker.data("required-msg") || $("#text-validate-translate").data("required"));

                $("html, body").animate(
                    { scrollTop: $picker.offset().top - 120 },
                    600
                );

                return false;
            }
        });

        return isValid;
    };

    function checkNavOverflow($picker) {
        try {
            let $btnNext = $picker.find(".imageSlide_next");
            let $btnPrev = $picker.find(".imageSlide_prev");
            let isRTL = $("html").attr("dir") === "rtl";
            let navScrollWidth = $picker[0].scrollWidth;
            let navClientWidth = $picker[0].clientWidth;
            let scrollLeft = $picker.scrollLeft();

            if (isRTL) {
                let maxScrollLeft = navScrollWidth - navClientWidth;
                let scrollRight = maxScrollLeft - scrollLeft;

                $btnNext.toggle(scrollLeft > 0);
                $btnPrev.toggle(scrollRight > 1);
            } else {
                $btnNext.toggle(
                    navScrollWidth > navClientWidth &&
                        scrollLeft + navClientWidth < navScrollWidth
                );
                $btnPrev.toggle(scrollLeft > 1);
            }
        } catch (error) {
            console.error("Error checking nav overflow:", error);
        }
    }

    $(".multi_image_picker").each(function () {
        let $picker = $(this);
        let ratio = $picker.data("ratio");
        let fieldName = $picker.data("field-name");
        let maxCount = $picker.data("max-count") || Infinity;
        let maxFileSize = $picker.data("max-filesize") || 5;
        maxFileSize = maxFileSize * 1024;
        $picker.spartanMultiImagePicker({
            fieldName: fieldName,
            maxCount: maxCount,
            rowHeight: "100px",
            groupClassName: "",
            maxFileSize: maxFileSize,
            allowedExt: "webp|jpg|jpeg|png|gif",
            dropFileLabel: `<div class="drop-label text-center">
                                <h6 class="mt-1 fw-medium lh-base">
                                    <span class="text-info">Click to upload</span><br>
                                    or drag and drop
                                </h6>
                            </div>`,
            placeholderImage: {
                image: placeholderImageUrl,
                width: "30px",
                height: "30px",
            },
            onAddRow: function (index) {
                checkNavOverflow($picker);
                setAspectRatio($picker, ratio);

                hasFileSizeError = false;
            },
            onRemoveRow: function (index) {
                checkNavOverflow($picker);
                setAspectRatio($picker, ratio);
            },
            onSizeErr: function (index, file) {
                hasFileSizeError = true;
                toastMagic.error($("#text-validate-translate").data("file-size-larger"));
            },
        });

        function setAspectRatio($picker, ratio) {
            if (ratio) {
                $picker.find(".file_upload").css("aspect-ratio", ratio);
            }
        }

        $picker.find(".imageSlide_next").click(function () {
            let scrollWidth = $picker
                .find(".spartan_item_wrapper")
                .outerWidth(true);
            $picker.animate(
                { scrollLeft: $picker.scrollLeft() + scrollWidth },
                300,
                function () {
                    checkNavOverflow($picker);
                }
            );
        });

        $picker.find(".imageSlide_prev").click(function () {
            let scrollWidth = $picker
                .find(".spartan_item_wrapper")
                .outerWidth(true);
            $picker.animate(
                { scrollLeft: $picker.scrollLeft() - scrollWidth },
                300,
                function () {
                    checkNavOverflow($picker);
                }
            );
        });
    });

    let resizeTimeout;
    $(window).on("resize", function () {
        clearTimeout(resizeTimeout);
        resizeTimeout = setTimeout(function () {
            $(".multi_image_picker").each(function () {
                checkNavOverflow($(this));
            });
        }, 200);
    });

    $(".multi_image_picker").on("scroll", function () {
        checkNavOverflow($(this));
    });

});
