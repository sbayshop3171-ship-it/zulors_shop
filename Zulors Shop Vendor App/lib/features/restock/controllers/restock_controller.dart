import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/restock/domain/models/restock_brand_model.dart';
import 'package:zulors_shop_vendor/features/restock/domain/services/restock_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import '../domain/models/restock_product_model.dart';


class RestockController with ChangeNotifier {
  final RestockServiceInterface restockServiceInterface;
  RestockController({required this.restockServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _searchText;
  String? get searchText => _searchText;

  final bool _isDeleteLoading = false;
  bool get isDeleteLoading => _isDeleteLoading;

  RestockProductModel? restockProductModel;

  List<Brands>? brands;

  int _categoryIndex = 0;
  int get categoryIndex => _categoryIndex;

  int? _categoryId;
  int? get categoryId => _categoryId;


  String? _startDate;
  String? get startDate => _startDate;

  String? _endDate;
  String? get endDate => _endDate;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<TextEditingController> variationQuantityController = [];
  List<FocusNode> variationQuantityFocusnode = [];

  FocusNode? qtyNode;

  final TextEditingController _totalQuantityController = TextEditingController(text: '1');
  TextEditingController get totalQuantityController => _totalQuantityController;


  // Future<void> getRestockProductList(int offset, int? categoryId, String? searchText) async {
  //   if(offset ==1 && categoryId != null){
  //     restockProductModel = null;
  //     notifyListeners();
  //   }
  //   _isLoading = true;
  //   ApiResponse apiResponse = await restockServiceInterface.getRestockProductList(offset.toString(), categoryId, searchText);
  //
  //   if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
  //     _isLoading = false;
  //     if(offset == 1) {
  //       restockProductModel = RestockProductModel.fromJson(apiResponse.response?.data);
  //     } else {
  //       restockProductModel!.data!.addAll(RestockProductModel.fromJson(apiResponse.response?.data).data!);
  //       restockProductModel!.offset = RestockProductModel.fromJson(apiResponse.response?.data).offset;
  //       restockProductModel!.totalSize = RestockProductModel.fromJson(apiResponse.response?.data).totalSize;
  //     }
  //     print("====AAAA===>>${restockProductModel?.toJson()}");
  //   _isLoading = false;
  //   notifyListeners();
  // }}



  Future<void> getRestockBrandList() async {
    brands = null;
    brands = [];
    _isLoading = true;
    ApiResponse apiResponse = await restockServiceInterface.getRestockBrandList();

    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      _isLoading = false;

      brands = RestockBrand.fromJson(apiResponse.response?.data).brands;
    _isLoading = false;
    notifyListeners();
  }}


  Future<void> deleteRestockListItem(int id, int index) async {
    _isLoading = true;
    ApiResponse apiResponse = await restockServiceInterface.deleteRestockItem(id);

    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      restockProductModel!.data!.removeAt(index);
      restockProductModel!.totalSize = restockProductModel!.totalSize! -1;
      _isLoading = false;
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> getRestockProductList(int offset) async {
    if(offset ==1 && (categoryId != null || (searchText != null || searchText != ''))){
      restockProductModel = null;
     // notifyListeners();
    }

    List<int> selectedBrandIdsList =[];

    for(Brands brand in brands!){
      if(brand.checked!){
        selectedBrandIdsList.add(brand.id!);
      }
    }


    Map<dynamic, dynamic> data = {
      'brand_ids' : jsonEncode(selectedBrandIdsList),
      'category_id' : _categoryId,
      'search' : _searchText,
      'restock_start_date' : _startDate,
      'restock_end_date' : _endDate,
      'offset' : offset
    };


    _isLoading = true;
    ApiResponse apiResponse = await restockServiceInterface.getRestockProductList(data);

    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      if(offset == 1) {
        restockProductModel = RestockProductModel.fromJson(apiResponse.response?.data);
      } else {
        restockProductModel!.data!.addAll(RestockProductModel.fromJson(apiResponse.response?.data).data!);
        restockProductModel!.offset = RestockProductModel.fromJson(apiResponse.response?.data).offset;
        restockProductModel!.totalSize = RestockProductModel.fromJson(apiResponse.response?.data).totalSize;
      }
      _isLoading = false;
      notifyListeners();
    }}



  void removeItem(int? index){
    if(index!= null && restockProductModel != null && restockProductModel!.data!.isNotEmpty) {
      restockProductModel!.data!.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> deleteRestockProduct(String? id, String? type, int? index) async {
    _isLoading = true;
    ApiResponse apiResponse = await restockServiceInterface.deleteRestockProduct(type, id);

    if (apiResponse.response != null  && apiResponse.response!.statusCode == 200) {
      if(index != null){
        restockProductModel!.data!.removeAt(index);
        restockProductModel!.totalSize = (restockProductModel!.totalSize! - 1);
      } else if (type == 'all'){
        restockProductModel!.data = [];
        restockProductModel!.totalSize = 0;
      }
      _isLoading = false;
      notifyListeners();
    }}


  void emptyReStockData() {
    restockProductModel = null;
    notifyListeners();
  }


  void setIndex(int index, int? id, {bool notify = true}) {
    _categoryIndex = index;
    _categoryId = id;
    if(notify){
      notifyListeners();
    }
  }


  Future <void> selectDate(BuildContext context,String startDate, String endDate) async {
    _startDate = startDate;
    _endDate = endDate;

    notifyListeners();
  }


  void setSearching(bool value, {bool isUpdate = true}) {
    _isSearching = value;
    if(!value){
      _searchText = null;
    }
    if(isUpdate){
      notifyListeners();
    }
  }

  void setSearchText(String? value, {bool isUpdate = true}) {
    _searchText = value;
  }


  List<int> _selectedBrandIds = [];
  List<int> get selectedBrandIds => _selectedBrandIds;


  void checkedToggleBrand(int index){
    brands![index].checked = !brands![index].checked!;

    if(brands![index].checked ?? false) {
      if(!_selectedBrandIds.contains(index)) {
        _selectedBrandIds.add(index);
      }
    }else {
      _selectedBrandIds.remove(index);
    }
    notifyListeners();
  }

  Future<void> resetChecked() async{
    _startDate = null;
    _endDate = null;

    brands = brands?.map((brand) {
      brand.checked = false;
      return brand;
    }).toList();
    _selectedBrandIds = [];

    await getRestockProductList(1);
    notifyListeners();
  }

  void initVariationController(List<Variation> variations) {
    variationQuantityController = [];
    variationQuantityFocusnode = [];
    for(Variation v in variations) {
      variationQuantityController.add(TextEditingController(text: v.qty.toString()));
      variationQuantityFocusnode.add(FocusNode());
    }
  }


  Future<void> updateRestockProductQuantity(BuildContext context, int? productId, int currentStock, List<Variation> variations, {int? index}) async {
    if(kDebugMode){
      print("variation======>${variations.length}/${variations.toList()}");
    }
    List<Variation> updatedVariations = [];
    for(int i=0; i<variations.length; i++){
      updatedVariations.add(Variation(type: variations[i].type,
          sku: variations[i].sku,
          price: variations[i].price,
          qty: int.parse(variationQuantityController[i].text)
      ));
    }
    _isLoading = true;
    notifyListeners();


    ApiResponse apiResponse = await restockServiceInterface.updateRestockProductQuantity(productId, currentStock, updatedVariations);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      Navigator.pop(Get.context!);
      showCustomSnackBarWidget(getTranslated('quantity_updated_successfully', Get.context!), Get.context!, isError: false);
      await getRestockProductList(1);
      // Provider.of<RestockController>(Get.context!, listen: false).removeItem(index);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }



  Future<void> updateProductQuantity(BuildContext context, int? productId, int currentStock, List<Variation> variations) async {
    if(kDebugMode){
      print("variation======>${variations.length}/${variations.toList()}");
    }
    List<Variation> updatedVariations = [];
    for(int i=0; i<variations.length; i++){
      updatedVariations.add(Variation(type: variations[i].type,
          sku: variations[i].sku,
          price: variations[i].price,
          qty: int.parse(variationQuantityController[i].text)
      ));
    }
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await restockServiceInterface.updateProductQuantity(productId, currentStock, updatedVariations);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      Navigator.pop(Get.context!);
      showCustomSnackBarWidget(getTranslated('quantity_updated_successfully', Get.context!), Get.context!, isError: false);
      Provider.of<ProductController>(Get.context!, listen: false).getStockOutProductList(1, 'en');
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void calculateVariationQuantity(){
    int variationTotalQuantity = 0;
    if(variationQuantityController.isNotEmpty) {
      variationTotalQuantity = 0;
      for(int i=0; i<variationQuantityController.length; i++) {
        variationTotalQuantity = variationTotalQuantity + (int.tryParse(variationQuantityController[i].text) ?? 0);
      }
    }
    _totalQuantityController.text = variationTotalQuantity.toString();
    notifyListeners();
  }


  void setCurrentStock(String stock){
    _totalQuantityController.text = stock;
  }


}
