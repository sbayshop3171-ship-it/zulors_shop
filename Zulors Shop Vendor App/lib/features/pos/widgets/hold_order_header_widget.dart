import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class HoldOrderHeaderWidget extends StatelessWidget {
  const HoldOrderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
        builder: (context, cartController, _ ){
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  children: [
                    Text(getTranslated('hold_orders', context)!,
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: (BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.error,
                      )),
                      child: Text((cartController.customerCartList.length).toString(),
                          style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).cardColor)),
                    )
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(getTranslated('your_hold_orders', context)!,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ]),
            ),

            InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.only(
                  top: Dimensions.paddingSizeSmall,
                  bottom: Dimensions.paddingSizeSmall,
                  left: Dimensions.paddingSizeSmall,
                ),
                child: Icon(Icons.close, size: 25))
            ),

          ],
        );
      }
    );
  }
}
