import 'package:zulors_shop_vendor/data/model/image_full_url.dart';

class ShopModel {
  int? id;
  String? name;
  String? address;
  String? contact;
  String? image;
  ImageFullUrl? imageFullUrl;
  String? createdAt;
  String? updatedAt;
  String? banner;
  ImageFullUrl? bannerFullUrl;
  ImageFullUrl? tinCertificateFullUrl;
  String? bottomBanner;
  ImageFullUrl? bottomBannerFullUrl;
  String? offerBanner;
  ImageFullUrl? offerBannerFullUrl;
  double? ratting;
  int? rattingCount;
  bool? temporaryClose;
  String? vacationEndDate;
  String? vacationStartDate;
  bool? vacationStatus;
  String? vacationDurationType;
  String? vacationNote;
  String? taxIdentificationNumber;
  String? tinExpireDate;
  int? totalReview;
  int? totalOrder;
  int? totalProducts;
  int? reorderLevel;
  Map<String, dynamic>? setupGuideApp;

  ShopModel(
      {this.id,
        this.name,
        this.address,
        this.contact,
        this.image,
        this.imageFullUrl,
        this.createdAt,
        this.updatedAt,
        this.banner,
        this.bannerFullUrl,
        this.tinCertificateFullUrl,
        this.bottomBanner,
        this.bottomBannerFullUrl,
        this.offerBanner,
        this.offerBannerFullUrl,
        this.ratting,
        this.rattingCount,
        this.temporaryClose,
        this.vacationEndDate,
        this.vacationStartDate,
        this.vacationStatus,
        this.vacationDurationType,
        this.vacationNote,
        this.taxIdentificationNumber,
        this.tinExpireDate,
        this.totalReview,
        this.totalOrder,
        this.totalProducts,
        this.setupGuideApp,
        this.reorderLevel,
      });

  ShopModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    contact = json['contact'];
    image = json['image'];
    imageFullUrl = json['image_full_url'] != null
      ? ImageFullUrl.fromJson(json['image_full_url'])
      : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    banner = json['banner'];
    bottomBanner = json['bottom_banner'];
    offerBanner = json['offer_banner'];
    ratting = json['rating'].toDouble();
    rattingCount = json['rating_count'];
    // temporaryClose = json['temporary_close']??false;

    temporaryClose = json['temporary_close'] != null ?
    !json['temporary_close']
    : true;



    vacationEndDate = json['vacation_end_date'];
    vacationStartDate = json['vacation_start_date'];
    vacationStatus = json['vacation_status']??false;
    offerBannerFullUrl = json['offer_banner_full_url'] != null
      ? ImageFullUrl.fromJson(json['offer_banner_full_url'])
      : null;
    bannerFullUrl = json['banner_full_url'] != null
        ? ImageFullUrl.fromJson(json['banner_full_url'])
        : null;
    bottomBannerFullUrl = json['bottom_banner_full_url'] != null
        ? ImageFullUrl.fromJson(json['bottom_banner_full_url'])
        : null;
    tinCertificateFullUrl = json['tin_certificate_full_url'] != null
      ? ImageFullUrl.fromJson(json['tin_certificate_full_url'])
      : null;
    vacationDurationType = json['vacation_duration_type'] ?? 'custom';
    vacationNote = json['vacation_note'] ?? '';
    taxIdentificationNumber = json['tax_identification_number'];
    tinExpireDate = json['tin_expire_date'];
    totalProducts = json['total_products'];
    totalOrder = json['total_orders'];
    totalReview = json['total_reviews'];
    setupGuideApp = json['setup_guide_app'] != null
      ? Map<String, dynamic>.from(json['setup_guide_app'])
      : null;

    reorderLevel = json['stock_limit'] != null
      ? int.tryParse(json['stock_limit'].toString())
      : null;
  }
}
