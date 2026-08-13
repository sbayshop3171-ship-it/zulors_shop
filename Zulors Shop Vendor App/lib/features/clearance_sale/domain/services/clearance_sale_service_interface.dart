abstract class ClearanceSaleServiceInterface {
  Future<dynamic> getChatList(String type, int offset);

  Future<dynamic> getClearanceSaleProductList(int offset);

  Future<dynamic> clearanceSaleProductDelete(int? productId);

 Future<dynamic> clearanceSaleProductDeleteAll();

 Future<dynamic> clearanceSaleProductStatusUpdate(int productId, int isActive);

  Future<dynamic> getSellerProductList(String sellerId, int offset, String languageCode, String search);

  Future<dynamic> getConfigData();

  Future<dynamic> updateConfigStatus(int status);

  Future<dynamic> updateClearanceSaleConfigData(Map<String,dynamic> data);

 Future<dynamic> clearanceSaleProductAdd(Map<String,dynamic> data);

  Future<dynamic> updateClearanceSaleProductDiscount(Map<String,dynamic> data);


}