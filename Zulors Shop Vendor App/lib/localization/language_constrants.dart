import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/app_localization.dart';

String? getTranslated(String? key, BuildContext context) {
  String? text = key;
  try{
    text = AppLocalization.of(context)!.translate(key);

  }catch (error){
    debugPrint('error --- $error');
  }
  return text;
}