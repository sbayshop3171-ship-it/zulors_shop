

class NotificationBody {
  int? orderId;
  int? orderDetailsId;
  int? refundId;
  String? type;
  String? messageKey;


  NotificationBody({
    this.orderId,
    this.orderDetailsId,
    this.refundId,
    this.type,
    this.messageKey,
  });

  NotificationBody.fromJson(Map<String, dynamic> json) {
    if(json['order_id'] != null && json['order_id'] != ''){
      orderId = int.tryParse(json['order_id'].toString());
    }
    if(json['order_details_id'] != null && json['order_details_id'] != ''){
      orderDetailsId = int.tryParse(json['order_details_id'].toString());
    }
    type = json['type'];
    messageKey = json['message_key'];
    if(json['refund_id'] != null && json['refund_id'] != ''){
      refundId = int.tryParse(json['refund_id'].toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_details_id'] = orderDetailsId;
    data['refund_id'] = refundId;
    data['type'] = type;
    data['message_key'] = messageKey;
    return data;
  }


}