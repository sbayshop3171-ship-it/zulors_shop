

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/vacation_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/withdrawal_method_model.dart';

abstract class ShopServiceInterface{
  Future<dynamic> getShop();
  Future<dynamic> updateShop(ShopModel userInfoModel,  File? file, XFile? shopBanner, XFile? secondaryBanner, XFile? offerBanner,
      {String? minimumOrderAmount, String? freeDeliveryStatus, String? freeDeliveryOverAmount, String? taxIdentificationNumber, String? tinExpireDate, String? stockLimit, XFile? tinCertificate});
  Future<dynamic> vacation(VacationModel vacationModel);
  Future<dynamic> temporaryClose(int status);
  Future<dynamic> getPaymentWithdrawalMethodList();
  Future<dynamic> addPaymentInfo(WithdrawAddModel withdrawAddModel,bool isUpdate);
  Future<dynamic> getPaymentInfoList(int? offset);
  Future<dynamic> updateConfigStatus(bool status, int id);
  Future<dynamic> deletePaymentMethod(int id);
  Future<dynamic> setDefaultPaymentMethod(int id);
  Future<dynamic> updateSetupGuideApp(String key, int value);
  Future<dynamic> downloadTinCertificate(String url);
}