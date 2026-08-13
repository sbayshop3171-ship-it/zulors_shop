import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class DropdownDecoratorWidget extends StatelessWidget {
  final String? title;
  final Widget child;
  const DropdownDecoratorWidget({super.key, this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(width: .5, color: Theme.of(context).primaryColor.withValues(alpha:.25))
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye),
            child: child,
          ),
        ),
      ),

      (title?.isNotEmpty ?? false) ?
      Positioned(top: 0, left: Dimensions.paddingSizeMedium, child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
        child: Text(getTranslated(title, context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
      )) : const SizedBox.shrink(),
    ]);
  }
}
