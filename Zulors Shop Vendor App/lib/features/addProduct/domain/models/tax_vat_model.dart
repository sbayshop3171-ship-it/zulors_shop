class TaxVatModel {
  int? id;
  String? name;
  double? taxRate;

  TaxVatModel({this.id, this.name, this.taxRate});

  TaxVatModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    taxRate = double.tryParse(json['tax_rate'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['tax_rate'] = taxRate;
    return data;
  }
}