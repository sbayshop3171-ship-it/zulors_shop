

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/vacation_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/withdrawal_method_model.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class ShopRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> getShop();
  Future<http.StreamedResponse> updateShop(ShopModel userInfoModel,  File? file, XFile? shopBanner, XFile? secondaryBanner, XFile? offerBanner,
      {String? minimumOrderAmount, String? freeDeliveryStatus, String? freeDeliveryOverAmount, String? taxIdentificationNumber, String? tinExpireDate, String? stockLimit, XFile? tinCertificate});
  Future<ApiResponse> vacation(VacationModel vacationModel);
  Future<ApiResponse> temporaryClose(int status);
  Future<ApiResponse> getPaymentWithdrawalMethodList();
  Future<ApiResponse> addPaymentInfo(WithdrawAddModel withdrawAddMode, bool isUpdate);
  Future<ApiResponse> getPaymentInfoList(int? offset);
  Future<ApiResponse> updateConfigStatus(bool status, int id);
  Future<ApiResponse> deletePaymentMethod(int id);
  Future<ApiResponse> setDefaultPaymentMethod(int id);
  Future<ApiResponse> updateSetupGuideApp(String key, int value);
  Future<HttpClientResponse> downloadTinCertificate(String url);
}