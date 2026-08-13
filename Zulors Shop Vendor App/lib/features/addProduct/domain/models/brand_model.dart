class BrandModel {
  int? _id;
  String? _name;
  String? _image;


  bool? _checked;

  BrandModel({int? id, String? name, String? image, bool checked = false}) {
    _id = id;
    _name = name;
    _image = image;


    _checked = checked;

  }

  int? get id => _id;
  String? get name => _name;
  String? get image => _image;


  bool? get checked => _checked;
  void toggleChecked(){
    _checked = !_checked!;
  }

  BrandModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _image = json['image'];


    _checked = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['name'] = _name;
    data['image'] = _image;
    return data;
  }
}
