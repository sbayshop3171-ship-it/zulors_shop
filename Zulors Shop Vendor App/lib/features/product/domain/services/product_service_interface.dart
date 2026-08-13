abstract class ProductServiceInterface {
  Future<dynamic> getSellerProductList({
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
  Future<dynamic> getPosProductList(int offset, List <String> ids);
  Future<dynamic> getStockLimitStatus();
  Future<dynamic> getSearchedPosProductList(String search, List <String> ids);
  Future<dynamic> getStockLimitedProductList(int offset, String languageCode );
  Future<dynamic> getMostPopularProductList(int offset, String languageCode );
  Future<dynamic> getTopSellingProductList(int offset, String languageCode );
  Future<dynamic> deleteProduct(int? productID);
  bool isShowCookies();
  Future<void> setIsShowCookies();
  Future<void> removeShowCookies();
  Future<dynamic> getBrandList(String languageCode);
}