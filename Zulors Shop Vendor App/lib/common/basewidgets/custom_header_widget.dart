import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class CustomHeaderWidget extends StatelessWidget {
  final String headerImage;
  final String? title;
  const CustomHeaderWidget({super.key, required this.title, required this.headerImage});

  @override
  Widget build(BuildContext context) {
    return Container( color: Theme.of(context).primaryColor.withValues(alpha:0.06), child: Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row( mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(headerImage, height: 30),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text(title!, style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).primaryColor,
          ),),
        ],
      ),
    ),);
  }
}
