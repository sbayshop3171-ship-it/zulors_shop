import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ChangeAmountWidget extends StatelessWidget {
  final double amount;
  final String currency;
  const ChangeAmountWidget({super.key, required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {

    return amount == 0 ? const SizedBox() : Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: .1),
              border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .125),),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: getTranslated('please_ensure_the_deliveryman_has', context), style: titilliumRegular),

                TextSpan(text: ' $amount $currency ', style: robotoBold),

                TextSpan(text: getTranslated('in_change_ready_for_the_customer', context),  style: titilliumRegular),
              ],
            ),
          ),
        ),
      );
  }
}
