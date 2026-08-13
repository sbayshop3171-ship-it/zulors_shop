
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/vacation_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/withdrawal_method_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/repositories/shop_repository_interface.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

class ShopRepository implements ShopRepositoryInterface{
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  ShopRepository({required this.dioClient, required this.sharedPreferences});

  @override
  Future<ApiResponse> getShop() async {
    try {
      final response = await dioClient!.get(AppConstants.shopUri);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<http.StreamedResponse> updateShop(ShopModel userInfoModel,  File? file, XFile? shopBanner, XFile? secondaryBanner, XFile? offerBanner,
      {String? minimumOrderAmount, String? freeDeliveryStatus, String? freeDeliveryOverAmount,  String? taxIdentificationNumber, String? tinExpireDate, String? stockLimit, XFile? tinCertificate}) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.shopUpdate}'));
    request.headers.addAll(<String,String>{'Authorization': 'Bearer ${Provider.of<AuthController>(Get.context!, listen: false).getUserToken()}'});
    if(file != null) {
      request.files.add(http.MultipartFile('logo', file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last));
    }
    if(shopBanner != null) {
      Uint8List list = await shopBanner.readAsBytes();
      var part = http.MultipartFile('banner', shopBanner.readAsBytes().asStream(), list.length, filename: basename(shopBanner.path));
      request.files.add(part);
    }if(secondaryBanner != null) {
      Uint8List list = await secondaryBanner.readAsBytes();
      var part = http.MultipartFile('bottom_banner', secondaryBanner.readAsBytes().asStream(), list.length, filename: basename(secondaryBanner.path));
      request.files.add(part);
    }
    if(offerBanner != null) {
      Uint8List list = await offerBanner.readAsBytes();
      var part = http.MultipartFile('offer_banner', offerBanner.readAsBytes().asStream(), list.length, filename: basename(offerBanner.path));
      request.files.add(part);
    }
    if(tinCertificate != null) {
      Uint8List list = await tinCertificate.readAsBytes();
      var part = http.MultipartFile('tin_certificate', tinCertificate.readAsBytes().asStream(), list.length, filename: basename(tinCertificate.path));
      request.files.add(part);
    }
    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      '_method': 'put', 'name': userInfoModel.name!, 'address': userInfoModel.address!, 'contact': userInfoModel.contact!,
      'minimum_order_amount' : minimumOrderAmount?? '0', 'free_delivery_status' : freeDeliveryStatus?? "false", 'free_delivery_over_amount': freeDeliveryOverAmount??'0',
      'tax_identification_number': taxIdentificationNumber ??'0', 'tin_expire_date': tinExpireDate ?? '' , 'stock_limit': stockLimit ?? '0'
    });
    request.fields.addAll(fields);
    http.StreamedResponse response = await request.send();
    if(kDebugMode){
      print("======>response body==> ${fields.toString()}");
      print("======>response body==> ${response.stream}");
    }
    return response;
  }

  @override
  Future<ApiResponse> vacation(VacationModel vacationModel) async {
    try {
      final response = await dioClient!.post(
        AppConstants.vacation,
        data: vacationModel
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> temporaryClose(int status) async {
    try {
      final response = await dioClient!.post(AppConstants.temporaryClose,data: {
        '_method' : "put",
        'status' : status
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> getPaymentWithdrawalMethodList() async {
    try {
      final response = await dioClient!.get(AppConstants.paymentWithdrawalMethodList);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }



  @override
  Future<ApiResponse> addPaymentInfo (WithdrawAddModel withdrawAddModel, bool isUpdate) async {
    try {
      final response = await dioClient!.post(
        isUpdate ? AppConstants.paymentInformationUpdate :
        AppConstants.paymentInformationAdd,
        data: withdrawAddModel
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getPaymentInfoList(int? offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.paymentInformationList}?limit=10&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updateConfigStatus(bool status, int id) async {
    try {
      final response = await dioClient!.post(AppConstants.paymentInformationStatusUpdate,
        data: {
          "id" : id,
          "status" : status
        }
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> deletePaymentMethod(int id) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.paymentInformationDelete}?id=$id',
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> setDefaultPaymentMethod(int id) async {
    try {
      final response = await dioClient!.post(
        AppConstants.paymentInformationDefault,
        data: {"id" : id}
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updateSetupGuideApp(String key, int value) async {
    try {
      final response = await dioClient!.post(AppConstants.updateSetupGuideApp, data: {
        'key' : key,
        'value' : value
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<HttpClientResponse> downloadTinCertificate (String? url) async {
    HttpClient client = HttpClient();
    final response = await client.getUrl(Uri.parse(url!)).then((HttpClientRequest request) {
      return request.close();
    });
    return response;
  }


  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }


}