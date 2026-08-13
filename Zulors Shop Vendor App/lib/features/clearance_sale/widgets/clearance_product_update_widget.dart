import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/models/clearnace_sale_product_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_product_distount_text_field_widget.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ClearanceProductUpdateWidget extends StatefulWidget {
  final Products products;
  const ClearanceProductUpdateWidget(this.products, {super.key});

  @override
  State<ClearanceProductUpdateWidget> createState() => _ClearanceProductUpdateWidgetState();
}

class _ClearanceProductUpdateWidgetState extends State<ClearanceProductUpdateWidget> {
  TextEditingController skuController = TextEditingController();
  String _discountType = '';
  bool hasVariation = false;

  var result;

  @override
  void initState() {
    _discountType = widget.products.discountType == 'percentage' ? 'percent' : 'amount';
    skuController.text = _discountType == 'percent' ? widget.products.discountAmount.toString() : PriceConverter.convertPriceWithoutSymbol(context, widget.products.discountAmount);

    if(widget.products.product?.variation != null && widget.products.product!.variation!.isNotEmpty) {
      hasVariation = true;
      result = Provider.of<ClearanceSaleController>(Get.context!, listen: false).getMinMaxValues(widget.products.product?.variation ?? []);
    }

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 15, weight: 2, color: Theme.of(context).disabledColor)
                    )
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 55, width: 55,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.05), width: .75)
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: CustomImageWidget(
                                image: widget.products.product?.thumbnailFullUrl?.path ?? '')
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: Column(
                              children: [
                                Text(widget.products.product?.name ?? '',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 3,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Theme.of(context).hintColor.withValues(alpha:0.20), thickness: 1),


                      Row(
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Wrap(
                                  children: [
                                    Text('${getTranslated('category', context)!} : ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),
                            
                                    Text(widget.products.product?.category?.name ?? '',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2,
                                    ),
                            
                                  ],
                                ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            
                                if(widget.products.product?.productType == 'physical') ...[
                                  Wrap(
                                    children: [
                                      Text('${getTranslated('brand', context)!} : ',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                      ),
                            
                                      Text(widget.products.product?.brand?.name ?? '',
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                ],
                            
                                Wrap(
                                  children: [
                                    Text('${getTranslated('stock', context)!} : ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),
                            
                                    Text(widget.products.product?.currentStock.toString() ?? '0',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Column(children: [

                            Text(PriceConverter.convertPrice(context, widget.products.product?.unitPrice,
                                discountType: widget.products.product?.clearanceSale?.discountType,
                                discount: widget.products.product?.clearanceSale?.discountAmount,
                            ), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),


                          ((widget.products.product!.clearanceSale?.discountAmount ?? 0) > 0) ?
                            Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                              child: Text(PriceConverter.convertPrice(context, widget.products.product!.unitPrice),
                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha:0.50),
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Theme.of(context).primaryColor.withValues(alpha:0.50),
                                    fontSize: Dimensions.fontSizeDefault,
                                  )),
                            ) : const SizedBox.shrink(),
                          ]),
                          
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        ],
                      ),

                    ],
                  )
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                ClearanceProductDiscountTextFieldWidget(
                  formProduct: true,
                  border: true,
                  controller: skuController,
                  textInputAction: TextInputAction.next,
                  textInputType: TextInputType.number,
                  isAmount: true,
                  hintText: getTranslated('discount_amount', context)!,
                  isPassword : false,
                  isClearanceDiscountAmount : _discountType != 'percent',
                  onDiscountTypeChanged : (String? value) {
                    setState(() => _discountType = value!);
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),


                SizedBox(
                  width: 210,
                  child: Row(children: [
                    Expanded(child: InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: CustomButtonWidget(
                        isColor: true,
                        btnTxt: '${getTranslated('cancel', context)}',
                        backgroundColor: Theme.of(context).cardColor,
                        fontColor: Theme.of(context).colorScheme.error,
                        borderColor: Theme.of(context).colorScheme.error,
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Consumer<ClearanceSaleController>(
                        builder: (context, clearanceSaleController, child) {
                          return  clearanceSaleController.isLoading ?
                            const Center(
                              child: SizedBox(
                                height:  30, width: 30,
                                child: CircularProgressIndicator(),
                              ),
                            ) :
                           CustomButtonWidget(
                            btnTxt:  getTranslated('update', context),
                             onTap: () {

                               if(skuController.text.isEmpty) {
                                 showCustomToast(message: getTranslated('discount_amount_is', context)!, context:  context, isSuccess: false);
                               } else if (hasVariation && _discountType == 'amount' && PriceConverter.convertAmount(double.tryParse(skuController.text)!, context) < result.minPrice) {
                                 showCustomToast(message: getTranslated('discount_amount_cannot_less_product_price', context)!, context:  context, isSuccess: false);
                               } else if(hasVariation && _discountType == 'amount' && PriceConverter.convertAmount(double.tryParse(skuController.text)!, context) > result.maxPrice) {
                                 showCustomToast(message: getTranslated('discount_amount_cannot_grater_then_product_price', context)!, context:  context, isSuccess: false);
                               } else if(!hasVariation && _discountType == 'amount' && PriceConverter.convertAmount(widget.products.product!.unitPrice ?? 0, context) < double.tryParse(skuController.text)!) {
                                 showCustomToast(message: getTranslated('discount_amount_cannot_grater_then_product_price', context)!, context:  context, isSuccess: false);
                               }else if(_discountType == 'percent' && double.tryParse(skuController.text)! > 100) {
                                 showCustomToast(message: getTranslated('discount_cannot_grater_then', context)!, context:  context, isSuccess: false);
                               } else {
                                 clearanceSaleController.clearanceSaleProductUpdate (
                                     widget.products.product!.id!,
                                     skuController.text,
                                     _discountType == 'percent' ? 'percent' : 'amount'
                                 );
                               }
                             },
                          );
                        }
                      )
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
