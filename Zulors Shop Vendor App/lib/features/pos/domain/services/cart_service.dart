

import 'package:zulors_shop_vendor/features/pos/domain/models/customer_body.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/place_order_body.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:zulors_shop_vendor/features/pos/domain/repository/cart_repository_interface.dart';
import 'package:zulors_shop_vendor/features/pos/domain/services/cart_service_interface.dart';

class CartService implements CartServiceInterface{
  final CartRepositoryInterface cartRepositoryInterface;
  CartService({required this.cartRepositoryInterface});

  @override
  Future addNewCustomer(CustomerBody customerBody) {
    return cartRepositoryInterface.addNewCustomer(customerBody);
  }

  @override
  Future customerSearch(String name) {
    return cartRepositoryInterface.customerSearch(name);
  }

  @override
  Future getCouponDiscount(String couponCode, int? userId, double orderAmount) {
    return cartRepositoryInterface.getCouponDiscount(couponCode, userId, orderAmount);
  }

  @override
  Future getCustomerList(String type) {
    return cartRepositoryInterface.getCustomerList(type);
  }

  @override
  Future getProductFromScan(String? productCode) {
    return cartRepositoryInterface.getProductFromScan(productCode);
  }

  @override
  Future placeOrder(PlaceOrderBody placeOrderBody) {
    return cartRepositoryInterface.placeOrder(placeOrderBody);
  }

  @override
  Future getInvoiceData(int? orderId) {
    return cartRepositoryInterface.getInvoiceData(orderId);
  }

  @override
  Future<void> setBluetoothAddress(String? address) async {
    await cartRepositoryInterface.setBluetoothAddress(address);
  }

  @override
  String? getBluetoothAddress() => cartRepositoryInterface.getBluetoothAddress();

  @override
  List<TemporaryCartListModel> getCartList() => cartRepositoryInterface.getCartList();

  @override
  void addToCartList(List<TemporaryCartListModel> cartProductList) {
   return cartRepositoryInterface.addToCartList(cartProductList);
  }

  @override
  Future getTaxAmount(PlaceOrderBody? placeOrderBody) {
    return cartRepositoryInterface.getTaxAmount(placeOrderBody);
  }


}