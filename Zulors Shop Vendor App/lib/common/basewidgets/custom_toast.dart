import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final SnackBarType sanckBarType;

  const CustomToast({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xE608AE61),
    // sanckBarType == SnackBarType.success ?  Color(0xE608AE61) : sanckBarType == SnackBarType.warning ?  Color(0xE6334257) :  Color(0xE6334257),
    this.textColor = Colors.white,
    this.borderRadius = 30,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    required this.sanckBarType
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: sanckBarType == SnackBarType.success ? const  Color(0xE608AE61) : sanckBarType == SnackBarType.warning ? const Color(0xE6334257) : const Color(0xE6334257),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
                Image.asset(sanckBarType == SnackBarType.success ? Images.snackbarTickmark :
                sanckBarType == SnackBarType.warning ? Images.snackbarWarning :  Images.snackbarError,
                width: 17, height: 17),

                const SizedBox(width: Dimensions.paddingSizeSmall),
                Flexible(child: Text(text, style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: textColor), maxLines: 3)),
              ],
            ),
          ),
          ),
        ),
    );
  }
}
