import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/custom_toast.dart';
import 'package:zulors_shop/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

 void showCustomSnackBar(String? message, BuildContext context, {bool isError = true, bool isToaster = false}) {
   Fluttertoast.showToast(
     msg: message!,
     toastLength: Toast.LENGTH_SHORT,
     gravity: ToastGravity.BOTTOM,

     timeInSecForIosWeb: 1,
     backgroundColor: isError ? const Color(0xFFFF0014) : const Color(0xFF1E7C15),
     textColor: Colors.white,
     fontSize: 16.0
   );
}

enum SnackBarType {
  error,
  warning,
  success,
}

void showCustomSnackBarWidget(String? message, BuildContext? context, {SnackBarType snackBarType = SnackBarType.success}) {
  final scaffold = ScaffoldMessenger.of(context ?? Get.context!);
  scaffold.showSnackBar(
    SnackBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      content: CustomToast(text: message ?? '', sanckBarType: snackBarType),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
