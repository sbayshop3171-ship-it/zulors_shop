import 'package:zulors_shop_vendor/features/clearance_sale/domain/repositories/clearance_sale_repository_interface.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/services/clearance_sale_service_interface.dart';

class ClearanceSaleService implements ClearanceSaleServiceInterface{
  ClearanceSaleRepositoryInterface clearanceSaleRepositoryInterface;
  ClearanceSaleService({required this.clearanceSaleRepositoryInterface});

  @override
  Future getChatList(String type, int offset) async{
    return await clearanceSaleRepositoryInterface.getChatList(type, offset);
  }

  @override
  Future getClearanceSaleProductList(int offset) async{
    return await clearanceSaleRepositoryInterface.getClearanceSaleProductList(offset);
  }

  @override
  Future clearanceSaleProductDelete(int? productId) async {
    return await clearanceSaleRepositoryInterface.clearanceSaleProductDelete(productId);
  }

  @override
  Future clearanceSaleProductDeleteAll() async {
    return await clearanceSaleRepositoryInterface.clearanceSaleProductDeleteAll();
  }

  @override
  Future clearanceSaleProductStatusUpdate(int productId, int isActive) async {
    return await clearanceSaleRepositoryInterface.clearanceSaleProductStatusUpdate(productId, isActive);
  }

  // Future<ApiResponse> getSellerProductList(String sellerId, int offset, String languageCode, String search);

  @override
  Future getSellerProductList(String sellerId, int offset, String languageCode, String search) async {
    return await clearanceSaleRepositoryInterface.getSellerProductList(sellerId, offset, languageCode, search);
  }



  @override
  Future getConfigData() async {
    return await clearanceSaleRepositoryInterface.getConfigData();
  }



  @override
  Future updateConfigStatus(int status) async {
    return await clearanceSaleRepositoryInterface.updateConfigStatus(status);
  }


  @override
  Future updateClearanceSaleConfigData(Map<String,dynamic> data) async {
    return await clearanceSaleRepositoryInterface.updateClearanceSaleConfigData(data);
  }


  @override
  Future clearanceSaleProductAdd(Map<String,dynamic> data) async {
    return await clearanceSaleRepositoryInterface.clearanceSaleProductAdd(data);
  }


  @override
  Future updateClearanceSaleProductDiscount(Map<String,dynamic> data) async {
    return await clearanceSaleRepositoryInterface.updateClearanceSaleProductDiscount(data);
  }

}