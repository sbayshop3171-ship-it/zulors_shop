import 'package:flutter/cupertino.dart';

class WithdrawalMethodModel {
  List<Data>? data;
  int? totalSize;
  int? limit;
  int? offset;

  WithdrawalMethodModel({this.data, this.totalSize, this.limit, this.offset});

  WithdrawalMethodModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    return {
      if (data != null)
        'data': data!.map((v) => v.toJson()).toList(),
      'total_size': totalSize,
      'limit': limit,
      'offset': offset,
    };
  }
}

class Data {
  int? id;
  String? methodName;
  List<MethodFields>? methodFields;
  bool? isDefault;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.methodName,
        this.methodFields,
        this.isDefault,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    methodName = json['method_name'];
    if (json['method_fields'] != null) {
      methodFields = <MethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(MethodFields.fromJson(v));
      });
    }
    isDefault = json['is_default'];
    isActive = json['is_active'];
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

class MethodFields {
  String? inputType;
  String? inputName;
  String? placeholder;
  int? isRequired;
  TextEditingController? textEditingController;
  String? countryCode;
  DateTime? dateTime;

  MethodFields({
    this.inputType,
    this.inputName,
    this.placeholder,
    this.isRequired,
    this.textEditingController,
    this.countryCode,
    this.dateTime
  });

  MethodFields.fromJson(Map<String, dynamic> json) {
    inputType = json['input_type'];
    inputName = json['input_name'];
    placeholder = json['placeholder'];
    isRequired = json['is_required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['input_type'] = inputType;
    data['input_name'] = inputName;
    data['placeholder'] = placeholder;
    data['is_required'] = isRequired;
    return data;
  }
}



class WithdrawAddModel {
  int? withdrawMethodId;
  String? methodName;
  int? isActive;
  Map<String, dynamic>? methodInfo;
  int? id;

  WithdrawAddModel(
    {this.withdrawMethodId, this.methodName, this.isActive, this.methodInfo, this.id});

  WithdrawAddModel.fromJson(Map<String, dynamic> json) {
    withdrawMethodId = json['withdraw_method_id'];
    methodName = json['method_name'];
    isActive = json['is_active'];
    methodInfo = Map<String, dynamic>.from(json['method_info']);
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['withdraw_method_id'] = withdrawMethodId;
    data['method_name'] = methodName;
    data['is_active'] = isActive;
    data['method_info'] = methodInfo;
    data['id'] = id;
    return data;
  }
}

class MethodInfo {
  Map<String, dynamic> info;

  MethodInfo({
    required this.info,
  });

  factory MethodInfo.fromJson(Map<String, dynamic> json) => MethodInfo(
    info: Map.from(json),
  );

  Map<String, dynamic> toJson() => Map.from(info);
}

