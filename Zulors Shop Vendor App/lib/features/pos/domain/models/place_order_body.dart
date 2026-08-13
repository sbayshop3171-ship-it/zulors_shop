import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';

class PlaceOrderBody {
  List<Cart>? _cart;
  double? _couponDiscountAmount;
  double? _orderAmount;
  String? _couponCode;
  double? _couponAmount;
  int? _userId;
  double? _extraDiscount;
  String? _extraDiscountType;
  String? _paymentMethod;
  double? _paidAmount;
  double? _totalTaxAmount;
  List<ModifiedCart>? _modifiedCart;

  PlaceOrderBody(
      {required List<Cart> cart,
        double? couponDiscountAmount,
        String? couponCode,
        double? couponAmount,
        double? orderAmount,
        int? userId,
        double? extraDiscount,
        String? extraDiscountType,
        String? paymentMethod,
        double? paidAmount,
        double? totalTaxAmount,
        List<ModifiedCart>? modifiedCart
       }) {
    _cart = cart;
    _couponDiscountAmount = couponDiscountAmount;
    _couponCode = couponCode;
    _couponAmount = couponAmount;
    _orderAmount = orderAmount;
    _userId = userId;
    _extraDiscount = extraDiscount;
    _extraDiscountType = extraDiscountType;
    _paymentMethod = paymentMethod;
    _paidAmount = paidAmount;
    _totalTaxAmount = totalTaxAmount;
    if (modifiedCart != null) {
      _modifiedCart = modifiedCart;
    }
  }

  List<Cart>? get cart => _cart;
  double? get couponDiscountAmount => _couponDiscountAmount;
  String? get couponCode => _couponCode;
  double? get couponAmount => _couponAmount;
  double? get orderAmount => _orderAmount;
  int? get userId => _userId;
  double? get extraDiscount => _extraDiscount;
  String? get extraDiscountType => _extraDiscountType;
  String? get paymentMethod => _paymentMethod;
  double? get paidAmount => _paidAmount;
  double? get totalTaxAmount => _totalTaxAmount;
  List<ModifiedCart>? get modifiedCart => _modifiedCart;


  PlaceOrderBody.fromJson(Map<String, dynamic> json) {
    if (json['cart'] != null) {
      _cart = [];
      json['cart'].forEach((v) {
        _cart!.add(Cart.fromJson(v));
      });
    }
    _couponDiscountAmount = double.tryParse(json['coupon_discount'].toString());
    _couponCode = json['coupon_code'];
    _couponAmount = double.tryParse(json['coupon_discount_amount'].toString());
    _orderAmount = double.tryParse(json['order_amount'].toString());
    _userId = json['customer_id'];
    _extraDiscount =  double.tryParse(json['extra_discount'].toString());
    _extraDiscountType = json ['extra_discount_type'];
    _paymentMethod = json ['payment_method'];
    _paidAmount =  double.tryParse(json['paid_amount'].toString());
    _totalTaxAmount = double.tryParse(json['total_tax_amount'].toString());
    if (json['modified_cart'] != null) {
      _modifiedCart = <ModifiedCart>[];
      json['modified_cart'].forEach((v) {
        _modifiedCart!.add( ModifiedCart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_cart != null) {
      data['cart'] = _cart!.map((v) => v.toJson()).toList();
    }
    data['coupon_discount'] = _couponDiscountAmount;
    data['order_amount'] = _orderAmount;
    data['coupon_code'] = _couponCode;
    data['coupon_discount_amount'] = _couponAmount;
    data['customer_id'] = _userId;
    data['extra_discount'] = _extraDiscount;
    data['extra_discount_type'] = _extraDiscountType;
    data['payment_method'] = _paymentMethod;
    data['paid_amount'] = _paidAmount;
    data['total_tax_amount'] = _totalTaxAmount;
    if (_modifiedCart != null) {
      data['modified_cart'] =
          _modifiedCart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  String? _productId;
  String? _price;
  double? _discountAmount;
  int? _quantity;
  String? _variant;
  String? _variantKey;
  double? _digitalVariationPrice;
  List<Variation?>? _variation;




  Cart(
      String productId,
      String price,
      double discountAmount,
      int? quantity,
      String? variant,
      String? variantKey,
      double? digitalVariationPrice,
      List<Variation?> variation
      ) {
    _productId = productId;
    _price = price;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _variant = variant;
    _variantKey = variantKey;
    _digitalVariationPrice = digitalVariationPrice;
    _variation = variation;
  }

  String? get productId => _productId;
  String? get price => _price;
  double? get discountAmount => _discountAmount;
  int? get quantity => _quantity;
  String? get variant => _variant;
  double? get digitalVariationPrice => _digitalVariationPrice;
  List<Variation?>? get variation => _variation;



  Cart.fromJson(Map<String, dynamic> json) {
    _productId = json['id'];
    _price = json['price'];
    _discountAmount = double.tryParse(json['discount'].toString());
    _quantity = json['quantity'];
    _variant = json['variant'];
    _variantKey = json['variant_key'];
    _digitalVariationPrice = json['digital_variation_price'];
    if (json['variation'] != null) {
      _variation = <Variation>[];
      json['variation'].forEach((v) {
        _variation!.add(Variation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _productId;
    data['price'] = _price;
    data['discount'] = _discountAmount;
    data['quantity'] = _quantity;
    data['variant'] = _variant;
    data['variant_key'] = _variantKey;
    data['digital_variation_price'] = _digitalVariationPrice;
    if (_variation != null) {
      data['variation'] = _variation!.map((v) => v!.toJson()).toList();
    }
    return data;
  }
}



class ModifiedCart {
  int? id;
  double? price;
  double? discountedPrice;
  double? discount;
  String? discountType;
  int? quantity;
  String? variant;
  String? variantKey;
  double? digitalVariationPrice;
  List<Variation>? variation;
  double? couponDiscount;
  double? extraDiscount;
  double? appliedTaxAmount;

  ModifiedCart(
      {this.id,
        this.price,
        this.discountedPrice,
        this.discount,
        this.discountType,
        this.quantity,
        this.variant,
        this.variantKey,
        this.digitalVariationPrice,
        this.variation,
        this.couponDiscount,
        this.extraDiscount,
        this.appliedTaxAmount});

  ModifiedCart.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString()) ;
    price = double.tryParse(json['price'].toString());
    discountedPrice = double.tryParse(json['discounted_price'].toString());
    discount =  double.tryParse(json['discount'].toString());
    discountType = json['discount_type'];
    quantity = json['quantity'];
    variant = json['variant'];
    variantKey = json['variant_key'];
    digitalVariationPrice = double.tryParse(json['digital_variation_price'].toString());
    if (json['variation'] != null) {
      variation = <Variation>[];
      json['variation'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
    couponDiscount = double.tryParse(json['coupon_discount'].toString());
    extraDiscount =  double.tryParse(json['extra_discount'].toString());
    appliedTaxAmount = double.tryParse(json['applied_tax_amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['price'] = price;
    data['discounted_price'] = discountedPrice;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['variant'] = variant;
    data['variant_key'] = variantKey;
    data['digital_variation_price'] = digitalVariationPrice;
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    data['coupon_discount'] = couponDiscount;
    data['extra_discount'] = extraDiscount;
    data['applied_tax_amount'] = appliedTaxAmount;
    return data;
  }
}