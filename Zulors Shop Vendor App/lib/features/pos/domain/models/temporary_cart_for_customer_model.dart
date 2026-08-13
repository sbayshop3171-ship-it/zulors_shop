import 'package:zulors_shop_vendor/features/pos/domain/models/cart_model.dart';

class TemporaryCartListModel {
  List<CartModel>? cart;
  int? userId;
  String? customerName;
  int? userIndex;
  double? customerBalance;
  double? _couponAmount;
  String? couponCode;
  double? extraDiscount;
  bool? isUser;
  String? phoneNumber;

  TemporaryCartListModel({
    this.cart,
    this.userId,
    this.customerName,
    this.userIndex,
    this.customerBalance,
    double? couponAmount,
    this.couponCode,
    this.extraDiscount,
    this.isUser,
    this.phoneNumber, // Initialize new field
  }) {
    _couponAmount = couponAmount;
  }

  double? get couponAmount => _couponAmount;

  set couponAmount(double? value) {
    _couponAmount = value;
  }

  TemporaryCartListModel.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      cart = [];
      json['cart'].forEach((v) {
        cart!.add(CartModel.fromJson(v));
      });
    }
    userId = json['user_id'];
    userIndex = json['user_index'];
    customerName = json['customer_name'];
    customerBalance = json['customer_balance'];
    couponCode = json['coupon_code'];
    _couponAmount = json['coupon_discount_amount'];
    isUser = json['is_user'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cart != null) {
      data['cart'] = cart!.map((v) => v.toJson()).toList();
    }
    data['user_id'] = userId;
    data['user_index'] = userIndex;
    data['customer_name'] = customerName;
    data['customer_balance'] = customerBalance;
    data['coupon_code'] = couponCode;
    data['coupon_discount_amount'] = _couponAmount;
    data['is_user'] = isUser;
    data['phone_number'] = phoneNumber;
    return data;
  }
}

class Cart {
  String? _productId;
  String? _price;
  double? _discountAmount;
  int? _quantity;
  double? _taxAmount;


  Cart(
      String productId,
      String price,
      double discountAmount,
      int quantity,
      double taxAmount,
      ) {
    _productId = productId;
    _price = price;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _taxAmount = taxAmount;

  }

  String? get productId => _productId;
  String? get price => _price;
  double? get discountAmount => _discountAmount;
  int? get quantity => _quantity;
  double? get taxAmount => _taxAmount;


  Cart.fromJson(Map<String, dynamic> json) {
    _productId = json['id'];
    _price = json['price'];
    _discountAmount = json['discount'];
    _quantity = json['quantity'];
    _taxAmount = json['tax'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _productId;
    data['price'] = _price;
    data['discount'] = _discountAmount;
    data['quantity'] = _quantity;
    data['tax'] = _taxAmount;
    return data;
  }
}



