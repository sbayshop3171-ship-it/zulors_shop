import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';


class CustomerInfoWidget extends StatelessWidget {
  final RefundModel? refundModel;
  const CustomerInfoWidget({super.key, this.refundModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 7,
          )]
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(children: [
          const CustomAssetImageWidget(Images.personImage, width: Dimensions.iconSizeSmall),
          const SizedBox(width: Dimensions.paddingEye),

          Text(getTranslated('customer_information', context)!, style: robotoMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Divider(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.10), height: 1, thickness: 1),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(crossAxisAlignment: CrossAxisAlignment.start,children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CustomImageWidget(width: 70, height: 70, image: '${refundModel!.customer!.imageFullUrl?.path}'),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('${refundModel!.customer!.fName ?? ''} ${refundModel!.customer!.lName ?? ''}', style: robotoMedium.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeDefault,
            )),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            refundModel?.customer?.id != 0 ?
            InkWell(
              onTap: () =>  _launchUrl(Platform.isIOS? 'tel://${refundModel!.customer!.phone}' : 'tel:${refundModel!.customer!.phone}'),
              child: Row(children: [
                SizedBox(width: Dimensions.iconSizeSmall, child: Image.asset(Images.phone, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text('${refundModel!.customer!.phone}', style: titilliumRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  fontSize: Dimensions.fontSizeDefault,
                )),
              ]),
            ) : const SizedBox(),

            refundModel?.customer?.id != 0 ?
            const SizedBox(height: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

            refundModel?.customer?.id != 0 ?
            InkWell(
              onTap: () {},
              child: Row(children: [
                SizedBox(width: Dimensions.iconSizeSmall, child: Image.asset(Images.email, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(refundModel!.customer!.email ?? '', style: titilliumRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  fontSize: Dimensions.fontSizeDefault,
                )),
              ]),
            ) : const SizedBox(),

          ])),
        ])
      ]),
    );
  }
}


Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}