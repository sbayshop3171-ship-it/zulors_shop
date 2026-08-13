import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ThirdPartyDeliveryInfoWidget extends StatelessWidget {
  final Order? orderModel;
  const ThirdPartyDeliveryInfoWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: ThemeShadow.getShadow(context)

      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getTranslated('third_party_information', context)!,
            style: robotoMedium.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
              fontSize: Dimensions.fontSizeLarge,)),
        const SizedBox(height: Dimensions.paddingSizeDefault),


        Row(children: [
          // ClipRRect(borderRadius: BorderRadius.circular(50),
          //   child: const CustomImageWidget( height: 50,width: 50, fit: BoxFit.cover,
          //       image: '')),
          // const SizedBox(width: Dimensions.paddingSizeSmall),


          Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(
              children: [
                Text('${getTranslated('third_party_delivery_service', context)!} : ',
                  style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!,
                  fontSize: Dimensions.fontSizeDefault)
                ),

                Text(orderModel?.thirdPartyServiceName ?? '',
                  style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                  fontSize: Dimensions.fontSizeDefault)
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            Row(
              children: [
                Text('${getTranslated('third_party_delivery_tracking_id', context)!} : ',
                  style: titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!,
                  fontSize: Dimensions.fontSizeDefault)
                ),

                Text(orderModel?.thirdPartyTrackingId ?? '',
                  style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                  fontSize: Dimensions.fontSizeDefault)
                ),
              ],
            ),



          ],))
        ],
        )
      ]),
    );
  }
}
