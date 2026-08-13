class GeneralSetupModel {
  bool? success;
  String? message;
  Data? data;

  GeneralSetupModel({this.success, this.message, this.data});

  GeneralSetupModel.fromJson(Map<String, dynamic> json) {
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
  String? categoryName;
  String? subCategoryName;
  String? subSubCategoryName;
  String? brandName;
  String? unitName;
  String? productType;
  String? deliveryType;
  List<String>? searchTags;
  int? categoryId;
  int? subCategoryId;
  int? subSubCategoryId;
  int? brandId;

  Data(
      {this.categoryName,
        this.subCategoryName,
        this.subSubCategoryName,
        this.brandName,
        this.unitName,
        this.productType,
        this.deliveryType,
        this.searchTags,
        this.categoryId,
        this.subCategoryId,
        this.subSubCategoryId,
        this.brandId});

  Data.fromJson(Map<String, dynamic> json) {
    categoryName = json['category_name'];
    subCategoryName = json['sub_category_name'];
    subSubCategoryName = json['sub_sub_category_name'];
    brandName = json['brand_name'];
    unitName = json['unit_name'];
    productType = json['product_type'];
    deliveryType = json['delivery_type'];
    searchTags = json['search_tags'].cast<String>();
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    subSubCategoryId = json['sub_sub_category_id'];
    brandId = json['brand_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_name'] = categoryName;
    data['sub_category_name'] = subCategoryName;
    data['sub_sub_category_name'] = subSubCategoryName;
    data['brand_name'] = brandName;
    data['unit_name'] = unitName;
    data['product_type'] = productType;
    data['delivery_type'] = deliveryType;
    data['search_tags'] = searchTags;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['sub_sub_category_id'] = subSubCategoryId;
    data['brand_id'] = brandId;
    return data;
  }
}
