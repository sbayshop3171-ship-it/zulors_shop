import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/product/domain/repositories/product_repository_interface.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';


class ProductRepository implements ProductRepositoryInterface{
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  ProductRepository({required this.sharedPreferences, required this.dioClient});

  @override
  Future<ApiResponse> getSellerProductList({
    required String sellerId,
    required int offset,
    required String languageCode,
    required String search,
    String? productType,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? brandIds,
    List<int>? categoryIds,
    List<int>? publishingHouseIds,
    List<int>? authorIds,
}) async {
    try {

      // Build query parameters dynamically
      final Map<String, dynamic> queryParams = {
        'limit': 20,
        'offset': offset,
        'search': search,
        if (productType != null && productType.isNotEmpty) 'product_type': productType,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (startDate != null) 'start_date': DateConverter.durationDateTime(startDate),
        if (endDate != null) 'end_date': DateConverter.durationDateTime(endDate),
        if (brandIds != null && brandIds.isNotEmpty) 'brand_ids': jsonEncode(brandIds),
        if (categoryIds != null && categoryIds.isNotEmpty) 'category_ids': jsonEncode(categoryIds),
        if(publishingHouseIds != null && publishingHouseIds.isNotEmpty) 'publishing_house_ids': jsonEncode(publishingHouseIds),
        if(authorIds != null && authorIds.isNotEmpty) 'author_ids': jsonEncode(authorIds),
      };

      debugPrint('-----------queryParams $queryParams');

      final response = await dioClient!.get(
        '${AppConstants.sellerProductUri}$sellerId/all-products',
        queryParameters: queryParams,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getPosProductList(int offset, List <String> ids) async {
    try {
      final response = await dioClient!.get('${AppConstants.posProductList}?limit=10&&offset=$offset&category_id=${jsonEncode(ids)}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getSearchedPosProductList(String search, List <String> ids) async {
    try {
      final response = await dioClient!.get('${AppConstants.searchPosProductList}?limit=10&offset=1&name=$search&category_id=${jsonEncode(ids)}');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getStockLimitedProductList(int offset, String languageCode ) async {
    try {
      final response = await dioClient!.get('${AppConstants.stockOutProductUri}$offset',
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getMostPopularProductList(int offset, String languageCode ) async {
    try {
      final response = await dioClient!.get('${AppConstants.mostPopularProduct}$offset',
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getTopSellingProductList(int offset, String languageCode ) async {
    try {
      final response = await dioClient!.get('${AppConstants.topSellingProduct}$offset',
        options: Options(headers: {AppConstants.langKey: languageCode}),
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
  Future delete(int id) async{
    try {
      final response = await dioClient!.post('${AppConstants.deleteProductUri}/$id',data: {
        '_method':'delete'
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
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

  @override
  Future<ApiResponse> getStockLimitStatus() async {
    try {
      final response = await dioClient!.get(AppConstants.stockLimitStatus);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  bool isShowCookies() {
    return sharedPreferences!.containsKey(AppConstants.showCookies);
  }

  @override
  Future<void> setIsShowCookies() async {
    await sharedPreferences!.setString(AppConstants.showCookies, 'cookies');
  }

  @override
  Future<void> removeShowCookies() async {
    await sharedPreferences!.remove(AppConstants.showCookies);
  }

  @override
  Future<ApiResponse> getBrandList(String languageCode) async {
    try {
      final response = await dioClient!.get(AppConstants.brandUri,
        options: Options(headers: {AppConstants.langKey: languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}