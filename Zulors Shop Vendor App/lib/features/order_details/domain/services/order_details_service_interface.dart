import 'dart:io';

import 'package:zulors_shop_vendor/features/order_details/domain/models/order_setup_model.dart';

abstract class OrderDetailsServiceInterface{
  Future<dynamic> setUpOrder(OrderSetupModel orderSetUpModel);
  Future<dynamic> getOrderDetails(String orderID);
  Future<dynamic> getOrderStatusList(String type);
  Future<dynamic> uploadAfterSellDigitalProduct(File? filePath, String token, String orderId);
  Future<HttpClientResponse> productDownload(String url);

}