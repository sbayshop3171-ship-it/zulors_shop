import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class IconWithTextRowWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final bool bold;
  const IconWithTextRowWidget({super.key,  required this.text, required this.icon, this.iconColor, this.textColor,  this.bold = false});


  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Icon(icon, color: iconColor ?? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.25), size: Dimensions.paddingSizeLarge),
      const SizedBox(width: Dimensions.paddingSizeSmall,),

      Expanded(child: Text(text, maxLines: 2, overflow : TextOverflow.ellipsis, style: bold
          ? robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)
          : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color),
      )),
    ]);
  }
}
