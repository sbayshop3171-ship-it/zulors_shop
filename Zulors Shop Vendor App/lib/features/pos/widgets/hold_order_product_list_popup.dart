import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class HoldOrderProductListPopup extends StatelessWidget {
  final List<CartModel>? cart;
  const HoldOrderProductListPopup({super.key, this.cart});

  @override
  Widget build(BuildContext context) {
    return Dialog( surfaceTintColor: Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha:0.15),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Dimensions.radiusDefault),
              topLeft: Radius.circular(Dimensions.radiusDefault),
            ),
          ),
          child: Row(mainAxisAlignment : MainAxisAlignment.center, children: [
            Text('${getTranslated('product_list', context)}',
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            ],
          )
        ),


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart!.length,
            itemBuilder: (context, index) {
              double productPrice = Provider.of<CartController>(context, listen: false).calculateProductPrice(cart![index]);

              String varientKey = '';

              if(cart![index].variant != null && cart![index].variant != '') {
                varientKey = cart![index].variant ?? '';
              } else if (cart![index].varientKey != null && cart![index].varientKey != '') {
                varientKey = cart![index].varientKey ?? '';
              }

                return SizedBox(
                  height: 90,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImageWidget(image: '${cart![index].product?.thumbnailFullUrl?.path}',
                          width: Dimensions.imageSize, height: Dimensions.imageSize,),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(cart![index].product?.name ?? '',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text('1 ${cart![index].product!.unit ?? ''}',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),


                            Text(varientKey,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),

                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Text( 'x' '${cart![index].quantity}',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Text(PriceConverter.convertPrice(context, productPrice),
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),


                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(color: Theme.of(context).hintColor.withValues(alpha:0.50));
              },
            ),
        )

        ],
      ),
    );
  }
}
