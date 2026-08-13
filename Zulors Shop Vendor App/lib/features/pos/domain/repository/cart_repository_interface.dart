import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/customer_body.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/place_order_body.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class CartRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> getCouponDiscount(String couponCode, int? userId, double orderAmount);
  Future<ApiResponse> placeOrder(PlaceOrderBody placeOrderBody);
  Future<ApiResponse> getProductFromScan(String? productCode);
  Future<ApiResponse> getCustomerList(String type);
  Future<ApiResponse> customerSearch(String name);
  Future<ApiResponse> addNewCustomer(CustomerBody customerBody);
  Future<ApiResponse> getInvoiceData(int? orderId);
  Future<void> setBluetoothAddress(String? address);
  String? getBluetoothAddress();
  List<TemporaryCartListModel> getCartList();
  void addToCartList(List<TemporaryCartListModel> cartProductList);
  Future<ApiResponse> getTaxAmount(PlaceOrderBody? placeOrderBody);
}