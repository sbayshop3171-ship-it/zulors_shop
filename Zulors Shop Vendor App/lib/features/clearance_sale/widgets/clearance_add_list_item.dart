import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_product_distount_text_field_widget.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ClearanceAddListItem extends StatefulWidget {
  final Product product;
  final Function(String text)? onDiscountTypeChanged;
  final int index;
  final TextEditingController? skuController;
  const ClearanceAddListItem({super.key, required this.product, this.onDiscountTypeChanged, required this.index, this.skuController});

  @override
  State<ClearanceAddListItem> createState() => _ClearanceAddListItemState();
}

class _ClearanceAddListItemState extends State<ClearanceAddListItem> {
  bool hasVariation = false;
  var result;
  String? errorText;
  bool? isWrongAmount;

  @override
  void initState() {
    if(widget.product.variation != null && widget.product.variation!.isNotEmpty) {
      hasVariation = true;
      result = Provider.of<ClearanceSaleController>(Get.context!, listen: false).getMinMaxValues(widget.product.variation ?? []);
    }
    errorText = getTranslated('discount_amount_is', Get.context!);
    isWrongAmount = true;

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ClearanceSaleController>(
        builder: (context, clearanceSaleController, child) {
        return  Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall, top: Dimensions.fontSizeSmall),
              child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.05), width: .75)
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            child: CustomImageWidget(
                                image: widget.product.thumbnailFullUrl?.path ?? '')),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),


                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.product.name ?? '',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Row(
                              children: [
                                Text(PriceConverter.convertPrice(context,
                                    widget.product.unitPrice,
                                    discountType: widget.product.discountType,
                                    discount: widget.product.discount
                                ), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                widget.product.discount! > 0 ?
                                Text(PriceConverter.convertPrice(context, widget.product.unitPrice),
                                  maxLines: 1,overflow: TextOverflow.ellipsis,
                                  style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),): const SizedBox.shrink(),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Wrap(
                              children: [
                                Text('${getTranslated('category', context)!} : ',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                ),

                                Text(widget.product.category?.name ?? '',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                ),

                                Text(' | ',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                ),

                                if(widget.product.productType == 'physical')

                                  ...[
                                    Text('${getTranslated('brand', context)!} : ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),

                                    Text(widget.product.brand?.name ?? '',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                    ),

                                    Text(' | ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),
                                  ],


                                if(widget.product.productType == 'physical')...[
                                  Text('${getTranslated('stock', context)!} : ',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                  ),

                                  Text(widget.product.currentStock.toString(),
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                  ),
                                ]

                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            if (clearanceSaleController.clearanceConfigModel?.discountType == 'product_wise')...[
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              ClearanceProductDiscountTextFieldWidget(
                                  formProduct: true,
                                  border: true,
                                  controller: clearanceSaleController.clearanceSaleAddModel[widget.index].amountController,
                                  textInputAction: TextInputAction.done,
                                  textInputType: TextInputType.number,
                                  isAmount: false,
                                  hintText: getTranslated('discount_amount', context)!,
                                  onChanged: (value) {
                                    TextEditingController controller =  clearanceSaleController.clearanceSaleAddModel[widget.index].amountController;
                                    String discountType =  clearanceSaleController.clearanceSaleAddModel[widget.index].type!;

                                    _validateDiscountAmount(controller, context, clearanceSaleController, discountType);

                                  },
                                  onDiscountTypeChanged : (String value) {
                                    clearanceSaleController.setSelectedProductDiscountType(widget.index, value);


                                    TextEditingController controller =  clearanceSaleController.clearanceSaleAddModel[widget.index].amountController;
                                    String discountType =  clearanceSaleController.clearanceSaleAddModel[widget.index].type!;

                                    _validateDiscountAmount(controller, context, clearanceSaleController, discountType);

                                  }
                              ),
                            ],


                            if(isWrongAmount! && clearanceSaleController.clearanceConfigModel?.discountType ==  'product_wise')...[
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Text(errorText ?? '',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error), maxLines: 2,
                              ),
                            ]


                          ],
                        ),
                      ),

                    ],
                  )
              ),
            ),

            Positioned(
              top: 2, right: 10,
              child: InkWell(
                onTap: () {
                  clearanceSaleController.removeSelectedProduct(widget.index);
                },
                child: Container(
                  height: 25, width: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.error
                  ),
                  child: Icon(Icons.close, size: 17, color: Theme.of(context).cardColor),
                ),
              )
            ),
          ],
        );
      }
    );
  }

  void _validateDiscountAmount(TextEditingController controller, BuildContext context, ClearanceSaleController clearanceSaleController, String discountType) {
    if(controller.text.isEmpty) {
      setState(() {
        errorText = getTranslated('discount_amount_is', context);
        isWrongAmount = true;
        clearanceSaleController.clearanceSaleAddModel[widget.index].isWrongAmount = true;
      });
    } else if (hasVariation && discountType == 'amount' && double.tryParse(controller.text)! < PriceConverter.convertAmount(result.minPrice, context)) {
      setState(() {
        errorText = getTranslated('discount_amount_cannot_less_product_price', context);
        isWrongAmount = true;
        clearanceSaleController.clearanceSaleAddModel[widget.index].isWrongAmount = true;
      });
    } else if(hasVariation && discountType == 'amount' && double.tryParse(controller.text)! > PriceConverter.convertAmount(result.maxPrice, context)) {
      setState(() {
        errorText = getTranslated('discount_amount_cannot_grater_then_product_price', context);
        isWrongAmount = true;
        clearanceSaleController.clearanceSaleAddModel[widget.index].isWrongAmount = true;
      });
    } else if(!hasVariation && discountType == 'amount' && PriceConverter.convertAmount(widget.product.unitPrice ?? 0, context) < double.tryParse(controller.text)!) {
      setState(() {
        errorText = getTranslated('discount_amount_cannot_grater_then_product_price', context);
        isWrongAmount = true;
        clearanceSaleController.clearanceSaleAddModel[widget.index].isWrongAmount = true;
      });
    }else if(discountType == 'percent' && double.tryParse(controller.text)! > 100) {
      setState(() {
        errorText = getTranslated('discount_cannot_grater_then', context);
        isWrongAmount = true;
        clearanceSaleController.clearanceSaleAddModel[widget.index].isWrongAmount = true;
      });
    } else {
      setState(() {
        isWrongAmount = false;
        clearanceSaleController.clearanceSaleAddModel[widget.index].isWrongAmount = false;
      });
    }
  }
}
