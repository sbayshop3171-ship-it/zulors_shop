import 'dart:io';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/order_details/domain/models/order_setup_model.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class OrderDetailsRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> setUpOrder(OrderSetupModel orderSetUpModel);
  Future<ApiResponse> getOrderDetails(String orderID);
  Future<ApiResponse> getOrderStatusList(String type);
  Future<ApiResponse> uploadAfterSellDigitalProduct(File? filePath, String token, String orderId);
  Future<HttpClientResponse> productDownload(String url);

}