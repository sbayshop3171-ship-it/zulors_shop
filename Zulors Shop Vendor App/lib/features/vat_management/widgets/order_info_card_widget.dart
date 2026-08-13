import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class OrderInfoCardWidget extends StatelessWidget {
  final String infoName;
  final String? amount;
  final String image;
  final Color? color;
  const OrderInfoCardWidget({super.key, required this.infoName, this.amount, required this.image, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.1) ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

        CustomAssetImageWidget(image, color: color),
        SizedBox(height: Dimensions.paddingSizeSmall),

        Text(amount ?? '0', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700, color: color)),

        Text(infoName, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8))),
      ]),
    );
  }
}
