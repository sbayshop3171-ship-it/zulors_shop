class OrderSetupModel {
  int? orderId;
  String? orderStatus;
  String? paymentStatus;
  int? deliveryManId;
  String? deliveryManCharge;
  String? expectedDeliveryDate;
  String? thirdPartyDeliveryServiceName;
  String? thirdPartyDeliveryServiceTrackingId;
  String? deliveryType;

  OrderSetupModel({
    this.orderId,
    this.orderStatus,
    this.paymentStatus,
    this.deliveryManId,
    this.deliveryManCharge,
    this.expectedDeliveryDate,
    this.thirdPartyDeliveryServiceName,
    this.thirdPartyDeliveryServiceTrackingId,
    this.deliveryType
  });

  factory OrderSetupModel.fromJson(Map<String, dynamic> json) {
    return OrderSetupModel(
      orderId: json['order_id'],
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      deliveryManId: json['delivery_man_id'],
      deliveryManCharge: json['deliveryman_charge'],
      expectedDeliveryDate: json['expected_delivery_date'],
      thirdPartyDeliveryServiceName: json['delivery_service_name'],
      thirdPartyDeliveryServiceTrackingId: json['third_party_delivery_tracking_id'],
      deliveryType: json['delivery_type']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_status': orderStatus,
      'payment_status': paymentStatus,
      'delivery_man_id': deliveryManId,
      'deliveryman_charge': deliveryManCharge,
      'expected_delivery_date': expectedDeliveryDate,
      'delivery_service_name': thirdPartyDeliveryServiceName,
      'third_party_delivery_tracking_id': thirdPartyDeliveryServiceTrackingId,
      "delivery_type": deliveryType
    };
  }


  void clear() {
    orderId = null;
    orderStatus = null;
    paymentStatus = null;
    deliveryManId = null;
    deliveryManCharge = null;
    expectedDeliveryDate = null;
    thirdPartyDeliveryServiceName = null;
    thirdPartyDeliveryServiceTrackingId = null;
    deliveryType = null;
  }
}


