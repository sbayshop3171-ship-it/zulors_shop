class VatReportModel {
  double? totalTax;
  int? totalOrders;
  double? totalOrderAmount;
  int? totalSize;
  int? limit;
  int? offset;
  List<OrderTransactions>? orderTransactions;
  List<TypeWiseTaxesList>? typeWiseTaxesList;

  VatReportModel(
      {this.totalTax,
        this.totalOrders,
        this.totalOrderAmount,
        this.totalSize,
        this.limit,
        this.offset,
        this.orderTransactions,
        this.typeWiseTaxesList
      });

  VatReportModel.fromJson(Map<String, dynamic> json) {
    totalTax = double.tryParse(json['total_tax'].toString());
    totalOrders = int.tryParse(json['total_orders'].toString());
    totalOrderAmount = double.tryParse(json['total_order_amount'].toString());
    totalSize = json['total_size'];
    limit = int.tryParse(json['limit']);
    offset = int.tryParse(json['offset']);
    if (json['order_transactions'] != null) {
      orderTransactions = <OrderTransactions>[];
      json['order_transactions'].forEach((v) {
        orderTransactions!.add(OrderTransactions.fromJson(v));
      });
    }
    typeWiseTaxesList = (json['type_wise_taxes_list'] as List)
      .map((item) => TypeWiseTaxesList.fromJson(item))
      .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_tax'] = totalTax;
    data['total_orders'] = totalOrders;
    data['total_order_amount'] = totalOrderAmount;
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (orderTransactions != null) {
      data['order_transactions'] =
          orderTransactions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderTransactions {
  int? sellerId;
  int? orderId;
  double? orderAmount;
  String? sellerAmount;
  String? adminCommission;
  String? receivedBy;
  String? status;
  String? deliveryCharge;
  double? tax;
  String? createdAt;
  String? updatedAt;
  int? customerId;
  String? sellerIs;
  String? deliveredBy;
  String? paymentMethod;
  String? transactionId;
  int? id;
  Seller? seller;
  List<OrderTaxes>? orderTaxes;
  Order? order;
  String? taxType;
  VatAmountFormats? vatAmountFormats;

  OrderTransactions(
      {this.sellerId,
        this.orderId,
        this.orderAmount,
        this.sellerAmount,
        this.adminCommission,
        this.receivedBy,
        this.status,
        this.deliveryCharge,
        this.tax,
        this.createdAt,
        this.updatedAt,
        this.customerId,
        this.sellerIs,
        this.deliveredBy,
        this.paymentMethod,
        this.transactionId,
        this.id,
        this.seller,
        this.orderTaxes,
        this.order,
        this.taxType,
        this.vatAmountFormats
      });

  OrderTransactions.fromJson(Map<String, dynamic> json) {
    sellerId = json['seller_id'];
    orderId = json['order_id'];
    orderAmount =  double.tryParse(json['order_amount'].toString());
    sellerAmount = json['seller_amount'];
    adminCommission = json['admin_commission'];
    receivedBy = json['received_by'];
    status = json['status'];
    deliveryCharge = json['delivery_charge'];
    tax = double.tryParse(json['tax'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    customerId = json['customer_id'];
    sellerIs = json['seller_is'];
    deliveredBy = json['delivered_by'];
    paymentMethod = json['payment_method'];
    transactionId = json['transaction_id'];
    id = json['id'];
    seller =
    json['seller'] != null ? Seller.fromJson(json['seller']) : null;
    if (json['order_taxes'] != null) {
      orderTaxes = <OrderTaxes>[];
      json['order_taxes'].forEach((v) {
        orderTaxes!.add(OrderTaxes.fromJson(v));
      });
    }
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    taxType = json['tax_type'];
    vatAmountFormats = json['vat_amount_formats'] != null
      ? VatAmountFormats.fromJson(json['vat_amount_formats'])
      : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seller_id'] = sellerId;
    data['order_id'] = orderId;
    data['order_amount'] = orderAmount;
    data['seller_amount'] = sellerAmount;
    data['admin_commission'] = adminCommission;
    data['received_by'] = receivedBy;
    data['status'] = status;
    data['delivery_charge'] = deliveryCharge;
    data['tax'] = tax;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['customer_id'] = customerId;
    data['seller_is'] = sellerIs;
    data['delivered_by'] = deliveredBy;
    data['payment_method'] = paymentMethod;
    data['transaction_id'] = transactionId;
    data['id'] = id;
    if (seller != null) {
      data['seller'] = seller!.toJson();
    }
    if (orderTaxes != null) {
      data['order_taxes'] = orderTaxes!.map((v) => v.toJson()).toList();
    }
    if (order != null) {
      data['order'] = order!.toJson();
    }
    data['tax_type'] = taxType;
    if (vatAmountFormats != null) {
      data['vat_amount_formats'] = vatAmountFormats!.toJson();
    }
    return data;
  }
}

class Seller {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? image;
  String? email;
  String? password;
  String? status;
  String? rememberToken;
  String? createdAt;
  String? updatedAt;
  String? bankName;
  String? branch;
  String? accountNo;
  String? holderName;
  String? authToken;
  String? cmFirebaseToken;
  int? posStatus;
  int? minimumOrderAmount;
  int? freeDeliveryStatus;
  int? freeDeliveryOverAmount;
  int? stockLimit;
  String? appLanguage;
  ImageFullUrl? imageFullUrl;
  List<Storage>? storage;

  Seller(
      {this.id,
        this.fName,
        this.lName,
        this.phone,
        this.image,
        this.email,
        this.password,
        this.status,
        this.rememberToken,
        this.createdAt,
        this.updatedAt,
        this.bankName,
        this.branch,
        this.accountNo,
        this.holderName,
        this.authToken,
        this.cmFirebaseToken,
        this.posStatus,
        this.minimumOrderAmount,
        this.freeDeliveryStatus,
        this.freeDeliveryOverAmount,
        this.stockLimit,
        this.appLanguage,
        this.imageFullUrl,
        this.storage});

  Seller.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    image = json['image'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bankName = json['bank_name'];
    branch = json['branch'];
    accountNo = json['account_no'];
    holderName = json['holder_name'];
    authToken = json['auth_token'];
    cmFirebaseToken = json['cm_firebase_token'];
    posStatus = json['pos_status'];
    minimumOrderAmount = json['minimum_order_amount'];
    freeDeliveryStatus = json['free_delivery_status'];
    freeDeliveryOverAmount = json['free_delivery_over_amount'];
    stockLimit = json['stock_limit'];
    appLanguage = json['app_language'];
    imageFullUrl = json['image_full_url'] != null
        ? ImageFullUrl.fromJson(json['image_full_url'])
        : null;
    if (json['storage'] != null) {
      storage = <Storage>[];
      json['storage'].forEach((v) {
        storage!.add(Storage.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['f_name'] = fName;
    data['l_name'] = lName;
    data['phone'] = phone;
    data['image'] = image;
    data['email'] = email;
    data['password'] = password;
    data['status'] = status;
    data['remember_token'] = rememberToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['bank_name'] = bankName;
    data['branch'] = branch;
    data['account_no'] = accountNo;
    data['holder_name'] = holderName;
    data['auth_token'] = authToken;
    data['cm_firebase_token'] = cmFirebaseToken;
    data['pos_status'] = posStatus;
    data['minimum_order_amount'] = minimumOrderAmount;
    data['free_delivery_status'] = freeDeliveryStatus;
    data['free_delivery_over_amount'] = freeDeliveryOverAmount;
    data['stock_limit'] = stockLimit;
    data['app_language'] = appLanguage;
    if (imageFullUrl != null) {
      data['image_full_url'] = imageFullUrl!.toJson();
    }
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
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

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage(
      {this.id,
        this.dataType,
        this.dataId,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt});

  Storage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dataType = json['data_type'];
    dataId = json['data_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['data_type'] = dataType;
    data['data_id'] = dataId;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OrderTaxes {
  int? id;
  String? taxName;
  String? taxType;
  String? taxOn;
  double? taxRate;
  double? taxAmount;
  double? beforeTaxAmount;
  double? afterTaxAmount;
  String? taxPayer;
  int? orderId;
  String? orderType;
  int? quantity;
  int? taxId;
  int? taxableId;
  String? taxableType;
  int? sellerId;
  String? sellerType;
  int? systemTaxSetupId;
  String? createdAt;
  String? updatedAt;
  Tax? tax;

  OrderTaxes(
    { this.id,
      this.taxName,
      this.taxType,
      this.taxOn,
      this.taxRate,
      this.taxAmount,
      this.beforeTaxAmount,
      this.afterTaxAmount,
      this.taxPayer,
      this.orderId,
      this.orderType,
      this.quantity,
      this.taxId,
      this.taxableId,
      this.taxableType,
      this.sellerId,
      this.sellerType,
      this.systemTaxSetupId,
      this.createdAt,
      this.updatedAt,
      this.tax
    }
  );

  OrderTaxes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    taxName = json['tax_name'];
    taxType = json['tax_type'];
    taxOn = json['tax_on'];
    taxRate = double.tryParse(json['tax_rate'].toString());
    taxAmount = double.tryParse(json['tax_amount'].toString());
    beforeTaxAmount = double.tryParse(json['before_tax_amount'].toString());
    afterTaxAmount = double.tryParse(json['after_tax_amount'].toString());
    taxPayer = json['tax_payer'];
    orderId = json['order_id'];
    orderType = json['order_type'];
    quantity = json['quantity'];
    taxId = json['tax_id'];
    taxableId = json['taxable_id'];
    taxableType = json['taxable_type'];
    sellerId = json['seller_id'];
    sellerType = json['seller_type'];
    systemTaxSetupId = json['system_tax_setup_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    tax = json['tax'] != null ? Tax.fromJson(json['tax']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tax_name'] = taxName;
    data['tax_type'] = taxType;
    data['tax_on'] = taxOn;
    data['tax_rate'] = taxRate;
    data['tax_amount'] = taxAmount;
    data['before_tax_amount'] = beforeTaxAmount;
    data['after_tax_amount'] = afterTaxAmount;
    data['tax_payer'] = taxPayer;
    data['order_id'] = orderId;
    data['order_type'] = orderType;
    data['quantity'] = quantity;
    data['tax_id'] = taxId;
    data['taxable_id'] = taxableId;
    data['taxable_type'] = taxableType;
    data['seller_id'] = sellerId;
    data['seller_type'] = sellerType;
    data['system_tax_setup_id'] = systemTaxSetupId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (tax != null) {
      data['tax'] = tax!.toJson();
    }
    return data;
  }
}

class Tax {
  int? id;
  String? name;
  double? taxRate;
  int? isDefault;
  int? isActive;
  String? updatedAt;

  Tax(
      {this.id,
        this.name,
        this.taxRate,
        this.isDefault,
        this.isActive,
        this.updatedAt});

  Tax.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    taxRate = double.tryParse(json['tax_rate'].toString());
    isDefault = json['is_default'];
    isActive = json['is_active'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tax_rate'] = taxRate;
    data['is_default'] = isDefault;
    data['is_active'] = isActive;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Order {
  int? id;
  int? customerId;
  bool? isGuest;
  String? customerType;
  String? paymentStatus;
  String? orderStatus;
  String? paymentMethod;
  String? transactionRef;
  double? orderAmount;
  double? totalTaxAmount;
  String? taxType;
  String? taxModel;
  int? paidAmount;
  int? bringChangeAmount;
  String? bringChangeAmountCurrency;
  String? adminCommission;
  bool? isPause;
  String? shippingAddress;
  String? createdAt;
  String? updatedAt;
  int? discountAmount;
  String? couponCode;
  String? couponDiscountBearer;
  String? shippingResponsibility;
  int? shippingMethodId;
  int? shippingCost;
  bool? isShippingFree;
  String? orderGroupId;
  String? verificationCode;
  bool? verificationStatus;
  int? sellerId;
  String? sellerIs;
  ShippingAddressData? shippingAddressData;
  int? deliverymanCharge;
  int? billingAddress;
  ShippingAddressData? billingAddressData;
  String? orderType;
  int? extraDiscount;
  int? referAndEarnDiscount;
  bool? checked;
  String? shippingType;

  Order(
      {this.id,
        this.customerId,
        this.isGuest,
        this.customerType,
        this.paymentStatus,
        this.orderStatus,
        this.paymentMethod,
        this.transactionRef,
        this.orderAmount,
        this.totalTaxAmount,
        this.taxType,
        this.paidAmount,
        this.bringChangeAmount,
        this.bringChangeAmountCurrency,
        this.adminCommission,
        this.isPause,
        this.shippingAddress,
        this.createdAt,
        this.updatedAt,
        this.discountAmount,
        this.couponCode,
        this.couponDiscountBearer,
        this.shippingResponsibility,
        this.shippingMethodId,
        this.shippingCost,
        this.isShippingFree,
        this.orderGroupId,
        this.verificationCode,
        this.verificationStatus,
        this.sellerId,
        this.sellerIs,
        this.shippingAddressData,
        this.deliverymanCharge,
        this.billingAddress,
        this.billingAddressData,
        this.orderType,
        this.extraDiscount,
        this.referAndEarnDiscount,
        this.checked,
        this.shippingType,
        this.taxModel
      });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    isGuest = json['is_guest'];
    customerType = json['customer_type'];
    paymentStatus = json['payment_status'];
    orderStatus = json['order_status'];
    paymentMethod = json['payment_method'];
    transactionRef = json['transaction_ref'];
    orderAmount = double.tryParse(json['order_amount'].toString());
    totalTaxAmount = double.tryParse(json['total_tax_amount'].toString());
    taxType = json['tax_type'];
    paidAmount = json['paid_amount'];
    bringChangeAmount = json['bring_change_amount'];
    bringChangeAmountCurrency = json['bring_change_amount_currency'];
    adminCommission = json['admin_commission'];
    isPause = json['is_pause'];
    shippingAddress = json['shipping_address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    discountAmount = json['discount_amount'];
    couponCode = json['coupon_code'];
    couponDiscountBearer = json['coupon_discount_bearer'];
    shippingResponsibility = json['shipping_responsibility'];
    shippingMethodId = json['shipping_method_id'];
    shippingCost = json['shipping_cost'];
    isShippingFree = json['is_shipping_free'];
    orderGroupId = json['order_group_id'];
    verificationCode = json['verification_code'];
    verificationStatus = json['verification_status'];
    sellerId = json['seller_id'];
    sellerIs = json['seller_is'];
    shippingAddressData = json['shipping_address_data'] != null
      ? ShippingAddressData.fromJson(json['shipping_address_data'])
      : null;
    deliverymanCharge = json['deliveryman_charge'];
    billingAddress = json['billing_address'];
    billingAddressData = json['billing_address_data'] != null
      ? ShippingAddressData.fromJson(json['billing_address_data'])
      : null;
    orderType = json['order_type'];
    extraDiscount = json['extra_discount'];
    referAndEarnDiscount = json['refer_and_earn_discount'];
    checked = json['checked'];
    shippingType = json['shipping_type'];
    taxModel = json['tax_model'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['is_guest'] = isGuest;
    data['customer_type'] = customerType;
    data['payment_status'] = paymentStatus;
    data['order_status'] = orderStatus;
    data['payment_method'] = paymentMethod;
    data['transaction_ref'] = transactionRef;
    data['order_amount'] = orderAmount;
    data['total_tax_amount'] = totalTaxAmount;
    data['tax_type'] = taxType;
    data['paid_amount'] = paidAmount;
    data['bring_change_amount'] = bringChangeAmount;
    data['bring_change_amount_currency'] = bringChangeAmountCurrency;
    data['admin_commission'] = adminCommission;
    data['is_pause'] = isPause;
    data['shipping_address'] = shippingAddress;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['discount_amount'] = discountAmount;
    data['coupon_code'] = couponCode;
    data['coupon_discount_bearer'] = couponDiscountBearer;
    data['shipping_responsibility'] = shippingResponsibility;
    data['shipping_method_id'] = shippingMethodId;
    data['shipping_cost'] = shippingCost;
    data['is_shipping_free'] = isShippingFree;
    data['order_group_id'] = orderGroupId;
    data['verification_code'] = verificationCode;
    data['verification_status'] = verificationStatus;
    data['seller_id'] = sellerId;
    data['seller_is'] = sellerIs;
    if (shippingAddressData != null) {
      data['shipping_address_data'] = shippingAddressData!.toJson();
    }
    data['deliveryman_charge'] = deliverymanCharge;
    data['billing_address'] = billingAddress;
    if (billingAddressData != null) {
      data['billing_address_data'] = billingAddressData!.toJson();
    }
    data['order_type'] = orderType;
    data['extra_discount'] = extraDiscount;
    data['refer_and_earn_discount'] = referAndEarnDiscount;
    data['checked'] = checked;
    data['shipping_type'] = shippingType;
    data['tax_model'] = taxModel;
    return data;
  }
}

class ShippingAddressData {
  int? id;
  String? customerId;
  bool? isGuest;
  String? contactPersonName;
  String? addressType;
  String? address;
  String? city;
  String? zip;
  String? phone;
  String? country;
  String? latitude;
  String? longitude;

  ShippingAddressData(
      {this.id,
        this.customerId,
        this.isGuest,
        this.contactPersonName,
        this.addressType,
        this.address,
        this.city,
        this.zip,
        this.phone,
        this.country,
        this.latitude,
        this.longitude
      });

  ShippingAddressData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'].toString();
    isGuest = json['is_guest'];
    contactPersonName = json['contact_person_name'];
    addressType = json['address_type'];
    address = json['address'];
    city = json['city'];
    zip = json['zip'];
    phone = json['phone'];
    country = json['country'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['is_guest'] = isGuest;
    data['contact_person_name'] = contactPersonName;
    data['address_type'] = addressType;
    data['address'] = address;
    data['city'] = city;
    data['zip'] = zip;
    data['phone'] = phone;
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}



class TaxItem {
  final String name;
  final double? taxRate;
  final double? totalAmount;
  final double? taxAmount;

  TaxItem({
    required this.name,
    required this.taxRate,
    required this.totalAmount,
    required this.taxAmount,
  });

  factory TaxItem.fromJson(Map<String, dynamic> json) {
    return TaxItem(
      name: json['name'] ?? '',
      taxRate: double.tryParse(json['tax_rate'].toString()),
      totalAmount: double.tryParse(json['total_amount'].toString()),
      taxAmount: double.tryParse(json['tax_amount'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'tax_rate': taxRate,
    'total_amount': totalAmount,
    'tax_amount': taxAmount
  };
}


class TypeWiseTaxesList {
  String? name;
  List<TaxItem>? data;

  TypeWiseTaxesList({this.name, this.data});

  TypeWiseTaxesList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['data'] != null) {
      data = <TaxItem>[];
      json['data'].forEach((v) {
        data!.add(TaxItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}




class VatAmountFormats {
  String? totalVatAmount;
  List<AllVatGroups>? allVatGroups;

  VatAmountFormats({this.totalVatAmount, this.allVatGroups});

  VatAmountFormats.fromJson(Map<String, dynamic> json) {
    totalVatAmount = json['total_vat_amount'];
    if (json['all_vat_groups'] != null) {
      allVatGroups = <AllVatGroups>[];
      json['all_vat_groups'].forEach((v) {
        allVatGroups!.add(AllVatGroups.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_vat_amount'] = totalVatAmount;
    if (allVatGroups != null) {
      data['all_vat_groups'] =
          allVatGroups!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllVatGroups {
  String? groupName;
  List<TaxItem>? data;

  AllVatGroups({this.groupName, this.data});

  AllVatGroups.fromJson(Map<String, dynamic> json) {
    groupName = json['group_name'];
    if (json['data'] != null) {
      data = <TaxItem>[];
      json['data'].forEach((v) {
        data!.add(TaxItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['group_name'] = groupName;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

