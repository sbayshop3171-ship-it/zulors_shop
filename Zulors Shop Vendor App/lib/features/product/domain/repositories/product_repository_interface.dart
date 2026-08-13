
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class ProductRepositoryInterface implements RepositoryInterface{
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
  });

  Future<ApiResponse> getPosProductList(int offset, List <String> ids);
  Future<ApiResponse> getStockLimitStatus();
  Future<ApiResponse> getSearchedPosProductList(String search, List <String> ids);
  Future<ApiResponse> getStockLimitedProductList(int offset, String languageCode );
  Future<ApiResponse> getMostPopularProductList(int offset, String languageCode );
  Future<ApiResponse> getTopSellingProductList(int offset, String languageCode );
  bool isShowCookies();
  Future<void> setIsShowCookies();
  Future<void> removeShowCookies();
  Future<ApiResponse> getBrandList(String languageCode);


}