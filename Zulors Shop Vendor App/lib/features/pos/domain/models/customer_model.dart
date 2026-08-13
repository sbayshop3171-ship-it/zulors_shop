class CustomerModel {
  List<Customers>? customers;

  CustomerModel({this.customers});

  CustomerModel.fromJson(Map<String, dynamic> json) {
    if (json['customers'] != null) {
      customers = <Customers>[];
      json['customers'].forEach((v) {
        customers!.add(Customers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (customers != null) {
      data['customers'] = customers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Customers {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? image;
  String? email;
  double? walletBalance;

  Customers(
      {this.id,
        this.fName,
        this.lName,
        this.phone,
        this.image,
        this.email,
        this.walletBalance
      });

  Customers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'] ?? '';
    lName = json['l_name'] ?? '';
    phone = json['phone'];
    image = json['image'];
    email = json['email'];
    if(json['wallet_balance'] != null) {
      walletBalance = double.tryParse(json['wallet_balance'].toString());
    } else {
      walletBalance = 0;
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
    return data;
  }
}
