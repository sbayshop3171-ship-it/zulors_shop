

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class NumberCheckerHelper {

  static bool isNumber(String number) {
    return number.split('').every((digit) => '+0123456789'.contains(digit));
  }

  static String? getCountryCode(String? number) {
    String? countryCode = '';
    try{
      countryCode = codes.firstWhere((item) =>
          number!.contains('${item['dial_code']}'))['dial_code'];
    }catch(error){
      debugPrint('country error: $error');
    }
    return countryCode;
  }

  static String? getPhoneNumber(String phoneNumberWithCountryCode, String countryCode){
    String phoneNumber = phoneNumberWithCountryCode.split(countryCode).last;
    return phoneNumber;
  }

}