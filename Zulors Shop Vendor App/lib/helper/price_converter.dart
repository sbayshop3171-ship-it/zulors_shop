import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';

class PriceConverter {
  static String convertPrice(BuildContext context, double? price, {double? discount, String? discountType}) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    if(discount != null && discountType != null){
      if(discountType == 'amount' || discountType == 'flat') {
        price = price! - discount;
      }else if(discountType == 'percent' || discountType == 'percentage') {
        price = price! - ((discount / 100) * price);
      }
    }

    bool singleCurrency = splashProvider.configModel?.currencyModel == 'single_currency';
    bool inRight = Provider.of<SplashController>(context, listen: false).configModel!.currencySymbolPosition == 'right';

    return '${inRight ? '' : splashProvider.myCurrency!.symbol} ${(singleCurrency? price : price!
        * splashProvider.myCurrency!.exchangeRate!
        * (1/ splashProvider.usdCurrency!.exchangeRate!))!.toStringAsFixed(splashProvider.configModel!.decimalPointSettings!)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ${inRight ? splashProvider.myCurrency!.symbol : ''}';
  }


  static double? convertWithDiscount(BuildContext context, double? price, double? discount, String? discountType) {
    if(discountType == 'amount' || discountType == 'flat') {
      price = price! - discount!;
    }else if(discountType == 'percent' || discountType == 'percentage') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }


  static String convertPriceWithoutSymbol(BuildContext context, double? price, {double? discount, String? discountType}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount' || discountType == 'flat') {
        price = price! - discount;
      }else if(discountType == 'percent' || discountType == 'percentage') {
        price = price! - ((discount / 100) * price);
      }
    }
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    bool singleCurrency = splashProvider.configModel!.currencyModel == 'single_currency';

    return (singleCurrency? price : price!
        * splashProvider.myCurrency!.exchangeRate!
        * (1 / splashProvider.usdCurrency!.exchangeRate!))!.toStringAsFixed(splashProvider.configModel!.decimalPointSettings!);
  }


  static String reverseConvertPriceWithoutSymbol(BuildContext context, double? localPrice, {double? discount, String? discountType, bool removeDecimalPoint = false}) {

    if (localPrice == null) return '0.00'; // Handle null price

    final splashProvider = Provider.of<SplashController>(context, listen: false);
    bool singleCurrency = splashProvider.configModel!.currencyModel == 'single_currency';

    // Reverse currency conversion: Convert the local price back to the base price (USD)
    if (!singleCurrency && splashProvider.myCurrency != null && splashProvider.usdCurrency != null) {
      localPrice = localPrice / splashProvider.myCurrency!.exchangeRate! * splashProvider.usdCurrency!.exchangeRate!;
    }

    // Apply reverse discount if discount and type are provided
    if (discount != null && discountType != null) {
      if (discountType == 'amount' || discountType == 'flat') {
        localPrice = localPrice + discount;
      } else if (discountType == 'percent' || discountType == 'percentage') {
        localPrice = localPrice / (1 - (discount / 100));
      }
    }

    // Format the final price with the correct number of decimals

    if(removeDecimalPoint) {
      return localPrice.toString();
    } else {
      return localPrice.toString();
    }
  }



  static double systemCurrencyToDefaultCurrency(double price, BuildContext context) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    bool singleCurrency = splashProvider.configModel!.currencyModel == 'single_currency';
    if(singleCurrency) {
      return price / 1;
    }else {
      return price / splashProvider.myCurrency!.exchangeRate!;
    }
  }

  static double convertAmount(double amount, BuildContext context) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    return double.parse((amount * splashProvider.myCurrency!.exchangeRate! *
        (1/splashProvider.usdCurrency!.exchangeRate!)).toStringAsFixed(splashProvider.configModel!.decimalPointSettings!));
  }
  static String percentageCalculation(BuildContext context, double? price, double? discount, String? discountType) {
    return '-${(discountType == 'percent' || discountType == 'percentage') ? '$discount %'
        : convertPrice(context, discount)}';
  }
  static String discountCalculationWithOutSymbol(BuildContext context,double price, double discount, String? discountType, {bool convertCurrency = true}) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);

    if(discountType == 'amount') {
      discount =  discount;
    }else if(discountType == 'percent') {
      discount =  ((discount / 100) * price);
    }

    if(discountType == 'percent' && convertCurrency) {
      discount = ((discount * splashProvider.myCurrency!.exchangeRate! *
        (1/splashProvider.usdCurrency!.exchangeRate!)));
    }

    return discount.toStringAsFixed(2);
  }

  static String discountCalculation(BuildContext context,double price, double discount, String? discountType) {
    final splashProvider = Provider.of<SplashController>(context, listen: false);
    if(discountType == 'amount') {
      discount =  discount;
    }else if(discountType == 'percent') {
      discount =  ((discount / 100) * price);
    }
    return '${splashProvider.myCurrency!.symbol} ${discount.toStringAsFixed(2)}';
  }


  static String getUnitCurrency (BuildContext context, double? price) {
    bool singleCurrency = Provider.of<SplashController>(context, listen: false).configModel!.currencyModel == 'single_currency';
    bool inRight = Provider.of<SplashController>(context, listen: false).configModel!.currencySymbolPosition == 'right';

    return '${inRight ? '' : Provider.of<SplashController>(context, listen: false).myCurrency!.symbol}'
        '${(singleCurrency? price : price!)!
        .toStringAsFixed(Provider.of<SplashController>(context,listen: false).configModel!.decimalPointSettings??1).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
        '${inRight ? Provider.of<SplashController>(context, listen: false).myCurrency!.symbol : ''}';
  }


  static String longToShortPrice(double amount){
    int decimalPoint = 2 ;

    if (amount.abs() >= 1e12) {
      return '${(amount / 1e12).toStringAsFixed(decimalPoint)}T';
    } else if (amount.abs() >= 1e9) {
      return '${(amount / 1e9).toStringAsFixed(decimalPoint)}B';
    } else if (amount.abs() >= 1e6) {
      return '${(amount / 1e6).toStringAsFixed(decimalPoint)}M';
    } else {
      return amount.toStringAsFixed(decimalPoint);
    }
  }
}