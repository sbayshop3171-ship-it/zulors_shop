import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'custom_toast.dart';

enum SnackBarType {
  error,
  warning,
  success,
}

void showCustomSnackBarWidget(String? message, BuildContext? context, {bool isError = true, bool isToaster = false, SnackBarType sanckBarType = SnackBarType.success}) {
    final scaffold = ScaffoldMessenger.of(context ?? Get.context!);
    scaffold.showSnackBar(
      SnackBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        content: CustomToast(text: message ?? '', sanckBarType: sanckBarType),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
}


void showCustomToast({bool isSuccess = true, required String message, required BuildContext context}) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isSuccess ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error,
      textColor: Colors.white,
      fontSize: Dimensions.fontSizeDefault
  );
}