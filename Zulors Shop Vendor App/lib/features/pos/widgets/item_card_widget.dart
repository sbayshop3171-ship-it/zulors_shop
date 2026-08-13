import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';
import 'package:zulors_shop_vendor/helper/debounce_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';


class ItemCartWidget extends StatefulWidget {
  final CartModel? cartModel;
  final int? index;
  final void Function() onChanged;
  const ItemCartWidget({super.key, this.cartModel, this.index, required this.onChanged});

  @override
  State<ItemCartWidget> createState() => _ItemCartWidgetState();
}

class _ItemCartWidgetState extends State<ItemCartWidget> {

  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);



  @override
  Widget build(BuildContext context) {
    double? price;
    if(widget.cartModel?.variation != null){
      price = widget.cartModel?.variation?.price;
    } else if (widget.cartModel?.varientKey != null) {
      price = widget.cartModel?.digitalVariationPrice;
    } else {
      price = widget.cartModel?.price;
    }


    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeMedium),
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          Provider.of<CartController>(context, listen: false).removeFromCart(widget.index!);
          widget.onChanged();
          Provider.of<CartController>(context, listen: false).getTaxAmount();
        },
        child: Container(decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.125),
                  spreadRadius: 0.5, blurRadius: 0.3, offset: const Offset(1,2))]),
          padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeSmall,0,Dimensions.paddingSizeSmall),
          child: Column(children: [
              Row(children: [

                Expanded(flex: 5,
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(height: Dimensions.productImageSize,
                        width: Dimensions.productImageSize,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeBorder),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          child: CustomImageWidget(image: '${widget.cartModel!.product!.thumbnailFullUrl?.path}',
                            placeholder: Images.placeholderImage,
                            fit: BoxFit.cover,
                            width: Dimensions.productImageSize,
                            height: Dimensions.productImageSize),
                        ),),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(child: Text('${widget.cartModel!.product!.name}', maxLines: 1,overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),)),
                    ],
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Consumer<CartController>(
                    builder: (context,cartController,_) {
                      return Row(children: [

                        InkWell(
                          onTap: (){
                            cartController.setQuantity(context,false, widget.index, showToaster: true);
                            widget.onChanged();
                            _debounce.run(
                              () {
                                cartController.getTaxAmount();
                              }
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall - 1),
                            child: Icon(Icons.remove_circle, size: Dimensions.incrementButton,
                                color:widget.cartModel!.quantity!>1? Theme.of(context).colorScheme.onPrimary:Theme.of(context).hintColor),
                          ),
                        ),

                        Center(child: Text(widget.cartModel!.quantity.toString(),
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))
                        ),

                        InkWell(
                          onTap: (){
                            cartController.setQuantity(context,true, widget.index, showToaster: true);
                            widget.onChanged();
                            _debounce.run(
                              () {
                                cartController.getTaxAmount();
                              }
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall - 1),
                            child: Icon(Icons.add_circle, size: Dimensions.incrementButton, color: Theme.of(context).primaryColor),
                          ),
                        ),

                      ],);
                    }
                  ),
                ),

                Expanded(flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                        child: Text(PriceConverter.convertPrice(context, price!),
                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      )
                    ],
                  )
                ),

              ],),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            ],
          ),
        ),
      ),
    );
  }
}
