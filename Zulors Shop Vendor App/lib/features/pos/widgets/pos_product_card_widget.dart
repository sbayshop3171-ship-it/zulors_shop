import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_product_card_widget.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/product_variation_selection_dialog_widget.dart';

class POSProductWidget extends StatefulWidget {
  final int? index;
  final Product productModel;
  const POSProductWidget({super.key, required this.productModel, this.index});

  @override
  State<POSProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<POSProductWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeMedium, Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeMedium, Dimensions.paddingSizeExtraSmall),
      child: Consumer<ProductController>(
        builder: (context, product,_) {
          return Consumer<CartController>(
            builder: (context, cart,_) {

              if(cart.currentCartModel != null) {
                List<CartModel>? cartModel = [];
                cartModel = cart.currentCartModel?.cart ?? [];

                for(int i=0; i< cartModel.length; i++){
                  if(widget.productModel.id == cartModel[i].product!.id){
                    product.setCartQuantity(cartModel[i].quantity, widget.index!);
                  }
                }
              }

              return GestureDetector(
                onTap: () {
                  if(widget.productModel.variation!.isNotEmpty || (widget.productModel.productType == 'digital' &&  widget.productModel.digitalProductExtensions != null)){
                    showModalBottomSheet(context: context, isScrollControlled: true,
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0),
                        builder: (con) => CartBottomSheetWidget(product: widget.productModel));
                  }
                },
                child: Stack(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05),
                            spreadRadius: 1, blurRadius: 1, offset: const Offset(1,2))]),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Column(children: [
                              Container(decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha:.10),
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                                  width: Dimensions.imageSize,
                                  height: Dimensions.imageSize,
                                  child: Stack(
                                    children: [
                                      ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                          child: CustomImageWidget(image: '${widget.productModel.thumbnailFullUrl?.path}',
                                            width: Dimensions.imageSize, height: Dimensions.imageSize,)),

                                      (widget.productModel.clearanceSale?.discountAmount ?? 0) > 0 ?
                                      const DiscountTagWidget(positionedTop: 5, positionedLeft: 5, positionedRight: 5,) : const SizedBox(),
                                    ],
                                  ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Text(getTranslated(widget.productModel.productType, context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            ],
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),


                          Expanded(flex: 8,
                            child: Padding(padding: const EdgeInsets.all(8.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(widget.productModel.name ?? '', style: robotoRegular.copyWith( color: Theme.of(context).textTheme.bodyLarge?.color),
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: Dimensions.paddingSizeSmall),


                                // InkWell(
                                //   onTap: (){
                                //     print(widget.productModel.clearanceSale?.discountType);
                                //     print(widget.productModel.clearanceSale?.discountAmount);
                                //   },
                                //   child: Text("Text")
                                // ),

                                Row(children: [
                                  Text(PriceConverter.convertPrice(context, widget.productModel.unitPrice,
                                    discountType: (widget.productModel.clearanceSale?.discountAmount ?? 0)  > 0
                                      ? widget.productModel.clearanceSale?.discountType
                                      : widget.productModel.discountType,
                                    discount: (widget.productModel.clearanceSale?.discountAmount ?? 0)  > 0
                                      ? widget.productModel.clearanceSale?.discountAmount
                                      : widget.productModel.discount
                                  ),
                                  style: robotoBold.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),),
                                  const Expanded(child: SizedBox.shrink()),
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Row(
                                  children: [
                                    (widget.productModel.discount! > 0 || (widget.productModel.clearanceSale?.discountAmount ?? 0) > 0) ?
                                    Text(PriceConverter.convertPrice(context, widget.productModel.unitPrice),
                                      maxLines: 1,overflow: TextOverflow.ellipsis,
                                      style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error,
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: Dimensions.fontSizeSmall,
                                      ),): const SizedBox.shrink(),
                                  ],
                                ),

                              ]),
                            ),
                          ),
                        ],),
                    ),
                  (widget.productModel.variation!.isNotEmpty || widget.productModel.digitalProductFileTypes!.isNotEmpty)?
                    Positioned(
                      right:  Provider.of<LocalizationController>(context, listen: false).isLtr? 10 : null, bottom: 10, left:  Provider.of<LocalizationController>(context, listen: false).isLtr?  null : 10,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.add_circle, color: Theme.of(context).primaryColor,size: Dimensions.incrementButton))):

                    Positioned(
                      right:  Provider.of<LocalizationController>(context, listen: false).isLtr? 10 : null, bottom: 10, left:  Provider.of<LocalizationController>(context, listen: false).isLtr?  null : 10,
                      child: Align(
                        child: Consumer<CartController>(
                            builder: (context,cartController,_) {
                              return Row(children: [
                                product.cartQuantity[widget.index!]! > 0?
                                InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: (){
                                    if(product.cartQuantity[widget.index!]! > 1) {
                                      CartModel cartModel = CartModel(widget.productModel.unitPrice, widget.productModel.discount, 1, widget.productModel.tax,null,null,null, null, widget.productModel, widget.productModel.taxModel);
                                      cartController.addToCart(context, cartModel, decreaseQuantity: true);
                                    }
                                  },
                                  child: Icon(Icons.remove_circle, color:product.cartQuantity[widget.index!]! > 1?
                                      Theme.of(context).colorScheme.onPrimary : Theme.of(context).hintColor,
                                      size: Dimensions.incrementButton),
                                ):const SizedBox(),
                                product.cartQuantity[widget.index!]!>0?
                                Center(child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall),
                                  child: Text(product.cartQuantity[widget.index!].toString(), style: robotoRegular.copyWith()),
                                )):const SizedBox(),

                                InkWell(
                                  onTap: (){
                                    if((widget.productModel.currentStock ?? 0) >= 1){
                                      CartModel cartModel = CartModel(widget.productModel.unitPrice, widget.productModel.discount, 1, widget.productModel.tax,null,null,null,null, widget.productModel, widget.productModel.taxModel);
                                      cartController.addToCart(context, cartModel);
                                    } else {
                                      showCustomSnackBarWidget(getTranslated('stock_out', context), context, isToaster: true);
                                    }
                                  },
                                  child: Icon(Icons.add_circle, color: Theme.of(context). primaryColor,size: Dimensions.incrementButton),
                                ),

                              ]);
                            }
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }
}
