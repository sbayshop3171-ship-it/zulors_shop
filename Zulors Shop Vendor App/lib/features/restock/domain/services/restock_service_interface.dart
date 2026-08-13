import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';

abstract class RestockServiceInterface{

  Future<dynamic> getRestockProductList(Map<dynamic, dynamic> data);

  Future<dynamic> getRestockBrandList();

  Future<dynamic> deleteRestockItem(int id);

  Future<dynamic> deleteRestockProduct(String? type, String? id);

  Future<dynamic> updateRestockProductQuantity(int? productId,int currentStock, List <Variation> variation);

  Future<dynamic> updateProductQuantity(int? productId,int currentStock, List <Variation> variation);

}