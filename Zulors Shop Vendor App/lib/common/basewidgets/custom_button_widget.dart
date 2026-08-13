import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onTap;
  final String? btnTxt;
  final bool isColor;
  final Color? backgroundColor;
  final Color? fontColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? buttonHeight;
  final double? textSize;
  final bool isLoading;
  final TextStyle? textStyle;

  const CustomButtonWidget({
    super.key, this.onTap,
    required this.btnTxt,
    this.backgroundColor,
    this.isColor = false,
    this.fontColor,
    this.borderRadius,
    this.borderColor,
    this.buttonHeight = 40,
    this.textSize = Dimensions.fontSizeDefault,
    this.isLoading = false, this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
       SizedBox(
        height: 15, width: 15,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          strokeWidth: 2,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Text(getTranslated('loading', context)!, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),

    ])) : GestureDetector(
      onTap: onTap as void Function()?,
      child: Container( height: buttonHeight, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isColor? backgroundColor : backgroundColor ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(borderRadius != null? borderRadius! : Dimensions.radiusDefault),
          border: Border.all(color: borderColor ?? Theme.of(context).cardColor)
        ),
        child: Text(btnTxt!,
            style: textStyle ?? robotoBold.copyWith(
              fontSize: textSize,
              color: fontColor ?? Colors.white,
            )),
      ),
    );
  }
}
