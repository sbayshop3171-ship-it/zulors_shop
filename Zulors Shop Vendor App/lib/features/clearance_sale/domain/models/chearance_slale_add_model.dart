import 'package:flutter/material.dart';


class ClearanceSaleAddModel{

  int? id;
  String? type;
  double? amount;
  bool? isWrongAmount;
  TextEditingController amountController;

  ClearanceSaleAddModel({this.id, this.type, this.amount, this.isWrongAmount, required this.amountController});

}