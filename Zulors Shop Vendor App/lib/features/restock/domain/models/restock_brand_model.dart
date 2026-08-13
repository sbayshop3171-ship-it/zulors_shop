class RestockBrand {
  List<Brands>? brands;

  RestockBrand({this.brands});

  RestockBrand.fromJson(Map<String, dynamic> json) {
    if (json['brands'] != null) {
      brands = <Brands>[];
      json['brands'].forEach((v) {
        brands!.add(Brands.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Brands {
  int? id;
  String? name;
  String? image;
  int? brandAllProductsCount;
  int? productCount;
  bool? checked;

  Brands(
    {this.id,
      this.name,
      this.image,
      this.brandAllProductsCount,
      this.productCount,
      this.checked
    });

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    brandAllProductsCount = json['brand_all_products_count'];
    productCount = json['product_count'];
    checked = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['brand_all_products_count'] = brandAllProductsCount;
    data['product_count'] = productCount;
    return data;
  }
}

class ImageFullUrl {
  String? key;
  String? path;
  int? status;

  ImageFullUrl({this.key, this.path, this.status});

  ImageFullUrl.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    path = json['path'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['path'] = path;
    data['status'] = status;
    return data;
  }
}
