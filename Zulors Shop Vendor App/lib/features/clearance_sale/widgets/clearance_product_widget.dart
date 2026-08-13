import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/models/clearnace_sale_product_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_product_update_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/delete_confiramation_dialog_widget.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ClearanceProductWidget extends StatefulWidget {
  final Products products;
  final int? index;
  const ClearanceProductWidget({required this.products, this.index, super.key});

  @override
  State<ClearanceProductWidget> createState() => _ClearanceProductWidgetState();
}

class _ClearanceProductWidgetState extends State<ClearanceProductWidget> {


  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    bool showAmountAlert = false;

    if(widget.products.product?.clearanceSale?.discountType == 'flat' || widget.products.product?.clearanceSale?.discountType == 'amount') {
      double minVariationPrice = (widget.products.product?.variation != null && widget.products.product!.variation!.isNotEmpty)
          ? Provider.of<ClearanceSaleController>(Get.context!, listen: false).getVariationMinimumPrice(
          digitalVariation: null, physicalVariation: widget.products.product!.variation)
          : (widget.products.product?.digitalVariation != null && widget.products.product!.digitalVariation!.isNotEmpty)
          ? Provider.of<ClearanceSaleController>(Get.context!, listen: false).getVariationMinimumPrice(
          digitalVariation: widget.products.product!.digitalVariation, physicalVariation: null) : 0;

      if(minVariationPrice == 0) {
        minVariationPrice = widget.products.product!.unitPrice!;
      }

      String discountedPrice =  PriceConverter.convertPriceWithoutSymbol(context, widget.products.product!.unitPrice,
        discountType: (widget.products.product?.clearanceSale?.discountAmount ?? 0)  > 0
          ? widget.products.product!.clearanceSale?.discountType : 'flat',
        discount: (widget.products.product?.clearanceSale?.discountAmount ?? 0)  > 0
          ? widget.products.product!.clearanceSale?.discountAmount
          : 0);



      if(double.parse(discountedPrice) < minVariationPrice && (0 > double.parse(discountedPrice)) ) {
        showAmountAlert = true;
      }
    }


