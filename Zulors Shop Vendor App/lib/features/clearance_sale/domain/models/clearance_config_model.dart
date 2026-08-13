class ClearanceConfigModel {
  int? id;
  String? setupBy;
  int? userId;
  int? shopId;
  int? isActive;
  String? discountType;
  double? discountAmount;
  String? offerActiveTime;
  String? offerActiveRangeStart;
  String? offerActiveRangeEnd;
  int? showInHomepage;
  int? showInHomepageOnce;
  int? showInShop;
  String? durationStartDate;
  String? durationEndDate;
  String? createdAt;
  String? updatedAt;
  String? clearanceSaleDuration;

  ClearanceConfigModel(
      {this.id,
        this.setupBy,
        this.userId,
        this.shopId,
        this.isActive,
        this.discountType,
        this.discountAmount,
        this.offerActiveTime,
        this.offerActiveRangeStart,
        this.offerActiveRangeEnd,
        this.showInHomepage,
        this.showInHomepageOnce,
        this.showInShop,
        this.durationStartDate,
        this.durationEndDate,
        this.createdAt,
        this.updatedAt,
        this.clearanceSaleDuration
      });

  ClearanceConfigModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    setupBy = json['setup_by'];
    userId = json['user_id'];
    shopId = json['shop_id'];
    isActive = json['is_active'];
    discountType = json['discount_type'];
    discountAmount = double.tryParse('${json['discount_amount']}');
    offerActiveTime = json['offer_active_time'];
    offerActiveRangeStart = json['offer_active_range_start'];
    offerActiveRangeEnd = json['offer_active_range_end'];
    showInHomepage = json['show_in_homepage'];
    showInHomepageOnce = json['show_in_homepage_once'];
    showInShop = json['show_in_shop'];
    durationStartDate = json['duration_start_date'];
    durationEndDate = json['duration_end_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    clearanceSaleDuration = json['clearance_sale_duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['setup_by'] = setupBy;
    data['user_id'] = userId;
    data['shop_id'] = shopId;
    data['is_active'] = isActive;
    data['discount_type'] = discountType;
    data['discount_amount'] = discountAmount;
    data['offer_active_time'] = offerActiveTime;
    data['offer_active_range_start'] = offerActiveRangeStart;
    data['offer_active_range_end'] = offerActiveRangeEnd;
    data['show_in_homepage'] = showInHomepage;
    data['show_in_homepage_once'] = showInHomepageOnce;
    data['show_in_shop'] = showInShop;
    data['duration_start_date'] = durationStartDate;
    data['duration_end_date'] = durationEndDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['clearance_sale_duration'] = clearanceSaleDuration;
    return data;
  }
}
