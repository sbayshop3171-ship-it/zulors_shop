import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/features/auth/domain/models/register_model.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class AuthRepository implements AuthRepositoryInterface{
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  AuthRepository({required this.dioClient, required this.sharedPreferences});

  @override
  Future<ApiResponse> login({String? emailAddress, String? password}) async {
    try {
      Response response = await dioClient!.post(AppConstants.loginUri,
        data: {"email": emailAddress, "password": password},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
     return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> setLanguageCode(String languageCode) async {
    try {
      final response = await dioClient!.post(AppConstants.setCurrentLanguageUri, data: {
        'current_language' : languageCode,
        '_method' : 'put'
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> forgotPassword(String identity) async {
    try {
      Response response = await dioClient!.post(AppConstants.forgotPasswordUri, data: {"identity": identity});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> resetPassword(String identity, String otp ,String password, String confirmPassword, String? token) async {

    try {
      Response response = await dioClient!.post(
          AppConstants.resetPasswordUri, data: {"_method" : "put",
        "identity": identity.trim(), "otp": token ?? otp,
        "password": password, "confirm_password":confirmPassword});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> verifyOtp(String identity, String otp) async {
    try {
      Response response = await dioClient!.post(
          AppConstants.verifyOtpUri, data: {"identity": identity.trim(), "otp": otp});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updateToken() async {
    try {
      String? deviceToken = await _getDeviceToken();
      FirebaseMessaging.instance.subscribeToTopic(AppConstants.topic);
      FirebaseMessaging.instance.subscribeToTopic(AppConstants.maintenanceModeTopic);
      Response response = await dioClient!.post(
        AppConstants.tokenUri,
        data: {"_method": "put", "cm_firebase_token": deviceToken},
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<String?> _getDeviceToken() async {
    String? deviceToken;
    deviceToken = await FirebaseMessaging.instance.getToken();

    if (deviceToken != null) {
      if (kDebugMode) {
        print('--------Device Token---------- $deviceToken');
      }
    }
    return deviceToken;
  }

  @override
  Future<void> saveUserToken(String token) async {
    dioClient!.token = token;
    dioClient!.dio!.options.headers = {'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'Bearer $token'};

    try {
      await sharedPreferences!.setString(AppConstants.token, token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getUserToken() {
    return sharedPreferences!.getString(AppConstants.token) ?? "";
  }

  @override
  bool isLoggedIn() {
    return sharedPreferences!.containsKey(AppConstants.token);
  }

  @override
  Future<bool> clearSharedData() async {
    try{
      await FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.topic);
      await FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.maintenanceModeTopic);
    }catch(e) {
      if (kDebugMode) {
        print("====Execption====>>$e");
      }
    }
    return sharedPreferences!.remove(AppConstants.token);
  }

  @override
  Future<void> saveUserCredentials(String number, String password) async {
    try {
      await sharedPreferences!.setString(AppConstants.userPassword, password);
      await sharedPreferences!.setString(AppConstants.userEmail, number);
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getUserEmail() {
    return sharedPreferences!.getString(AppConstants.userEmail) ?? "";
  }

  @override
  String getUserPassword() {
    return sharedPreferences!.getString(AppConstants.userPassword) ?? "";
  }

  @override
  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences!.remove(AppConstants.userPassword);
    return await sharedPreferences!.remove(AppConstants.userEmail);
  }

  @override
  Future<ApiResponse> registration(XFile? profileImage, XFile? shopLogo, XFile? shopBanner, XFile? secondaryBanner, RegisterModel registerModel, XFile? tinCertificate) async {
    http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.baseUrl}${AppConstants.registration}'));
    if(profileImage != null) {
      Uint8List list = await profileImage.readAsBytes();
      var part = http.MultipartFile('image', profileImage.readAsBytes().asStream(), list.length, filename: basename(profileImage.path));
      request.files.add(part);
    } if(shopLogo != null) {
      Uint8List list = await shopLogo.readAsBytes();
      var part = http.MultipartFile('logo', shopLogo.readAsBytes().asStream(), list.length, filename: basename(shopLogo.path));
      request.files.add(part);
    } if(shopBanner != null) {
      Uint8List list = await shopBanner.readAsBytes();
      var part = http.MultipartFile('banner', shopBanner.readAsBytes().asStream(), list.length, filename: basename(shopBanner.path));
      request.files.add(part);
    }if(secondaryBanner != null) {
      Uint8List list = await secondaryBanner.readAsBytes();
      var part = http.MultipartFile('bottom_banner', secondaryBanner.readAsBytes().asStream(), list.length, filename: basename(secondaryBanner.path));
      request.files.add(part);
    }
    if(tinCertificate != null) {
      Uint8List list = await tinCertificate.readAsBytes();
      var part = http.MultipartFile('tin_certificate', tinCertificate.readAsBytes().asStream(), list.length, filename: basename(tinCertificate.path));
      request.files.add(part);
    }

    Map<String, String> fields = {};
    fields.addAll(<String, String>{
      'f_name': registerModel.fName!,
      'l_name': registerModel.lName!,
      'phone': registerModel.phone!,
      'email': registerModel.email!,
      'password': registerModel.password!,
      'confirm_password': registerModel.confirmPassword!,
      'shop_name': registerModel.shopName!,
      'shop_address': registerModel.shopAddress!,
      'tax_identification_number': registerModel.businessTin!,
      'tin_expire_date': registerModel.tinExpireDate ?? ''
    });

    request.fields.addAll(fields);
    if (kDebugMode) {
      print('=====> ${request.url.path}\n${request.fields}');
    }

    http.StreamedResponse response = await request.send();
    var res = await http.Response.fromStream(response);
    if (kDebugMode) {
      print('=====Response body is here==>${res.body}');
    }

    try {
      return ApiResponse.withSuccess(Response(statusCode: response.statusCode,
          requestOptions: RequestOptions(path: ''),
          statusMessage: response.reasonPhrase, data: res.body));
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));

    }
  }

  @override
  Future<ApiResponse> firebaseAuthTokenStore(String userInput, String token) async {
    try {
      Response response = await dioClient!.post(
          AppConstants.firebaseAuthTokenStore, data: {"identity": userInput, "token": token});
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> firebaseAuthVerify({required String phoneNumber, required String session, required String otp, required bool isForgetPassword}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.firebaseAuthVerify,
        data: {
          'sessionInfo' : session,
          'phoneNumber' : phoneNumber,
          'code' : otp
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> checkVendorExistPhone({required String phoneNumber}) async {
    try {
      Response response = await dioClient!.post(
        AppConstants.checkVendorExistInfoPhone,
        data: {
          'phone' : phoneNumber,
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
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
