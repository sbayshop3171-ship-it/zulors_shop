import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/invoice_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class InvoiceDialogWidget extends StatelessWidget {
  final InvoiceModel? invoice;
  final ShopModel? shopModel;
  final int? orderId;
  final double? discountProduct;
  final double? couponDiscountProduct;
  final double? extraDiscountAmount;
  final double? tax;
  final double? total;
  final ScreenshotController screenshotController;

  const InvoiceDialogWidget({super.key,
    required this.shopModel,
    required this.orderId,
    required this.invoice,
    required this.discountProduct,
    required this.total, required this.screenshotController, this.couponDiscountProduct, this.tax, this.extraDiscountAmount,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize = View.of(context).physicalSize.width > 1000 ? Dimensions.fontSizeExtraSmall : Dimensions.paddingSizeSmall;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 5)],
            ),
            width: MediaQuery.of(context).size.width - ((View.of(context).physicalSize.width - 700) * 0.4),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Screenshot(
              controller: screenshotController,
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      shopModel?.name ?? '',
                      style: robotoRegular.copyWith(fontSize: fontSize),
                    ),
                  ),
                  Center(
                    child: Text(
                      shopModel?.contact ?? '',
                      style: robotoRegular.copyWith(fontSize: fontSize),
                    ),
                  ),
                  //Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          '${getTranslated('invoice', context)!.toUpperCase()}#$orderId',
                          style: robotoRegular.copyWith(fontSize: fontSize, decoration: TextDecoration.underline),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                            getTranslated('payment_method', context)!,
                            textAlign: TextAlign.right,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                            DateConverter.dateTimeStringToMonthAndTime(invoice!.createdAt!),
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                            'Cash',
                            textAlign: TextAlign.right,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                            getTranslated('sl', context)!.toUpperCase(),
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                            getTranslated('product_info', context)!,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          getTranslated('qty', context)!,
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          getTranslated('price', context)!,
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                  Column(
                    children: invoice!.details!.map((detail) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                                '${invoice!.details!.indexOf(detail) + 1}',
                                style: robotoRegular.copyWith(fontSize: fontSize)
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Text(
                                '${detail.productDetails!.name}',
                                style: robotoRegular.copyWith(fontSize: fontSize)
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              detail.qty.toString(),
                              style: robotoRegular.copyWith(fontSize: fontSize),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${detail.price}',
                              style: robotoRegular.copyWith(fontSize: fontSize),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                  Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(
                          getTranslated('subtotal', context)!,
                          style: robotoRegular.copyWith(fontSize: fontSize),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '${invoice!.orderAmount}',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(
                            getTranslated('product_discount', context)!,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '$discountProduct',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(
                            getTranslated('coupon_discount', context)!,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),

                      Expanded(
                        flex: 4,
                        child: Text(
                          '$couponDiscountProduct',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(
                          'extra',
                            // getTranslated('extra_discount', context)!,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '$extraDiscountAmount',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(
                            getTranslated('tax', context)!,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '$tax',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                  Row(
                    children: [
                      Expanded(
                        flex: 14,
                        child: Text(
                            getTranslated('total', context)!,
                            style: robotoRegular.copyWith(fontSize: fontSize)
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '$total',
                          style: robotoRegular.copyWith(fontSize: fontSize),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       flex: 6,
                  //       child: Text(
                  //           getTranslated('change', context)!,
                  //           style: robotoRegular.copyWith(fontSize: fontSize)
                  //       ),
                  //     ),
                  //     Expanded(
                  //       flex: 6,
                  //       child: Text(
                  //         '${invoice!.orderAmount! - total! - discountProduct!}',
                  //         textAlign: TextAlign.right,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 10),
                  Divider(color: Theme.of(context).textTheme.bodyLarge!.color, thickness: 1),
                  Center(
                    child: Text(
                      getTranslated('thank_you', context)!,
                      style: robotoRegular.copyWith(fontSize: fontSize),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
