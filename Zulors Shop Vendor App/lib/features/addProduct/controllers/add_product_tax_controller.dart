import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/services/add_product_service_interface.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';


class AddProductTaxController extends ChangeNotifier {
  final AddProductServiceInterface addProductServiceInterface;

  AddProductTaxController({required this.addProductServiceInterface});

  List<TaxVatModel>  _taxVatList = [];
  List<TaxVatModel> get taxVatList => _taxVatList;

  List<TaxVatModel>  _selectedTaxList = [];
  List<TaxVatModel> get selectedTaxList => _selectedTaxList;


  Future<void> getTaxVatList() async {
    _taxVatList = [];
    _selectedTaxList = [];
    ApiResponse response = await addProductServiceInterface.getTaxVatList();
    if (response.response != null && response.response!.statusCode == 200) {
      response.response?.data.forEach((vatTax) {
        _taxVatList.add(TaxVatModel.fromJson(vatTax));
      }
      );
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  void addToSelectedTaxList(TaxVatModel taxVatModel){
    _selectedTaxList.add(taxVatModel);
    notifyListeners();
  }

  void removeToSelectedTaxList(TaxVatModel taxVatModel, int index){
    _selectedTaxList.removeAt(index);
    notifyListeners();
  }

  bool isSelected (TaxVatModel taxVatModel) {
    for(TaxVatModel tvModel in _selectedTaxList){
      if(taxVatModel.id == tvModel.id) {
        return true;
      }
    }
    return false;
  }


  void setProductVatTax(List<TaxVats>? taxVats) {
    if(taxVats != null && taxVats.isNotEmpty) {
      for(TaxVats taxVat  in taxVats) {
        _selectedTaxList.add(taxVat.tax!);
      }
    }
  }


  void setAIProductVatTax(List<TaxVatModel>? taxVats) {
    if(taxVats != null && taxVats.isNotEmpty) {
      for(TaxVatModel taxVat  in taxVats) {
        if(!checkContains(taxVat)) {
          _selectedTaxList.add(taxVat);
        }
      }
    }
    notifyListeners();
  }

  bool checkContains(TaxVatModel? vatTRax) {
    if(_selectedTaxList.isNotEmpty && vatTRax != null){
      for(TaxVatModel tax in _selectedTaxList) {
        if(tax.id == vatTRax.id) {
          return true;
        }
      }
    }
    return false;
  }



}