import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_loader_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product_details/screens/product_details_screen.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/features/restock/domain/models/restock_product_model.dart';
import 'package:zulors_shop_vendor/features/restock/widgets/quantity_update_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/restock/widgets/restock_bottom_sheet.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class RestockListItemWidget extends StatefulWidget {
  final Product? product;
  final double? ratting;
  final Data? data;
  final int index;
  const RestockListItemWidget({super.key, this.product, this.ratting, this.data, required this.index});

  @override
  State<RestockListItemWidget> createState() => _RestockListItemWidgetState();
}

class _RestockListItemWidgetState extends State<RestockListItemWidget> {
  late TextEditingController? _stockQuantityController;

  @override
  void initState() {
    _stockQuantityController = TextEditingController(text: widget.product?.currentStock.toString() ?? '0');
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        InkWell(
          onTap: () {
            // Navigator.push(context, PageRouteBuilder(transitionDuration: const Duration(milliseconds: 1000),
            //   pageBuilder: (context, anim1, anim2) => ProductDetails(productId: product?.id,
            //   slug: product?.slug)));
          },

          child: Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
            child: Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)
              ),

              child: Column(
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.10),width: 0.5)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          child: CustomImageWidget(image: widget.product?.thumbnailFullUrl?.path ?? '', height: 84, width: 84))
                    ),

                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          children: [
                            Flexible(
                              child: InkWell(
                                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductDetailsScreen(productModel: widget.product))),
                                child: Text(widget.product?.name ?? '', maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        // Price
                        Row(
                          children: [
                            Text(PriceConverter.convertPrice(context,
                                widget.product?.unitPrice, discountType: widget.product?.discountType,
                                discount: widget.product?.discount),
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
                            ),
                          ],
                        ),



                        // variation
                        //(widget.data?.variant != null && widget.data!.variant!.isNotEmpty) ?
                        Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            Text('${getTranslated('total_request', context)!} : ',
                              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)
                            ),
                            Text('${widget.data?.restockProductCustomersCount ?? 0}' , maxLines: 1,overflow: TextOverflow.ellipsis,
                              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).colorScheme.onTertiaryContainer))])
                        )
                            //: const SizedBox(),
                      ],
                      ),
                    ),
                  ]),

                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Row(children: [
                        Text('${getTranslated('last_request', context)!} : ',
                            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)
                        ),
                        Text(DateConverter.isoStringToLocalDateAndTime(widget.data!.updatedAt!), maxLines: 1,overflow: TextOverflow.ellipsis,
                            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodySmall!.color))])
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
            bottom : 50, right: 30,
            child:  Consumer<RestockController>(
                builder: (context, restockProvider, _) {
                  return InkWell(
                    onTap: () async {
                      showDialog(context: context, builder: (ctx)  => const CustomLoaderWidget());
                      await restockProvider.deleteRestockListItem(widget.data!.id!, widget.index);
                      Navigator.of(Get.context!).pop();
                    },
                    child: Container(
                      height: 30, width: 30,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeOrder+1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        border: Border.all(color: Theme.of(context).colorScheme.error, width: 0.5)
                      ),
                      child: Image.asset(Images.delete),
                    ),
                  );
                }
            )
        ),

        Positioned(
          bottom : 10, right: 30,
          child:  Consumer<RestockController>(
            builder: (context, restockProvider, _) {
              return Consumer<AddProductController>(
                builder: (context, productProvider, _) {
                  return Consumer<VariationController>(
                    builder: (context, variationController, _) {
                      return InkWell(
                        onTap: () {
                          if (widget.product!.variation != null && widget.product!.variation!.isNotEmpty) {
                            _stockQuantityController!.text = widget.product?.currentStock.toString() ?? '0';
                            showModalBottomSheet(context: context, isScrollControlled: true,
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0),
                              builder: (con) => RestockSheetWidget(
                                stockQuantityController: _stockQuantityController,
                                product: widget.product,
                                title: getTranslated('product_variations', context),
                                variantKeys: widget.data?.variantKeys ?? [],
                                onYesPressed: () {
                                  bool isEmpty = false;

                                  if(variationController.variantTypeList.isNotEmpty){
                                    for (int i=0; i< variationController.variantTypeList.length; i++) {
                                      if(variationController.variantTypeList[i].qtyController.text == '' && !isEmpty) {
                                        isEmpty = true;
                                      }
                                    }
                                  }

                                  if(isEmpty) {
                                    showCustomSnackBarWidget('variation_quantity_is_required', sanckBarType: SnackBarType.error, context);
                                  } else if(_stockQuantityController!.text.toString().isEmpty){
                                    showCustomSnackBarWidget('product_quantity_is_required', context);
                                    if (kDebugMode) {
                                      print(widget.product!.id);
                                    }
                                  }else {
                                    restockProvider.updateRestockProductQuantity(context, widget.product?.id, int.parse(_stockQuantityController!.text.toString()), widget.product!.variation!, index: widget.index);
                                  }
                                }
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return QuantityUpdateDialogWidget (
                                  stockQuantityController: _stockQuantityController,
                                  product: widget.product,
                                  title: getTranslated('product_variations', context),
                                  onYesPressed: () {
                                     if(_stockQuantityController!.text.toString().isEmpty){
                                      showCustomSnackBarWidget('product_quantity_is_required', context);
                                      if (kDebugMode) {
                                        print(widget.product?.id);
                                      }
                                    }else{
                                      productProvider.updateRestockProductQuantity(context, widget.product?.id, int.parse(_stockQuantityController!.text.toString()), widget.product!.variation!, index: widget.index);
                                    }
                                  }
                                );
                              },
                            );
                          }
                        },

                        child: Container(
                          height: 30, width: 30,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeOrder),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                              border: Border.all(color: Theme.of(context).primaryColor, width: 0.5)
                          ),
                          child: Image.asset(Images.updateQuantityIcon),
                        ),
                      );
                    }
                  );
                }
              );
            }
          )
        )



      ],
    );
  }
}
