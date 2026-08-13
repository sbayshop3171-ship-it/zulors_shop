import 'package:flutter/material.dart';
import 'package:zulors_shop/localization/app_localization.dart';

String? getTranslated(String? key, BuildContext context) {
  String? text = key;
  try{
    text = AppLocalization.of(context)!.translate(key);
  }catch (error){
    text = "$key";
  }
  return text;
}