import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';


class CustomerContactWidget extends StatelessWidget {
  final Order? orderModel;
  const CustomerContactWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: ThemeShadow.getShadow(context)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        orderModel!.isGuest! ?
        Text('${getTranslated('customer_information', context)} (${getTranslated('guest_customer', context)})',
            style: robotoMedium.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
              fontSize: Dimensions.fontSizeLarge,)):
        Text('${getTranslated('customer_information', context)}',
            style: robotoMedium.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
              fontSize: Dimensions.fontSizeLarge,)),
        const SizedBox(height: Dimensions.paddingSizeDefault),


        Row( mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(50),
            child: CustomImageWidget( height: 50,width: 50, fit: BoxFit.cover,
            image: '${orderModel?.customer?.imageFullPath?.path}')),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(orderModel!.isGuest! ? '${orderModel!.shippingAddressData != null? orderModel!.shippingAddressData?.contactPersonName :
            '${orderModel?.billingAddressData?.contactPersonName}'}' :
            '${orderModel!.customer?.fName ?? ''} ''${orderModel!.customer?.lName ?? ''}',
                style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                    fontSize: Dimensions.fontSizeDefault)),

            const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            if (orderModel?.customerId != 0)
            Row(
              children: [
                Image.asset(Images.phone, width: 15),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(orderModel!.isGuest! ? '${orderModel!.shippingAddressData != null? orderModel!.shippingAddressData?.phone :
                '${orderModel?.billingAddressData?.phone}'}' :
                '${orderModel!.customer?.phone}',
                    style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                        fontSize: Dimensions.fontSizeDefault)),
              ],
            ),

            if (orderModel?.customerId != 0)
            const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            if (orderModel?.customerId != 0)
            Row(
              children: [
                Image.asset(Images.email, width: 15),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                orderModel!.isGuest! ?
                Text('${orderModel!.shippingAddressData != null? orderModel!.shippingAddressData?.email :
                '${orderModel?.billingAddressData?.email}'}',
                    style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                        fontSize: Dimensions.fontSizeDefault)):
                Text(orderModel!.customer?.email ?? '',
                    style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                        fontSize: Dimensions.fontSizeDefault)),
              ],
            ),

            ],))
        ],
        )
      ]),
    );
  }
}
