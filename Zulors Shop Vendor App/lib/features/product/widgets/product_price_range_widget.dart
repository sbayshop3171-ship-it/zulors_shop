import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ProductPriceRangeWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  const ProductPriceRangeWidget({super.key, required this.minPriceController, required this.maxPriceController});



  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;
    final double maxPriceRange = PriceConverter.convertAmount(configModel?.productMaxPriceRange ?? 0, context);

    return Consumer<ProductController>(
        builder: (context, productController, _)
        {
          final double minPrice = productController.minPrice ?? 0;
          final double maxPrice = productController.maxPrice ?? maxPriceRange;

          return Column(children: [


            FlutterSlider(
              values: [minPrice, maxPrice],
              rangeSlider: true,
              max: maxPriceRange,
              min: 0,
              trackBar: FlutterSliderTrackBar(
                activeTrackBarHeight: 5,
                activeTrackBar: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Theme.of(context).primaryColor),
                inactiveTrackBar: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: .4)),
              ),
              tooltip: FlutterSliderTooltip(
                // To always show the tooltip for demonstration
                alwaysShowTooltip: false,
                custom: (value) {
                  return Transform.translate(
                    offset: const Offset(0, - Dimensions.iconSizeLarge),
                    child: CustomPaint(
                      painter: _PointyTooltipPainter(),
                      child: Container(
                        width: 120,
                        height: 40,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                        child: Center(
                          child: Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(color: Theme.of(context).highlightColor, fontSize: Dimensions.fontSizeExtraLarge, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              handler: FlutterSliderHandler(
                decoration: const BoxDecoration(),
                child: Container(
                  width: Dimensions.paddingSizeDefault,
                  height: Dimensions.paddingSizeDefault,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              rightHandler: FlutterSliderHandler(
                decoration: const BoxDecoration(),
                child: Container(
                  width: Dimensions.paddingSizeDefault,
                  height: Dimensions.paddingSizeDefault,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              handlerWidth: 40,
              handlerHeight: 20,

              disabled: false,
              onDragging: (handlerIndex, lowerValue, upperValue) {
                minPriceController.text = lowerValue.toStringAsFixed(0);
                maxPriceController.text = upperValue.toStringAsFixed(0);

                productController.setPriceRange(lowerValue, upperValue);
              },
            ),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.iconSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                    Text(getTranslated('min', context)!, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),

                    CustomTextFieldWidget(
                      controller: minPriceController,
                      borderColor: Theme.of(context).hintColor.withValues(alpha: .5),
                      border: true,
                      variant: true,
                      textInputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')), // Allow only digits
                      ],
                      onChanged: (String text) {

                        final double tempMinPrice = double.tryParse(minPriceController.text) ?? 0;
                        final double tempMaxPrice = double.tryParse(maxPriceController.text) ?? 0;

                        if(tempMinPrice <= tempMaxPrice && tempMinPrice <= maxPriceRange && tempMaxPrice <= maxPriceRange) {
                          productController.setPriceRange(
                              tempMinPrice,
                              tempMaxPrice
                          );
                        } else {
                          productController.setPriceRangeValidity(minPrice: tempMinPrice, maxPrice: tempMaxPrice, isValid: false);
                        }
                      },
                    )
                  ]),
                ),
              ),

              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.iconSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                    Text(getTranslated('max', context)!, style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),

                    CustomTextFieldWidget(
                      controller: maxPriceController,
                      borderColor: Theme.of(context).hintColor.withValues(alpha: .5),
                      border: true,
                      variant: true,
                      textInputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')), // Allow only digits
                      ],
                      onChanged: (String text) {

                        final double tempMinPrice = double.tryParse(minPriceController.text) ?? 0;
                        final double tempMaxPrice = double.tryParse(maxPriceController.text) ?? 0;

                        if((tempMinPrice <= tempMaxPrice) && (tempMaxPrice <= maxPriceRange)){
                          productController.setPriceRange(tempMinPrice, tempMaxPrice);
                        } else {
                          productController.setPriceRangeValidity(minPrice: tempMinPrice, maxPrice: tempMaxPrice, isValid: false);
                        }
                      },
                    )
                  ],),
                ),
              )
            ],)
          ]);
        }
    );
  }
}

class _PointyTooltipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Theme.of(Get.context!).primaryColor;

    const double borderRadius = 5.0;
    const double triangleHeight = 10.0;
    const double triangleWidth = 16.0;

    final RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(borderRadius),
    );

    final Path path = Path()
    // Add the rounded rectangle's path as the base
      ..addRRect(roundedRect)
      ..moveTo(size.width / 2 - triangleWidth / 2, size.height) // Left triangle edge
      ..lineTo(size.width / 2, size.height + triangleHeight) // Triangle point
      ..lineTo(size.width / 2 + triangleWidth / 2, size.height) // Right triangle edge
      ..close(); // Close the path for the triangle

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

