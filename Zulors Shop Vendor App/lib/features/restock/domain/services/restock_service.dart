import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/restock/domain/repositories/restock_repository_interface.dart';
import 'package:zulors_shop_vendor/features/restock/domain/services/restock_service_interface.dart';

class RestockService implements RestockServiceInterface{
  RestockRepositoryInterface restockRepositoryInterface;
  RestockService({required this.restockRepositoryInterface});

  @override
  Future getRestockProductList(Map<dynamic, dynamic> data) async{
    return await restockRepositoryInterface.getRestockProductList(data);
  }

  // getRestockBrandList
  @override
  Future getRestockBrandList() async{
    return await restockRepositoryInterface.getRestockBrandList();
  }

  @override
  Future deleteRestockItem(int id) async{
    return await restockRepositoryInterface.deleteRestockItem(id);
  }


  @override
  Future deleteRestockProduct(String? type, String? id) async{
    return await restockRepositoryInterface.deleteRestockProduct(type, id);
  }

  @override
  Future updateRestockProductQuantity(int? productId, int currentStock, List<Variation> variation) {
    return restockRepositoryInterface.updateRestockProductQuantity(productId, currentStock, variation);
  }

  @override
  Future updateProductQuantity(int? productId, int currentStock, List<Variation> variation) {
    return restockRepositoryInterface.updateProductQuantity(productId, currentStock, variation);
  }

}