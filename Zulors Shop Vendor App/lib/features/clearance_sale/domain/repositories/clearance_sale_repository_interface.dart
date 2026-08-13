import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class ClearanceSaleRepositoryInterface implements RepositoryInterface{

  Future<ApiResponse> getChatList(String type, int offset);

  Future<ApiResponse> getClearanceSaleProductList(int offset);

  Future<ApiResponse> clearanceSaleProductDelete(int? productId);

  Future<ApiResponse> clearanceSaleProductDeleteAll();

  Future<ApiResponse> clearanceSaleProductStatusUpdate(int productId, int isActive);

  Future<ApiResponse> getSellerProductList(String sellerId, int offset, String languageCode, String search);

  Future<ApiResponse> getConfigData();

  Future<ApiResponse> updateConfigStatus(int status);

  Future<ApiResponse> updateClearanceSaleConfigData(Map<String,dynamic> data);

  Future<ApiResponse> clearanceSaleProductAdd(Map<String,dynamic> data);

  Future<ApiResponse> updateClearanceSaleProductDiscount(Map<String,dynamic> data);

}