import 'package:zulors_shop_vendor/features/addProduct/domain/models/tax_vat_model.dart';

class PricingModel {
  bool? success;
  String? message;
  Data? data;

  PricingModel({this.success, this.message, this.data});

  PricingModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  double? unitPrice;
  int? minimumOrderQuantity;
  int? currentStock;
  String? discountType;
  double? discountAmount;
  double? shippingCost;
  int? isShippingCostMultil;
  List<TaxVatModel>? vatTax;

  Data(
      {this.unitPrice,
        this.minimumOrderQuantity,
        this.currentStock,
        this.discountType,
        this.discountAmount,
        this.shippingCost,
        this.isShippingCostMultil,
        this.vatTax});

  Data.fromJson(Map<String, dynamic> json) {
    unitPrice = double.tryParse(json['unit_price'].toString());
    minimumOrderQuantity = json['minimum_order_quantity'];
    currentStock = json['current_stock'];
    discountType = json['discount_type'];
    discountAmount = double.tryParse(json['discount_amount'].toString());
    shippingCost = double.tryParse(json['shipping_cost'].toString());
    isShippingCostMultil = json['is_shipping_cost_multil'];
    if (json['vatTax'] != null) {
      vatTax = <TaxVatModel>[];
      json['vatTax'].forEach((v) {
        vatTax!.add(TaxVatModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unit_price'] = unitPrice;
    data['minimum_order_quantity'] = minimumOrderQuantity;
    data['current_stock'] = currentStock;
    data['discount_type'] = discountType;
    data['discount_amount'] = discountAmount;
    data['shipping_cost'] = shippingCost;
    data['is_shipping_cost_multil'] = isShippingCostMultil;
    if (vatTax != null) {
      data['vatTax'] = vatTax!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
