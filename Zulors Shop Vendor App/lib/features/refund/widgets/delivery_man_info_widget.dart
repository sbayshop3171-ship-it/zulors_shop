import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryManInfoWidget extends StatelessWidget {
  final RefundController? refundReq;
  const DeliveryManInfoWidget({super.key, this.refundReq});

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(color: Theme.of(context).cardColor,
        boxShadow: ThemeShadow.getShadow(context),
       ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getTranslated('deliveryman_contact_details', context)!,
            style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: Dimensions.paddingSizeMedium),

        Row(children: [ClipRRect(borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
              errorWidget: (ctx, url, err) => Image.asset(Images.placeholderImage, height: 50,width: 50, fit: BoxFit.cover),
              placeholder: (ctx, url) => Image.asset(Images.placeholderImage,height: 50,width: 50, fit: BoxFit.cover),
              imageUrl: '${Provider.of<SplashController>(context, listen: false).
              baseUrls!.deliveryManImageUrl}/${refundReq!.refundDetailsModel!.deliverymanDetails!.image}',
              height: 50,width: 50, fit: BoxFit.cover),),
          const SizedBox(width: Dimensions.paddingSizeLarge),

          Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text(
              '${refundReq!.refundDetailsModel!.deliverymanDetails!.fName ?? ''} '
                  '${refundReq!.refundDetailsModel!.deliverymanDetails!.lName ?? ''}',
              style: robotoMedium.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),

            InkWell(
              onTap: () => _launchUrl(Platform.isIOS? 'tel://${refundReq!.refundDetailsModel!.deliverymanDetails!.phone!}' : 'tel:${refundReq!.refundDetailsModel!.deliverymanDetails!.phone!}'),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Image.asset(Images.phone),),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text('${refundReq!.refundDetailsModel!.deliverymanDetails!.phone}', style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeDefault,
                  )),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            InkWell(
              onTap: () async {
                final Uri email =  Uri(
                  scheme: 'mailto',
                  path: refundReq!.refundDetailsModel!.deliverymanDetails!.email ?? '',
                );

                await launchUrl(email, mode: LaunchMode.externalApplication);
              },
              child: Row(children: [
                SizedBox(width: 20, child: Image.asset(Images.email),),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Text(refundReq!.refundDetailsModel!.deliverymanDetails!.email ?? '', style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                )),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          ])),
        ]),
      ]),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}