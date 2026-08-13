import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class BalanceStatementWidget extends StatelessWidget {
  final String? text;
  final String? icon;
  final Color? color;
  final double? amount;
  const BalanceStatementWidget({super.key, this.text, this.icon, this.color, this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null?
          SizedBox(width: Dimensions.iconSizeDefault,
              child: Image.asset(icon!)): const SizedBox(),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(text!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
          const Spacer(),
          Container(decoration: BoxDecoration(
              color: color!.withValues(alpha:.10),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge)
          ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeExtraSmall),
              child: Text(PriceConverter.convertPrice(context, amount),
                  style: robotoRegular.copyWith(color : color)),
            ),
          )


        ],
      ),
    );
  }
}
