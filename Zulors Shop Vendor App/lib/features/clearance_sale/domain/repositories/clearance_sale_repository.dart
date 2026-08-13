import 'package:dio/dio.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'dart:async';
import 'clearance_sale_repository_interface.dart';

class ClearanceSaleRepository implements ClearanceSaleRepositoryInterface{
  final DioClient? dioClient;
  ClearanceSaleRepository({required this.dioClient});

  @override
  Future<ApiResponse> getChatList(String type, int offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.cartUri}$type?limit=30&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> getClearanceSaleProductList(int offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.clearanceSaleProductList}?limit=10&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> clearanceSaleProductDelete(int? productId) async {
    String productId0 = productId?.toString() ?? '';
    try {
      final response = await dioClient!.post('${AppConstants.clearanceSaleDeleteProduct}$productId0');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // Future<ApiResponse> clearanceSaleProductDeleteAll()
  // Future<ApiResponse> clearanceSaleProductStatusUpdate(int productId, int isActive)

  @override
  Future<ApiResponse> clearanceSaleProductDeleteAll() async {
    try {
      final response = await dioClient!.post(AppConstants.clearanceSaleDeleteAllProduct);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> clearanceSaleProductStatusUpdate(int productId, int isActive) async {
    try {
      final response = await dioClient!.post(
        AppConstants.clearanceSaleProductStatusUpdate,
        data: {'product_id' : productId, 'is_active' : isActive  }
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }



  @override
  Future<ApiResponse> getSellerProductList(String sellerId, int offset, String languageCode, String search ) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.sellerProductUri}$sellerId/all-products?limit=20&&offset=$offset&search=$search&offer_type=clearance_sale',
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> getConfigData() async {
    try {
      final response = await dioClient!.get(AppConstants.clearanceSaleConfigData);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> updateConfigStatus(int status) async {
    try {
      final response = await dioClient!.post(AppConstants.clearanceSaleConfigStatusUpdate,
      data: {
        "status" : status
      }
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> updateClearanceSaleConfigData(Map<String,dynamic> data) async {
    try {
      final response = await dioClient!.post(AppConstants.clearanceSaleConfigDataUpdate,
          data: data
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> clearanceSaleProductAdd(Map<String,dynamic> data) async {
    try {
      final response = await dioClient!.post(AppConstants.clearanceSaleProductAdd,
          data: data
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> updateClearanceSaleProductDiscount(Map<String,dynamic> data) async {
    try {
      final response = await dioClient!.post(AppConstants.clearanceSaleProductDiscountUpdate, data: data);
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