import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/vacation_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/withdrawal_method_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/repositories/shop_repository_interface.dart';
import 'package:zulors_shop_vendor/features/shop/domain/services/shop_service_interface.dart';

class ShopService implements ShopServiceInterface{
  final ShopRepositoryInterface shopRepositoryInterface;
  ShopService({required this.shopRepositoryInterface});

  @override
  Future getShop() {
    return shopRepositoryInterface.getShop();
  }

  @override
  Future temporaryClose(int status) {
    return shopRepositoryInterface.temporaryClose(status);
  }



  @override
  Future updateShop(ShopModel userInfoModel, File? file, XFile? shopBanner, XFile? secondaryBanner, XFile? offerBanner, {String? minimumOrderAmount, String? freeDeliveryStatus, String? freeDeliveryOverAmount,
    String? taxIdentificationNumber, String? tinExpireDate, String? stockLimit, XFile? tinCertificate}) {
    return shopRepositoryInterface.updateShop(userInfoModel, file, shopBanner, secondaryBanner, offerBanner, minimumOrderAmount: minimumOrderAmount, freeDeliveryOverAmount: freeDeliveryOverAmount, freeDeliveryStatus: freeDeliveryStatus,
      taxIdentificationNumber: taxIdentificationNumber, tinExpireDate: tinExpireDate, stockLimit: stockLimit, tinCertificate :  tinCertificate);
  }

  @override
  Future vacation(VacationModel vacationModel) {
    return shopRepositoryInterface.vacation(vacationModel);
  }

  @override
  Future getPaymentWithdrawalMethodList() {
    return shopRepositoryInterface.getPaymentWithdrawalMethodList();
  }

  @override
  Future addPaymentInfo(WithdrawAddModel vacationModel, bool isUpdate) {
    return shopRepositoryInterface.addPaymentInfo(vacationModel, isUpdate);
  }

  @override
  Future getPaymentInfoList(int? offset) {
    return shopRepositoryInterface.getPaymentInfoList(offset);
  }

  @override
  Future updateConfigStatus(bool status, int id) {
    return shopRepositoryInterface.updateConfigStatus(status, id);
  }

  @override
  Future deletePaymentMethod(int id) {
    return shopRepositoryInterface.deletePaymentMethod(id);
  }

  @override
  Future setDefaultPaymentMethod(int id) {
    return shopRepositoryInterface.setDefaultPaymentMethod(id);
  }

  @override
  Future updateSetupGuideApp(String key, int value) {
    return shopRepositoryInterface.updateSetupGuideApp(key, value);
  }



  @override
  Future<HttpClientResponse> downloadTinCertificate(String url) async{
    return await shopRepositoryInterface.downloadTinCertificate(url);
  }




}