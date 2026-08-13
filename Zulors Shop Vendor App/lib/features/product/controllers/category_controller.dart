import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/category_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/services/category_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/main.dart';

class CategoryController extends ChangeNotifier {
  final CategoryServiceInterface categoryServiceInterface;
  CategoryController({required this.categoryServiceInterface});


  List<int?> _categoryIds = [];
  List<int?> _subCategoryIds = [];
  List<int?> _subSubCategoryIds = [];
  List<int?> get categoryIds => _categoryIds;
  List<int?> get subCategoryIds => _subCategoryIds;
  List<int?> get subSubCategoryIds => _subSubCategoryIds;

  int? _categoryIndex = 0;
  int? get categoryIndex => _categoryIndex;

  List<bool?> _selectedCategory = [];
  List<bool?> get selectedCategory => _selectedCategory;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? get categoryList => _categoryList;

  int? _subCategoryIndex = 0;
  int? get subCategoryIndex => _subCategoryIndex;

  List<SubCategory>? _subCategoryList;
  List<SubCategory>? get subCategoryList => _subCategoryList;

  int? _subSubCategoryIndex = 0;
  int? get subSubCategoryIndex => _subSubCategoryIndex;

  List<SubSubCategory>? _subSubCategoryList;
  List<SubSubCategory>? get subSubCategoryList => _subSubCategoryList;

  int? _categorySelectedIndex;
  int? _subCategorySelectedIndex;
  int? _subSubCategorySelectedIndex;

  int? get categorySelectedIndex => _categorySelectedIndex;
  int? get subCategorySelectedIndex => _subCategorySelectedIndex;
  int? get subSubCategorySelectedIndex => _subSubCategorySelectedIndex;





  ///Move to Product List
  Future<void> getCategoryList(BuildContext context, Product? product, String language) async {
    log("====category call==> ");
    _categoryIds =[];
    _subCategoryIds =[];
    _subSubCategoryIds =[];
    _categoryIds.add(0);
    _subCategoryIds.add(0);
    _subSubCategoryIds.add(0);
    _categoryIndex = 0;

    _selectedCategory = [];
    // if(_categoryList != null && _categoryList!.isNotEmpty){
    //   notifyListeners();
    // }
    ApiResponse response = await categoryServiceInterface.getCategoryList(language);
    if (response.response != null && response.response!.statusCode == 200) {
      _categoryList = [];
      response.response!.data.forEach((category) => _categoryList!.add(CategoryModel.fromJson(category)));
      _categoryIndex = 0;

      for(int index = 0; index < _categoryList!.length; index++) {
        _categoryIds.add(_categoryList![index].id);
        _selectedCategory.add(false);
      }

      if(product != null && product.categoryIds != null &&product.categoryIds!.isNotEmpty){
        setCategoryIndex(_categoryIds.indexOf(int.parse(product.categoryIds![0].id!)), false);
        getSubCategoryList(Get.context!,_categoryIds.indexOf(int.parse(product.categoryIds![0].id!)), false, product);
        if (_subCategoryList != null && _subCategoryList!.isNotEmpty) {
          for (int index = 0; index < _subCategoryList!.length; index++) {
            _subCategoryIds.add(_subCategoryList![index].id);
          }

          if(product.categoryIds!.length>1){
            setSubCategoryIndex(_subCategoryIds.indexOf(int.parse(product.categoryIds![1].id!)), false);
            getSubSubCategoryList(_subCategoryIds.indexOf(int.parse(product.categoryIds![1].id!)), false);
          }
        }

        if (_subSubCategoryList != null) {
          for (int index = 0; index < _subSubCategoryList!.length; index++) {
            _subSubCategoryIds.add(_subSubCategoryList![index].id);
          }
          if(product.categoryIds!.length>2){
            setSubSubCategoryIndex(_subSubCategoryIds.indexOf(int.parse(product.categoryIds![2].id!)), false);
            setSubSubCategoryIndex(_subSubCategoryIds.indexOf(int.parse(product.categoryIds![2].id!)), false);
          }
        }
      }
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  Future<void> getSubCategoryList(BuildContext context, int? selectedIndex, bool notify, Product? product) async {
    _subCategoryIndex = 0;
    if(categoryIndex != 0) {
      _subCategoryList = [];
      _subCategoryList!.addAll(_categoryList![categoryIndex!-1].subCategories!);
    }
    if(notify){
      _subCategoryIds = [];
      _subCategoryIds.add(0);
      _subCategoryIndex = 0;
      _subSubCategoryIds = [];
      _subSubCategoryIds.add(0);
      _subSubCategoryIndex = 0;
      for (var element in _subCategoryList!) {
        _subCategoryIds.add(element.id);
      }
      notifyListeners();
    }
  }

  Future<void> getSubSubCategoryList(int? selectedIndex, bool notify) async {
    _subSubCategoryIndex = 0;
    if(_subCategoryIndex != 0) {
      _subSubCategoryList = [];
      _subSubCategoryList!.addAll(subCategoryList![_subCategoryIndex!-1].subSubCategories!);
    }
    if(notify){
      _subSubCategoryIds = [];
      _subSubCategoryIds.add(0);
      _subSubCategoryIndex = 0;
      if(_subSubCategoryList!.isNotEmpty){
        for (var element in _subSubCategoryList!) {
          _subSubCategoryIds.add(element.id);
        }
      }
      notifyListeners();
    }
  }


  void setCategoryIndex(int? index, bool notify) {
    _categoryIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  void setSubCategoryIndex(int? index, bool notify) {
    _subCategoryIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  void setSubSubCategoryIndex(int? index, bool notify) {
    _subSubCategoryIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  void setSelectedCategoryForFilter(int index, bool? selected){
    _selectedCategory[index] = selected;
    notifyListeners();
  }

  void emptyCategoryList() {
    _selectedCategory = [];
    _categoryList = [];
  }

  void resetCategory () {
    _categoryIndex = 0;
    _subCategoryIndex = 0;
    _subSubCategoryIndex = 0;
  }

  void removeCategory(){
    _categoryList = null;
    _subCategoryList = null;
    _subSubCategoryList = null;
  }

  void toggleCategoryChecked(int index, {bool isUpdate = true}){
    categoryList![index].toggleChecked();

    if(isUpdate) {
      notifyListeners();
    }
  }


  void setAiCategoryIndex(int? categoryId, int? subCategoryId, int? subSubCategoryId) {

    if(_categoryIds.isNotEmpty && categoryId != null) {
      for(int i =0; i< _categoryIds.length; i++) {
        if(_categoryIds[i] == categoryId) {
          setCategoryIndex(i, true);
          getSubCategoryList(Get.context!, _categorySelectedIndex , true, null);
        }
      }
    }

    if(_subCategoryIds.isNotEmpty && subCategoryId != null) {
      for(int i =0; i< _subCategoryIds.length; i++) {
        if(_subCategoryIds[i] == subCategoryId) {
          setSubCategoryIndex(i, true);
          getSubSubCategoryList(_subCategorySelectedIndex, true);
        }
      }
    }

    if(_subSubCategoryIds.isNotEmpty) {
      for(int i =0; i< _subSubCategoryIds.length; i++) {
        if(_subSubCategoryIds[i] == subSubCategoryId) {
          setSubSubCategoryIndex(i, true);
        }
      }
    }
  }









}
