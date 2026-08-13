import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/customer_model.dart';
import 'package:zulors_shop_vendor/features/pos/domain/services/cart_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/main.dart';


class CustomerController extends ChangeNotifier{
  final CartServiceInterface cartServiceInterface;
  CustomerController({required this.cartServiceInterface});

  List<Customers>? _searchedCustomerList;
  List<Customers>? get searchedCustomerList =>_searchedCustomerList;

  int? _customerId = 0;
  int? get customerId => _customerId;

  String? _customerSelectedName = '';
  String? get customerSelectedName => _customerSelectedName;

  String? _customerSelectedMobile = '';
  String? get customerSelectedMobile => _customerSelectedMobile;




  Future<void> getCustomerList(String type) async {
    _searchedCustomerList = null;
    ApiResponse response = await cartServiceInterface.getCustomerList(type);
    if(response.response!.statusCode == 200) {
      _searchedCustomerList = [];
      _searchedCustomerList!.addAll(CustomerModel.fromJson(response.response!.data).customers!);
    }else {
      ApiChecker.checkApi( response);
    }
    notifyListeners();
  }

  void setCustomerInfo(int? id, String? name, String? phone,  bool notify, double? customerBalance ,{bool formCart = false, fromInit = false}) {
    _customerId = id;
    _customerSelectedName = name;
    _customerSelectedMobile  = phone;

    Provider.of<CartController>(Get.context!, listen: false).setCurrentCartCustomerInfo(id, name, phone, customerBalance, notify);
    if(notify) {
      notifyListeners();
    }
  }


  void resetCustomerInfo(int? id, String? name, String? phone,  bool notify) {
    setCustomerInfo(0,  'Walk-In Customer', '', true, 0);
  }


  bool  checkWalletAmount (int? customerId, double orderAmount) {
    bool hasAmount = false;

    _searchedCustomerList?.forEach((customer) {
      if(customer.id == customerId && customer.walletBalance != null && customer.walletBalance! >= orderAmount) {
        hasAmount = true;
      }
    });

    return hasAmount;
  }


  Future<void> searchCustomer(BuildContext context,String searchName) async {
    _searchedCustomerList = [];

    ApiResponse response = await cartServiceInterface.customerSearch(searchName);
    if(response.response!.statusCode == 200) {
      _searchedCustomerList = [];
      _searchedCustomerList!.addAll(CustomerModel.fromJson(response.response!.data).customers!);
    }else {
      ApiChecker.checkApi( response);
    }
    notifyListeners();
  }



  void resetCustomerId({bool isUpdate = false}) {
    _customerId = 0;
    if(isUpdate){
      notifyListeners();
    }
  }

}