    return Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
      child: Slidable(
        key: const ValueKey(0),
        endActionPane: ActionPane(extentRatio: .25,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (value) {
                  showDialog(context: context, builder: (_)=> DeleteConfirmationDialogWidget(widget.products.productId, widget.index));
                },
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0.30),
                foregroundColor: Theme.of(context).colorScheme.error,
                icon: CupertinoIcons.delete_solid,  // l
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(Dimensions.radiusDefault),
                  bottomRight: Radius.circular(Dimensions.radiusDefault),
                ),// abel: getTranslated('delete', context)
              )
            ]
        ),

        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).highlightColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                            image: widget.products.product?.thumbnailFullUrl?.path ?? '')),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: Text(widget.products.product?.name ?? '',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),



                    Consumer<ClearanceSaleController>(
                      builder: (context, clearanceController, child) {
                        return PopupMenuButton<int>(
                          icon:  Container(
                            height: 35, width: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: Theme.of(context).cardColor,
                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)
                            ),
                            child: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
                          ),
                          offset: const Offset(0, 40),
                          onSelected: (value) {

                            if(value == 2) {
                              showDialog(context: context, builder: (_)=> ClearanceProductUpdateWidget(widget.products));
                            } else if (value == 3) {
                              showDialog(context: context, builder: (_)=> DeleteConfirmationDialogWidget(widget.products.productId, widget.index));
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(getTranslated('statuss', context)!,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                  ),

                                  const SizedBox(width: 25),

                                  Consumer<ClearanceSaleController>(
                                    builder: (context, clearanceController, child) {
                                      return FlutterSwitch(width: 40.0, height: 20.0, toggleSize: 18.0,
                                        value: widget.products.isActive == 1,
                                        borderRadius: 20.0,
                                        activeColor: Theme.of(context).primaryColor,
                                        padding: 1.0,
                                        onToggle:(bool isActive) {
                                          if(showAmountAlert) {
                                            showCustomSnackBarWidget(getTranslated("your_products_unit", context), context, isError: false, sanckBarType: SnackBarType.warning);
                                          } else {
                                            clearanceController.updateClearanceSaleProductStatus(widget.products.productId!, isActive ? 1 : 0, widget.index!);
                                          }

                                        },
                                      );
                                    }
                                  ),
                                ],
                              ),
                            ),


                            if (clearanceController.clearanceConfigModel?.discountType != 'flat' )...[
                              PopupMenuItem(
                                value: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(getTranslated('edit_discount', context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                    ),
                                    const SizedBox(width: 10),

                                    Icon(Icons.edit, color: Theme.of(context).primaryColor),
                                  ],
                                ),
                              )
                            ],

                            PopupMenuItem(
                              value: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(getTranslated('delete_product', context)!,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),

                  ],
                ),
              ),



              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(children: [

                                Text(PriceConverter.convertPrice(context, widget.products.product?.unitPrice,
                                   discountType: (widget.products.product?.clearanceSale?.discountAmount ?? 0)  > 0
                                     ? widget.products.product?.clearanceSale?.discountType
                                     : widget.products.product?.discountType,
                                   discount: (widget.products.product?.clearanceSale?.discountAmount ?? 0)  > 0
                                     ? showAmountAlert ? 0 :  widget.products.product?.clearanceSale?.discountAmount
                                     : widget.products.product?.discount
                                ), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),


                                widget.products.product!.discount! > 0  || ((widget.products.product!.clearanceSale?.discountAmount ?? 0) > 0) ? showAmountAlert
                                ? const SizedBox() :
                                Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: Text(PriceConverter.convertPrice(context, widget.products.product!.unitPrice),
                                    maxLines: 1,overflow: TextOverflow.ellipsis,
                                    style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha:0.50),
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Theme.of(context).primaryColor.withValues(alpha:0.50),
                                      fontSize: Dimensions.fontSizeDefault,
                                    )),
                                ) : const SizedBox.shrink(),


                                showAmountAlert ?
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: JustTheTooltip(
                                    backgroundColor: Colors.black87,
                                    controller: tooltipController,
                                    preferredDirection: AxisDirection.up,
                                    tailLength: 10,
                                    tailBaseWidth: 20,
                                    content: Container(width: 250,
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                      child: Text(getTranslated('your_products_unit', context)!,
                                      style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault))
                                    ),
                                    child: InkWell(
                                      onTap: ()=>  tooltipController.showTooltip(),
                                      child: Image.asset(Images.discountAlertIcon, height: 15, width: 15,))),
                                ) : const SizedBox(),
                              ]),

                            Wrap(
                              children: [
                                Text('${getTranslated('category', context)!} : ',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor
                                  ), maxLines: 2,
                                ),

                                Text(widget.products.product!.category?.name ?? '',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                ),


                                if(widget.products.product?.productType == 'physical')
                                  ...[
                                    Text(' | ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),

                                    Text('${getTranslated('brand', context)!} : ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),

                                    Text(widget.products.product?.brand?.name ?? '',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                    ),
                                  ],


                                if(widget.products.product?.productType == 'physical')
                                  ...[
                                    Text(' | ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),

                                    Text('${getTranslated('stock', context)!} : ',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                    ),

                                    Text(widget.products.product?.currentStock.toString() ?? '0',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                    ),
                                  ],
                              ],
                            ),
                          ],
                        )
                    ),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Theme.of(context).primaryColor.withValues(alpha:0.05),
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: 1)
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(widget.products.discountType == 'percentage' ?  '${widget.products.discountAmount}%' : PriceConverter.convertPrice(context, widget.products.discountAmount),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge), maxLines: 2,
                        ),

                        Text(getTranslated('discount', context)!,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor), maxLines: 2,
                        ),
                      ]),
                    ),
                  ],
                ),
              ),



            ],
          )
        ),
      ),
    );
  }
}
