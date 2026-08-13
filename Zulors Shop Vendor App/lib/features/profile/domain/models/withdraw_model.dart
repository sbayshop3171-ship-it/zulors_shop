import 'package:zulors_shop_vendor/features/shop/domain/models/payment_information_model.dart';

class WithdrawModel {
  int? id;
  String? methodName;
  List<InfoMethodFields>? methodFields;
  bool? isDefault;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  WithdrawModel(
      {this.id,
        this.methodName,
        this.methodFields,
        this.isDefault,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  WithdrawModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    methodName = json['method_name'];
    if (json['method_fields'] != null) {
      methodFields = <InfoMethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(InfoMethodFields.fromJson(v));
      });
    }
    isDefault = json['is_default']??false;
    isActive = json['is_active'] ? 1 : 0;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['method_name'] = methodName;
    if (methodFields != null) {
      data['method_fields'] =
      methodFields!.map((v) => v.toJson()).toList();
    }
    data['is_default'] = isDefault;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}



class MethodModel {
  int? id;
  String? inputName;
  String? type;
  List<InfoMethodFields>? methodFields;
  bool? isDefault;
  Map<String, dynamic>? methodInfo;

  MethodModel({this.id, this.inputName, this.type, this.methodFields, this.methodInfo, this.isDefault});

  MethodModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    inputName = json['input_name'];
    type = json['type'];
    if (json['method_fields'] != null) {
      methodFields = <InfoMethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(InfoMethodFields.fromJson(v));
      });
    }
    methodInfo = json['method_info'] != null
      ? Map<String, dynamic>.from(json['method_info'])
      : null;
    isDefault = json['is_default'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['input_name'] = inputName;
    data['type'] = type;
    if (methodFields != null) {
      data['method_fields'] =
      methodFields!.map((v) => v.toJson()).toList();
    }
    if (methodInfo != null) {
      data['method_info'] = methodInfo;
    }
    data['is_default'] = isDefault;
    return data;
  }
}
