import 'package:zulors_shop_vendor/data/model/image_full_url.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/enums/product_type_enum.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';

class ProductModel {

  int? totalSize;
  int? limit;
  int? offset;
  ProductTypeEnum? productType;
  double? minPrice;
  double? maxPrice;
  DateTime? startDate;
  DateTime? endDate;
  Set<int>? brandIds;
  List<int>? categoryIds;
  Set<int>? publishHouseIds;
  Set<int>? authorIds;
  String? search;
  List<Product>? _products;

  List<Product>? get products => _products;

  ProductModel.fromJson(Map<String, dynamic> json, {bool fromGetProducts = false}) {
    totalSize = int.tryParse('${json['total_size']}');
    limit = int.parse(json['limit'].toString());
    offset = int.parse(json['offset'].toString());

    if(json['product_type'] != null) {
      productType = _getProductType(json['product_type']);
    }
    minPrice = double.tryParse('${json['min_price']}');
    maxPrice = double.tryParse('${json['max_price']}');
    startDate = DateConverter.convertDurationDateTimeFromString(json['start_date']);
    endDate = DateConverter.convertDurationDateTimeFromString(json['end_date']);
    search = json['search'];

    // Parse brandIds and categoryIds as lists of integers
    if (json['brand_ids'] != null) {
      brandIds = Set<int>.from(json['brand_ids'].map((id) => int.parse(id.toString())));
    }
    if (json['category_ids'] != null) {
      categoryIds = List<int>.from(json['category_ids'].map((id) => int.parse(id.toString())));
    }

    if (json['publishing_house_ids'] != null) {
      publishHouseIds = Set<int>.from(json['publishing_house_ids'].map((id) => int.parse(id.toString())));
    }

    if(json['author_ids'] != null) {
      authorIds = Set<int>.from(json['author_ids'].map((id) => int.parse(id.toString())));
    }

    if (json['products'] != null) {
      _products = [];
      json['products'].forEach((v) {
        _products!.add(Product.fromJson(v, fromGetProducts: fromGetProducts));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (_products != null) {
      data['products'] = _products!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  ProductTypeEnum _getProductType(String value) {
    switch(value) {
      case 'all': {
        return ProductTypeEnum.all;
      }
      case 'physical': {
        return ProductTypeEnum.physical;
      }
      case 'digital': {
        return ProductTypeEnum.digital;

      }
      default: {
        return ProductTypeEnum.all;
      }
    }
  }
}

class Product {
  int? id;
  String? addedBy;
  int? userId;
  String? name;
  String? slug;
  String? productType;
  String? code;
  int? brandId;
  List<CategoryIds>? categoryIds;
  String? unit;
  List<String?>? images;
  List<ImageFullUrl>? imagesFullUrl;
  String? thumbnail;
  ImageFullUrl? thumbnailFullUrl;
  List<ProductColors>? colors;
  List<int?>? attributes;
  List<ChoiceOptions>? choiceOptions;
  List<Variation>? variation;
  List<String>? digitalProductFileTypes;
  Map<String, dynamic>? digitalProductExtensions;
  double? unitPrice;
  double? purchasePrice;
  double? tax;
  String? taxModel;
  int? minQty;
  String? taxType;
  double? discount;
  String? discountType;
  int? currentStock;
  String? details;
  String? createdAt;
  String? updatedAt;
  int? status;
  int? requestStatus;
  List<Rating>? rating;
  String? metaTitle;
  String? metaDescription;
  String? metaImage;
  double? shippingCost;
  int? multiplyWithQuantity;
  int? minimumOrderQty;
  String? digitalProductType;
  String? digitalFileReady;
  int? reviewsCount;
  String? averageReview;
  List<Reviews>? reviews;
  String? deniedNote;
  List<Tags>? tags;
  MetaSeoInfo? metaSeoInfo;
  List<DigitalVariation>? digitalVariation;
  ImageFullUrl? metaImageFullUrl;
  List<String?>? authors;
  List<String?>? publishingHouse;
  ImageFullUrl? previewFileFullUrl;
  Brand? brand;
  Category? category;
  ClearanceSale? clearanceSale;
  ImageFullUrl? digitalFileReadyFullUrl;
  String? videoUrl;
  List<int?>? taxIds;
  List<TaxVats>? taxVats;

  Product(
      {this.id,
        this.addedBy,
        this.userId,
        this.name,
        this.slug,
        this.productType,
        this.code,
        this.brandId,
        this.categoryIds,
        this.unit,
        this.minQty,
        this.images,
        this.imagesFullUrl,
        this.thumbnail,
        this.thumbnailFullUrl,
        this.metaImageFullUrl,
        this.colors,
        String? variantProduct,
        this.attributes,
        this.choiceOptions,
        this.variation,
        this.digitalProductFileTypes,
        this.digitalProductExtensions,
        this.unitPrice,
        this.purchasePrice,
        this.tax,
        this.taxModel,
        this.taxType,
        this.discount,
        this.discountType,
        this.currentStock,
        this.details,
        String? attachment,
        this.createdAt,
        this.updatedAt,
        this.status,
        this.requestStatus,
        int? featuredStatus,
        this.rating,
        this.metaTitle,
        this.metaDescription,
        this.metaImage,
        this.shippingCost,
        this.multiplyWithQuantity,
        this.minimumOrderQty,
        String? digitalProductType,
        String? digitalFileReady,
        int? reviewsCount,
        String? averageReview,
        List<Reviews>? reviews,
        String? deniedNote,
        List<Tags>? tags,
        this.metaSeoInfo,
        this.digitalVariation,
        this.authors,
        this.publishingHouse,
        this.previewFileFullUrl,
        this.brand,
        this.category,
        this.clearanceSale,
        this.digitalFileReadyFullUrl,
        this.videoUrl,
        this.taxIds,
        this.taxVats
      }) {
    if (digitalProductType != null) {
      this.digitalProductType = digitalProductType;
    }
    if (digitalFileReady != null) {
      this.digitalFileReady = digitalFileReady;
    }
    if (reviewsCount != null) {
      this.reviewsCount = reviewsCount;
    }
    if (averageReview != null) {
      this.averageReview = averageReview;
    }
    if (reviews != null) {
      this.reviews = reviews;
    }
    if (deniedNote != null) {
      this.deniedNote = deniedNote;
    }
    if (tags != null) {
      this.tags = tags;
    }

    if(taxIds != null) {
      taxIds = taxIds;
    }



  }

  Product.fromJson(Map<String, dynamic> json, {bool fromGetProducts = false}) {
    id = json['id'];
    addedBy = json['added_by'];
    userId = json['user_id'];
    name = json['name'];
    slug = json['slug'];
    productType = json['product_type'];
    code = json['code'];
    brandId = json['brand_id'];
    if (json['category_ids'] != null && json['category_ids'] is !String) {
      categoryIds = [];
      json['category_ids'].forEach((v) {
        categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    unit = json['unit'];
    minQty = json['min_qty'];
    if(json['images'] != null && json['category_ids'] is !String && json['images'] is List){
      images = json['images'] != null ? json['images'].cast<String>() : [];
    }

    thumbnail = json['thumbnail'];
    if (json['colors_formatted'] != null && json['category_ids'] is !String) {
      colors = [];
      json['colors_formatted'].forEach((v) {
        colors!.add(ProductColors.fromJson(v));
      });
    }
    if(json['attributes'] != null && json['category_ids'] is !String) {
      attributes = [];
      for(int index=0; index<json['attributes'].length; index++) {
        attributes!.add(int.parse(json['attributes'][index].toString()));
      }
    }
    if (json['choice_options'] != null && json['category_ids'] is !String) {
      choiceOptions = [];
      json['choice_options'].forEach((v) {
        choiceOptions!.add(ChoiceOptions.fromJson(v));
      });
    }
    if (json['variation'] != null && json['category_ids'] is !String) {
      variation = [];
      json['variation'].forEach((v) {
        variation!.add(Variation.fromJson(v));
      });
    }
    if(json['digital_product_file_types'] != null) {
      digitalProductFileTypes = json['digital_product_file_types'].cast<String>();
    }else {
      digitalProductFileTypes = [];
    }

    if(json['digital_product_extensions'] != null && json['digital_product_extensions'] is !List) {
      digitalProductExtensions = (json['digital_product_extensions'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, List<String>.from(value)),
      );
    }
    unitPrice = json['unit_price'].toDouble();
    purchasePrice = json['purchase_price'].toDouble();
    tax =  json['tax']?.toDouble();
    taxModel = json['tax_model'];
    taxType = json['tax_type'];
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    currentStock = json['current_stock'];
    details = json['details'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    status = json['status'];
    if(json['request_status'] != null) {
      try{
        requestStatus = json['request_status'];
      }catch(e){
        requestStatus = int.parse(json['request_status']);
      }
    }
    deniedNote = json['denied_note'];


    if (json['rating'] != null) {
      rating = [];
      json['rating'].forEach((v) {
        rating!.add(Rating.fromJson(v));
      });
    }
    metaTitle = json['meta_title'];
    metaDescription = json['meta_description'];
    metaImage = json['meta_image'];
    if(json['shipping_cost']!=null){
      shippingCost = json['shipping_cost'].toDouble();
    }
    if(json['multiply_qty']!=null){
      multiplyWithQuantity = json['multiply_qty'];
    }
    if(json['minimum_order_qty']!=null){
      try{
        minimumOrderQty = json['minimum_order_qty'];
      }catch(e){
        minimumOrderQty = int.parse(json['minimum_order_qty'].toString());
      }
    }
    if(json['digital_product_type']!=null){
      digitalProductType = json['digital_product_type'];
    }
    if(json['digital_file_ready']!=null){
      digitalFileReady = json['digital_file_ready'];
    }
    if(json['reviews_count'] != null){
      reviewsCount = int.parse(json['reviews_count'].toString());
    }else{
      reviewsCount = 0;
    }

    averageReview = json['average_review'].toString();
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(Reviews.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(Tags.fromJson(v));
      });
    }
    metaSeoInfo = json['seo_info'] != null
      ? MetaSeoInfo.fromJson(json['seo_info'], fromGetProducts: fromGetProducts)
      : null;

    thumbnailFullUrl = json['thumbnail_full_url'] != null
      ? ImageFullUrl.fromJson(json['thumbnail_full_url'])
      : null;
    metaImageFullUrl  = json['meta_image_full_url'] != null
      ? ImageFullUrl.fromJson(json['meta_image_full_url'])
      : null;

    previewFileFullUrl  = json['preview_file_full_url'] != null
      ? ImageFullUrl.fromJson(json['preview_file_full_url'])
      : null;

    if (json['images_full_url'] != null) {
     imagesFullUrl = <ImageFullUrl>[];
      json['images_full_url'].forEach((v) {
        imagesFullUrl!.add(ImageFullUrl.fromJson(v));
      });
    }

    if (json['digital_variation'] != null) {
      digitalVariation = <DigitalVariation>[];
      json['digital_variation'].forEach((v) {
        digitalVariation!.add(DigitalVariation.fromJson(v));
      });
    } else {
      digitalVariation = [];
    }

    if(json['digital_product_authors_names'] != null && json['digital_product_authors_names'] is !String && json['digital_product_authors_names'] is List){
      authors = json['digital_product_authors_names'] != null ? json['digital_product_authors_names'].cast<String>() : [];
    }

    if(json['digital_product_publishing_house_names'] != null && json['digital_product_publishing_house_names'] is !String && json['digital_product_publishing_house_names'] is List){
      publishingHouse = json['digital_product_publishing_house_names'] != null ? json['digital_product_publishing_house_names'].cast<String>() : [];
    }

    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;

    category = json['category'] != null ? Category.fromJson(json['category']) : null;

    clearanceSale = json['clearance_sale'] != null ? ClearanceSale.fromJson(json['clearance_sale']) : null;

    digitalFileReadyFullUrl = json['digital_file_ready_full_url'] != null
      ? ImageFullUrl.fromJson(json['digital_file_ready_full_url'])
      : null;

    if(json['video_url']!=null){
      videoUrl = json['video_url'];
    }

    if (json['tax_ids'] != null && json['tax_ids'] is !String) {
      taxIds = [];
      json['tax_ids'].forEach((v) {
        taxIds!.add(v);
      });
    }

    if (json['tax_vats'] != null) {
      taxVats = <TaxVats>[];
      json['tax_vats'].forEach((v) {
        taxVats!.add(TaxVats.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['added_by'] = addedBy;
    data['user_id'] = userId;
    data['name'] = name;
    data['slug'] = slug;
    data['product_type'] = productType;
    data['code'] = code;
    data['brand_id'] = brandId;
    if (categoryIds != null) {
      data['category_ids'] = categoryIds!.map((v) => v.toJson()).toList();
    }
    data['unit'] = unit;
    data['min_qty'] = minQty;
    data['images'] = images;
    data['authors'] = authors;
    data['publishing_house'] = publishingHouse;
    data['thumbnail'] = thumbnail;
    if (colors != null ) {
      data['colors_formatted'] = colors!.map((v) => v.toJson()).toList();
    }
    data['attributes'] = attributes;
    if (choiceOptions != null) {
      data['choice_options'] =
          choiceOptions!.map((v) => v.toJson()).toList();
    }
    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }
    data['unit_price'] = unitPrice;
    data['purchase_price'] = purchasePrice;
    data['tax'] = tax;
    data['tax_model'] = taxModel;
    data['tax_type'] = taxType;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['current_stock'] = currentStock;
    data['details'] = details;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['status'] = status;
    data['denied_note'] = deniedNote;
    data['request_status'] = requestStatus;
    if (rating != null) {
      data['rating'] = rating!.map((v) => v.toJson()).toList();
    }
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_image'] = metaImage;
    data['shipping_cost'] = shippingCost;
    data['multiply_qty'] = multiplyWithQuantity;
    data['minimum_order_qty'] = minimumOrderQty;
    data['digital_product_type'] = digitalProductType;
    data['digital_file_ready'] = digitalFileReady;
    data['reviews_count'] = reviewsCount;
    data['average_review'] = averageReview;
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.map((v) => v.toJson()).toList();
    }
    if (metaSeoInfo != null) {
      data['seo_info'] = metaSeoInfo!.toJson();
    }
    if(clearanceSale != null) {
      data['clearance_sale'] = clearanceSale!.toJson();
    }
    data['video_url'] = averageReview;
    data['tax_ids'] = taxIds;

    if (taxVats != null) {
      data['tax_vats'] = taxVats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DigitalVariation {
  int? id;
  int? productId;
  String? variantKey;
  String? sku;
  double? price;
  String? file;
  String? createdAt;
  String? updatedAt;
  ImageFullUrl? fileFullUrl;

  DigitalVariation(
      {this.id,
        this.productId,
        this.variantKey,
        this.sku,
        this.price,
        this.file,
        this.createdAt,
        this.updatedAt,
        this.fileFullUrl
      });

  DigitalVariation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    variantKey = json['variant_key'];
    sku = json['sku'];
    price = json['price'] != null ?
    double.tryParse(json['price'].toString()) : null;
    file = json['file'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fileFullUrl =  json['file_full_url'] != null
        ? ImageFullUrl.fromJson(json['file_full_url']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['variant_key'] = variantKey;
    data['sku'] = sku;
    data['price'] = price;
    data['file'] = file;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class CategoryIds {
  String? id;
  int? position;

  CategoryIds({this.id, this.position});


  CategoryIds.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['position'] = position;
    return data;
  }
}

class ProductColors {
  String? _name;
  String? _code;

  ProductColors({String? name, String? code}) {
    _name = name;
    _code = code;
  }

  String? get name => _name;
  String? get code => _code;

  ProductColors.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    data['code'] = _code;
    return data;
  }
}

class ChoiceOptions {
  String? _name;
  String? _title;
  List<String>? _options;

  ChoiceOptions({String? name, String? title, List<String>? options}) {
    _name = name;
    _title = title;
    _options = options;
  }

  String? get name => _name;
  String? get title => _title;
  List<String>? get options => _options;

  ChoiceOptions.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _title = json['title'];
    _options = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    data['title'] = _title;
    data['options'] = _options;
    return data;
  }
}

class Variation {
  String? _type;
  double? _price;
  String? _sku;
  int? _qty;

  Variation({String? type, double? price, String? sku, int? qty}) {
    _type = type;
    _price = price;
    _sku = sku;
    _qty = qty;
  }

  String? get type => _type;
  double? get price => _price;
  String? get sku => _sku;
  int? get qty => _qty;

  Variation.fromJson(Map<String, dynamic> json) {
    _type = json['type'];
    _price = json['price'].toDouble();
    _sku = json['sku'];
    _qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = _type;
    data['price'] = _price;
    data['sku'] = _sku;
    data['qty'] = _qty;
    return data;
  }
}

class Rating {
  String? _average;
  int? _productId;

  Rating({String? average, int? productId}) {
    _average = average;
    _productId = productId;
  }

  String? get average => _average;
  int? get productId => _productId;

  Rating.fromJson(Map<String, dynamic> json) {
    _average = json['average'].toString();
    _productId = json['product_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['average'] = _average;
    data['product_id'] = _productId;
    return data;
  }
}

class Reviews {
  int? _id;
  int? _productId;
  int? _customerId;
  String? _comment;
  String? _attachment;
  int? _rating;
  int? _status;
  String? _createdAt;
  String? _updatedAt;
  Customer? _customer;
  List<ImageFullUrl>? _attachmentFullUrl;

  Reviews(
      {int? id,
        int? productId,
        int? customerId,
        String? comment,
        String? attachment,
        int? rating,
        int? status,
        String? createdAt,
        String? updatedAt,
        Customer? customer,
        List<ImageFullUrl>? attachmentFullUrl}) {
    if (id != null) {
      _id = id;
    }
    if (productId != null) {
      _productId = productId;
    }
    if (customerId != null) {
      _customerId = customerId;
    }
    if (comment != null) {
      _comment = comment;
    }
    if (attachment != null) {
      _attachment = attachment;
    }
    if (rating != null) {
      _rating = rating;
    }
    if (status != null) {
      _status = status;
    }
    if (createdAt != null) {
      _createdAt = createdAt;
    }
    if (updatedAt != null) {
      _updatedAt = updatedAt;
    }
    if (customer != null) {
      _customer = customer;
    }
    if(attachmentFullUrl != null) {
      _attachmentFullUrl = attachmentFullUrl;
    }
  }

  int? get id => _id;
  int? get productId => _productId;
  int? get customerId => _customerId;
  String? get comment => _comment;
  String? get attachment => _attachment;
  int? get rating => _rating;
  int? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  Customer? get customer => _customer;
  List<ImageFullUrl>? get attachmentFullUrl => _attachmentFullUrl;

  Reviews.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _productId = json['product_id'];
    _customerId = json['customer_id'];
    _comment = json['comment'];
    if(json['attachment'] is String) {
      _attachment = json['attachment'];
    }
    _rating = json['rating'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _customer = json['customer'] != null
      ? Customer.fromJson(json['customer'])
      : null;
    if (json['attachment_images_full_url'] != null) {
      _attachmentFullUrl = <ImageFullUrl>[];
      json['attachment_images_full_url'].forEach((v) {
        _attachmentFullUrl!.add(ImageFullUrl.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['product_id'] = _productId;
    data['customer_id'] = _customerId;
    data['comment'] = _comment;
    data['attachment'] = _attachment;
    data['rating'] = _rating;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    if (_customer != null) {
      data['customer'] = _customer!.toJson();
    }
    return data;
  }
}

class Customer {
  int? _id;
  String? _fName;
  String? _lName;
  String? _phone;
  String? _image;
  String? _email;
  ImageFullUrl? _imageFullUrl;

  Customer(
      {int? id,
        String? fName,
        String? lName,
        String? phone,
        String? image,
        String? email,
        ImageFullUrl? imageFullUrl,
      }) {
    if (id != null) {
      _id = id;
    }
    if (fName != null) {
      _fName = fName;
    }
    if (lName != null) {
      _lName = lName;
    }
    if (phone != null) {
      _phone = phone;
    }
    if (image != null) {
      _image = image;
    }
    if (email != null) {
      _email = email;
    }

    if (imageFullUrl != null) {
      _imageFullUrl = imageFullUrl;
    }


  }

  int? get id => _id;
  String? get fName => _fName;
  String? get lName => _lName;
  String? get phone => _phone;
  String? get image => _image;
  String? get email => _email;
  ImageFullUrl? get imageFullUrl => _imageFullUrl;


  Customer.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _fName = json['f_name'];
    _lName = json['l_name'];
    _phone = json['phone'];
    _image = json['image'];
    _email = json['email'];
    _imageFullUrl = json['image_full_url'] != null
        ? ImageFullUrl.fromJson(json['image_full_url'])
        : null;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['f_name'] = _fName;
    data['l_name'] = _lName;
    data['phone'] = _phone;
    data['image'] = _image;
    data['email'] = _email;

    return data;
  }
}

class Tags {
  int? id;
  String? tag;


  Tags({this.id, this.tag});

  Tags.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tag = json['tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tag'] = tag;
    return data;
  }
}

class MetaSeoInfo {
  int? metaId;
  int? metaProductId;
  String? metaTitle;
  String? metaDescription;
  String? metaIndex;
  String? metaNoIndex;
  String? metaNoFollow;
  String? metaNoImageIndex;
  String? metaNoArchive;
  String? metaNoSnippet;
  String? metaMaxSnippet;
  String? metaMaxSnippetValue;
  String? metaMaxVideoPreview;
  String? metaMaxVideoPreviewValue;
  String? metaMaxImagePreview;
  String? metaMaxImagePreviewValue;
  String? metaImage;
  String? metaCreatedAt;
  String? metaUpdatedAt;
  ImageFullUrl? imageFullUrl;


  MetaSeoInfo(
      {this.metaId,
        this.metaProductId,
        this.metaTitle,
        this.metaDescription,
        this.metaIndex = '1',
        this.metaNoIndex,
        this.metaNoFollow = '',
        this.metaNoImageIndex = '0',
        this.metaNoArchive = '0',
        this.metaNoSnippet = '0',
        this.metaMaxSnippet = '0',
        this.metaMaxSnippetValue,
        this.metaMaxVideoPreview = '0',
        this.metaMaxVideoPreviewValue,
        this.metaMaxImagePreview = '0',
        this.metaMaxImagePreviewValue,
        this.metaImage,
        this.metaCreatedAt,
        this.metaUpdatedAt,
        this.imageFullUrl
      });

  MetaSeoInfo.fromJson(Map<String, dynamic> json, {bool fromGetProducts = false}) {
    metaTitle = fromGetProducts ? json['title'] : json['meta_title'];
    metaDescription = fromGetProducts ? json['description'] : json['meta_description'];
    metaIndex = fromGetProducts ? json['index'] : json['meta_index'];
    metaNoIndex = fromGetProducts ? json['index'] : json['meta_index'];
    metaNoFollow = fromGetProducts ? json['no_follow'] : json['meta_no_follow'];
    metaNoImageIndex = fromGetProducts  ? json['no_image_index'] : json['meta_no_image_index'];
    metaNoArchive = fromGetProducts  ? json['no_archive'] : json['meta_no_archive'];
    metaNoSnippet = fromGetProducts  ? json['no_snippet'] : json['meta_no_snippet'];
    metaMaxSnippet = fromGetProducts  ? json['max_snippet'] : json['meta_max_snippet'];
    metaMaxSnippetValue = fromGetProducts  ? json['max_snippet_value'] : json['meta_max_snippet_value'];
    metaMaxVideoPreview = fromGetProducts  ? json['max_video_preview'] : json['meta_max_video_preview'];
    metaMaxVideoPreviewValue = fromGetProducts  ? json['max_video_preview_value'] : json['meta_max_video_preview_value'];
    metaMaxImagePreview = fromGetProducts  ? json['max_image_preview'] : json['meta_max_image_preview'];
    metaMaxImagePreviewValue = fromGetProducts  ? json['max_image_preview_value'] : json['meta_max_image_preview_value'];
    metaImage = fromGetProducts  ? json['meta_image'] : json['meta_image'];
    imageFullUrl  = json['image_full_url'] != null
      ? ImageFullUrl.fromJson(json['image_full_url'])
      : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['meta_id'] = metaId;
    data['meta_product_id'] = metaProductId;
    data['meta_title'] = metaTitle;
    data['meta_description'] = metaDescription;
    data['meta_index'] = metaIndex;
    data['meta_no_follow'] = metaNoFollow;
    data['meta_no_image_index'] = metaNoImageIndex;
    data['meta_no_archive'] = metaNoArchive;
    data['meta_no_snippet'] = metaNoSnippet;
    data['meta_max_snippet'] = metaMaxSnippet;
    data['meta_max_snippet_value'] = metaMaxSnippetValue;
    data['meta_max_video_preview'] = metaMaxVideoPreview;
    data['meta_max_video_preview_value'] = metaMaxVideoPreviewValue;
    data['meta_max_image_preview'] = metaMaxImagePreview;
    data['meta_max_image_preview_value'] = metaMaxImagePreviewValue;
    data['meta_image'] = metaImage;
    data['meta_created_at'] = metaCreatedAt;
    data['meta_updated_at'] = metaUpdatedAt;
    return data;
  }
}

class Brand {
  int? id;
  String? name;
  String? image;
  String? imageStorageType;
  int? status;
  String? createdAt;
  String? updatedAt;

  Brand(
      {this.id,
        this.name,
        this.image,
        this.imageStorageType,
        this.status,
        this.createdAt,
        this.updatedAt
      });

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    imageStorageType = json['image_storage_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['image_storage_type'] = imageStorageType;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? slug;
  String? icon;
  String? iconStorageType;
  int? parentId;
  int? position;
  String? createdAt;
  String? updatedAt;
  int? homeStatus;
  int? priority;

  Category(
      {this.id,
        this.name,
        this.slug,
        this.icon,
        this.iconStorageType,
        this.parentId,
        this.position,
        this.createdAt,
        this.updatedAt,
        this.homeStatus,
        this.priority
      });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    icon = json['icon'];
    iconStorageType = json['icon_storage_type'];
    parentId = json['parent_id'];
    position = json['position'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    homeStatus = json['home_status'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['icon'] = icon;
    data['icon_storage_type'] = iconStorageType;
    data['parent_id'] = parentId;
    data['position'] = position;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['home_status'] = homeStatus;
    data['priority'] = priority;
    return data;
  }
}

class ClearanceSale {
  int? id;
  String? addedBy;
  int? productId;
  int? setupId;
  int? userId;
  int? shopId;
  int? isActive;
  String? discountType;
  double? discountAmount;
  String? createdAt;
  String? updatedAt;

  ClearanceSale(
      {this.id,
        this.addedBy,
        this.productId,
        this.setupId,
        this.userId,
        this.shopId,
        this.isActive,
        this.discountType,
        this.discountAmount,
        this.createdAt,
        this.updatedAt});

  ClearanceSale.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addedBy = json['added_by'];
    productId = json['product_id'];
    setupId = json['setup_id'];
    userId = json['user_id'];
    shopId = json['shop_id'];
    isActive = json['is_active'];
    discountType = json['discount_type'];
    discountAmount = json['discount_amount'] != null ?
    double.tryParse(json['discount_amount'].toString()) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['added_by'] = addedBy;
    data['product_id'] = productId;
    data['setup_id'] = setupId;
    data['user_id'] = userId;
    data['shop_id'] = shopId;
    data['is_active'] = isActive;
    data['discount_type'] = discountType;
    data['discount_amount'] = discountAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


class TaxVats {
  int? id;
  String? taxableType;
  int? taxableId;
  int? taxId;
  int? systemTaxSetupId;
  String? createdAt;
  String? updatedAt;
  TaxVatModel? tax;

  TaxVats(
      {this.id,
        this.taxableType,
        this.taxableId,
        this.taxId,
        this.systemTaxSetupId,
        this.createdAt,
        this.updatedAt,
        this.tax});

  TaxVats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxableType = json['taxable_type'];
    taxableId = json['taxable_id'];
    taxId = json['tax_id'];
    systemTaxSetupId = json['system_tax_setup_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    tax = json['tax'] != null ? TaxVatModel.fromJson(json['tax']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['taxable_type'] = taxableType;
    data['taxable_id'] = taxableId;
    data['tax_id'] = taxId;
    data['system_tax_setup_id'] = systemTaxSetupId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (tax != null) {
      data['tax'] = tax!.toJson();
    }
    return data;
  }
}

