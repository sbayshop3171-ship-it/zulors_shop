class AiVariationModel {
  bool? success;
  String? message;
  Data? data;

  AiVariationModel({this.success, this.message, this.data});

  AiVariationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? colorsActive;
  List<AiColors>? colors;
  List<ChoiceAttributes>? choiceAttributes;
  List<GenereateVariation>? genereateVariation;

  Data({this.colorsActive, this.colors, this.choiceAttributes,  this.genereateVariation});

  Data.fromJson(Map<String, dynamic> json) {
    colorsActive = json['colors_active'];
    if (json['colors'] != null) {
      colors = <AiColors>[];
      json['colors'].forEach((v) {
        colors!.add(AiColors.fromJson(v));
      });
    }
    if (json['choice_attributes'] != null) {
      choiceAttributes = <ChoiceAttributes>[];
      json['choice_attributes'].forEach((v) {
        choiceAttributes!.add(ChoiceAttributes.fromJson(v));
      });
    }
    if (json['genereate_variation'] != null) {
      genereateVariation = <GenereateVariation>[];
      json['genereate_variation'].forEach((v) {
        genereateVariation!.add(GenereateVariation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['colors_active'] = colorsActive;
    if (colors != null) {
      data['colors'] = colors!.map((v) => v.toJson()).toList();
    }
    if (choiceAttributes != null) {
      data['choice_attributes'] =
          choiceAttributes!.map((v) => v.toJson()).toList();
    }
    if (genereateVariation != null) {
      data['genereate_variation'] =
          genereateVariation!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AiColors {
  String? name;
  String? code;

  AiColors({this.name, this.code});

  AiColors.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}

class ChoiceAttributes {
  int? id;
  String? name;
  List<String>? values;

  ChoiceAttributes({this.id, this.values});

  ChoiceAttributes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    values = json['options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['options'] = values;
    return data;
  }
}


class GenereateVariation {
  String? option;
  String? sku;
  double? price;
  int? stock;

  GenereateVariation({this.option, this.sku, this.price, this.stock});

  GenereateVariation.fromJson(Map<String, dynamic> json) {
    option = json['option'];
    sku = json['sku'];
    price = double.tryParse(json['price'].toString());
    stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['option'] = option;
    data['sku'] = sku;
    data['price'] = price;
    data['stock'] = stock;
    return data;
  }
}