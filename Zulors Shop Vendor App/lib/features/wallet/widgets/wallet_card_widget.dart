import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class WalletCardWidget extends StatelessWidget {
  final String? amount;
  final String? title;
  final Color? color;
  const WalletCardWidget({super.key, this.amount, this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          spreadRadius: -3,
          offset: const Offset(0, 6),
        )],
      ),

      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(amount.toString(), style: robotoBold.copyWith(
          color: color,
          fontSize: Dimensions.fontSizeExtraLargeTwenty,
        )),

        Text(title!,textAlign: TextAlign.center, style: robotoRegular.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.50),
          fontSize: Dimensions.fontSizeSmall,
        )),
      ]),
    );
  }
}