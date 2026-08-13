import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';

class ClearanceSaleProductModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<Products>? products;

  ClearanceSaleProductModel(
      {this.totalSize, this.limit, this.offset, this.products});

  ClearanceSaleProductModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['products'] != null) {
      products = <Products>[];
      json['products'].forEach((v) {
        products!.add(Products.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Products {
  int? id;
  String? addedBy;
  int? userId;
  int? shopId;
  int? productId;
  int? isActive;
  String? discountType;
  double? discountAmount;
  String? createdAt;
  String? updatedAt;
  Product? product;

  Products(
      {this.id,
        this.addedBy,
        this.userId,
        this.shopId,
        this.productId,
        this.isActive,
        this.discountType,
        this.discountAmount,
        this.createdAt,
        this.updatedAt,
        this.product});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addedBy = json['added_by'];
    userId = json['user_id'];
    shopId = json['shop_id'];
    productId = json['product_id'];
    isActive = json['is_active'];
    discountType = json['discount_type'];
    discountAmount = json['discount_amount'] !=null ? double.tryParse(json['discount_amount'].toString()) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['added_by'] = addedBy;
    data['user_id'] = userId;
    data['shop_id'] = shopId;
    data['product_id'] = productId;
    data['is_active'] = isActive;
    data['discount_type'] = discountType;
    data['discount_amount'] = discountAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}
