class PaymentInformationModel {
  List<PaymentInfoData>? data;
  int? totalSize;
  int? limit;
  int? offset;

  PaymentInformationModel({this.data, this.totalSize, this.limit, this.offset});

  PaymentInformationModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <PaymentInfoData>[];
      json['data'].forEach((v) {
        data!.add(PaymentInfoData.fromJson(v));
      });
    }
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    return data;
  }
}

class PaymentInfoData {
  int? id;
  String? userId;
  int? withdrawMethodId;
  String? methodName;
  Map<String, dynamic>? methodInfo;
  bool? isActive;
  bool? isDefault;
  String? createdAt;
  String? updatedAt;
  WithdrawMethod? withdrawMethod;

  PaymentInfoData(
      {this.id,
        this.userId,
        this.withdrawMethodId,
        this.methodName,
        this.methodInfo,
        this.isActive,
        this.isDefault,
        this.createdAt,
        this.updatedAt,
        this.withdrawMethod});

  PaymentInfoData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    withdrawMethodId = json['withdraw_method_id'];
    methodName = json['method_name'];
    methodInfo = json['method_info'] != null
      ? Map<String, dynamic>.from(json['method_info'])
      : null;
    isActive = json['is_active'];
    isDefault = json['is_default'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    withdrawMethod = json['withdraw_method'] != null
      ? WithdrawMethod.fromJson(json['withdraw_method'])
      : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['withdraw_method_id'] = withdrawMethodId;
    data['method_name'] = methodName;
    if (methodInfo != null) {
      data['method_info'] = methodInfo;
    }
    data['is_active'] = isActive;
    data['is_default'] = isDefault;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (withdrawMethod != null) {
      data['withdraw_method'] = withdrawMethod!.toJson();
    }
    return data;
  }
}

class WithdrawMethod {
  int? id;
  String? methodName;
  List<InfoMethodFields>? methodFields;
  bool? isDefault;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  WithdrawMethod(
      {this.id,
        this.methodName,
        this.methodFields,
        this.isDefault,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  WithdrawMethod.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    methodName = json['method_name'];
    if (json['method_fields'] != null) {
      methodFields = <InfoMethodFields>[];
      json['method_fields'].forEach((v) {
        methodFields!.add(InfoMethodFields.fromJson(v));
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

class InfoMethodFields {
  String? inputType;
  String? inputName;
  String? placeholder;
  int? isRequired;

  InfoMethodFields(
    {this.inputType, this.inputName, this.placeholder, this.isRequired});

  InfoMethodFields.fromJson(Map<String, dynamic> json) {
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


class MethodInfo {
  String? date;
  String? name;
  String? roll;
  String? email;
  String? password;

  MethodInfo({this.date, this.name, this.roll, this.email, this.password});

  MethodInfo.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    name = json['name'];
    roll = json['roll'];
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['name'] = name;
    data['roll'] = roll;
    data['email'] = email;
    data['password'] = password;
    return data;
  }
}