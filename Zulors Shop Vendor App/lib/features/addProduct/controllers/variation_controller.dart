import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/add_product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/attr.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/attribute_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/variant_type_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/services/add_product_service_interface.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/ai_variation_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/main.dart';

class VariationController extends ChangeNotifier {
  final AddProductServiceInterface addProductServiceInterface;

  VariationController({required this.addProductServiceInterface});

  List<AttributeModel>? _attributeList = [];
  List<AttributeModel>? get attributeList => _attributeList;

  List<int> _selectedColor = [];
  List<int> get selectedColor =>_selectedColor;

  List<VariantTypeModel> _variantTypeList =[];
  List<VariantTypeModel> get variantTypeList => _variantTypeList;

  int _totalVariationQuantity = 0;
  int get totalVariationQuantity  => _totalVariationQuantity;

  final TextEditingController _totalQuantityController = TextEditingController(text: '1');
  TextEditingController get totalQuantityController => _totalQuantityController;

  List<String?> _colorCodeList =[];
  List<String?> get colorCodeList => _colorCodeList;


  Future<void> getAttributeList(BuildContext context, Product? product, String language) async {
    _attributeList = null;
    _totalVariationQuantity = 0;
    _selectedColor = [];
    _variantTypeList = [];

    Provider.of<AddProductImageController>(Get.context!, listen: false).removeProductImage();
    Provider.of<AddProductController>(context,listen: false).resetDiscountTypeIndex();

    ApiResponse response = await addProductServiceInterface.getAttributeList(language);

    if (response.response != null || response.response!.statusCode != 200) {

      _attributeList = _initializeAttributeList();

      Provider.of<AddProductImageController>(Get.context!, listen: false).emptyWithColorImage();

      for (var attribute in response.response!.data) {
        _addAttribute(attribute, product);
      }

    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  List<AttributeModel> _initializeAttributeList() {
    return [
      AttributeModel(
        attribute: Attr(id: 0, name: 'Color'),
        active: false,
        controller: TextEditingController(),
        variants: [],
      )
    ];
  }

  void _addAttribute(dynamic attribute, Product? product) {
    Attr attr = Attr.fromJson(attribute);
    bool active = product?.attributes?.contains(attr.id) ?? false;

    List<String> options = [];
    if (active && product?.choiceOptions != null && product!.choiceOptions!.isNotEmpty) {
      int index = product.attributes!.indexOf(attr.id);
      options = product.choiceOptions![index].options ?? [];
    }

    _attributeList!.add(AttributeModel(
      attribute: attr,
      active: active,
      controller: TextEditingController(),
      variants: options,
    ));

    if (kDebugMode) {
      debugPrint('--------${attr.id}/$active/${product?.attributes}');
    }
  }




  void calculateVariationQuantity() {
    if(_variantTypeList.isNotEmpty) {
      _totalVariationQuantity = 0;
      for(int i=0; i<_variantTypeList.length; i++) {
        _totalVariationQuantity = _totalVariationQuantity + int.parse(_variantTypeList[i].qtyController.text);
      }
    }
    _totalQuantityController.text = _totalVariationQuantity.toString();
    notifyListeners();
  }

  void setAttribute() {
    _attributeList![0].active = true;
  }

  void setCurrentStock(String stock){
    _totalQuantityController.text = stock;
  }

  void toggleAttribute(BuildContext context,int index, Product? product) {
    _attributeList![index].active = !_attributeList![index].active;
    generateVariantTypes(context,product);
    notifyListeners();
  }

  void addVariant(BuildContext context, int index, String? variant, Product? product, bool notify, {List<GenereateVariation>? genereateVariation}) {
    _attributeList![index].variants.add(variant);
    generateVariantTypes(context,product, genereateVariation: genereateVariation);
    if(notify) {
      notifyListeners();
    }
  }

  void removeVariant(BuildContext context,int mainIndex, int index, Product? product) {
    _attributeList![mainIndex].variants.removeAt(index);
    generateVariantTypes(context, product, genereateVariation:  Provider.of<AiController>(context, listen: false).aiVariationModel?.data?.genereateVariation);
    notifyListeners();
  }

  bool hasAttribute() {
    bool hasData = false;
    for(AttributeModel attribute in _attributeList!) {
      if(attribute.active) {
        hasData = true;
        break;
      }
    }
    return hasData;
  }




  void generateVariantTypes(BuildContext context, Product? product, {List<GenereateVariation>? genereateVariation}) {
    List<List<String?>> mainList = [];
    int length = 1;
    bool hasData = false;
    List<int> indexList = [];
    _variantTypeList = [];

    for (var attribute in _attributeList!) {
      if(attribute.active) {
        hasData = true;
        mainList.add(attribute.variants);
        length = length * attribute.variants.length;
        indexList.add(0);
      }
    }
    if(!hasData) {
      length = 0;
    }
    for(int i=0; i<length; i++) {
      String value = '';
      for(int j=0; j<mainList.length; j++) {
        value = value + (value.isEmpty ? '' : '-') + mainList[j][indexList[j]]!.trim();
      }
      if(product != null && genereateVariation == null) {
        double? price = 0;
        int? quantity = 0;
        for(Variation variation in product.variation!) {
          if(variation.type == value) {
            price = variation.price;
            quantity = variation.qty;
            break;
          }
        }
        _variantTypeList.add(VariantTypeModel(
          variantType: value, controller: TextEditingController(text: price! > 0 ? PriceConverter.convertPriceWithoutSymbol(context,price) : ''), node: FocusNode(),
          qtyController: TextEditingController(text: quantity.toString()), qtyNode: FocusNode(),
        ));
        // _variationTotalQuantity
      }else {
        if (genereateVariation != null) {
          for(GenereateVariation gVariation in genereateVariation) {
            if(value == gVariation.option) {
              _variantTypeList.add(VariantTypeModel(variantType: value, controller: TextEditingController(text: gVariation.price.toString()), node: FocusNode(),qtyController: TextEditingController(text: gVariation.stock.toString()),qtyNode: FocusNode()));
            }
          }
        } else {
          _variantTypeList.add(VariantTypeModel(variantType: value, controller: TextEditingController(), node: FocusNode(),qtyController: TextEditingController(),qtyNode: FocusNode()));
        }
      }

      for(int j=0; j<mainList.length; j++) {
        if(indexList[indexList.length-(1+j)] < mainList[mainList.length-(1+j)].length-1) {
          indexList[indexList.length-(1+j)] = indexList[indexList.length-(1+j)] + 1;
          break;
        }else {
          indexList[indexList.length-(1+j)] = 0;
        }
      }
    }
    // if(_variantTypeList.isNotEmpty){
    //   for(int i=0; i<_variantTypeList.length; i++){
    //     int qty = int.tryParse(_variantTypeList[i].qtyController.text) ?? 0;
    //     _variationTotalQuantity = _variationTotalQuantity + qty;
    //   }
    // }
    debugPrint('-----------gen----${_variantTypeList.length}');
    // debugPrint("====TotalVariationCount=====>${_variationTotalQuantity}");
  }


  void addColorCode(String? colorCode, {int? index}){
    if(index == 0){
      _colorCodeList = [];
      Provider.of<AddProductImageController>(Get.context!, listen: false).emptyWithColorImage();
    }
    _colorCodeList.add(colorCode);
    Provider.of<AddProductImageController>(Get.context!, listen: false).addWithColorImage(colorCode, isUpdate: true);
    notifyListeners();
  }

  void removeColorCode(int index){
    _colorCodeList.removeAt(index);
    Provider.of<AddProductImageController>(Get.context!, listen: false).removeWithColorImage(index);
    notifyListeners();
  }

  void initColorCode(){
    _colorCodeList = [];
    Provider.of<AddProductImageController>(Get.context!,listen: false).emptyWithColorImage();
  }



  Map<String, dynamic> processVariantData (BuildContext context) {
    Map<String, dynamic> fields = {};
    int totalQuantity = 0;

    if (_variantTypeList.isNotEmpty) {
      List<int?> idList = [];
      List<String?> nameList = [];

      // Process attribute list
      for (var attributeModel in _attributeList!) {
        if (attributeModel.active) {
          if (attributeModel.attribute.id != 0) {
            idList.add(attributeModel.attribute.id);
            nameList.add(attributeModel.attribute.name);
          }

          // Collect variant strings
          List<String?> variantString = [];
          for (var variant in attributeModel.variants) {
            variantString.add(variant);
          }

          // Add variant strings to fields
          fields.addAll(<String, dynamic>{
            'choice_options_${attributeModel.attribute.id}': variantString
          });
        }
      }

      // Add choice attributes, choice numbers, and choice names to fields
      fields.addAll(<String, dynamic>{
        'choice_attributes': jsonEncode(idList),
        'choice_no': jsonEncode(idList),
        'choice': jsonEncode(nameList),
      });

      // Process variant type list
      for (int index = 0; index < _variantTypeList.length; index++) {
        fields.addAll(<String, dynamic>{
          'price_${_variantTypeList[index].variantType}': PriceConverter
              .systemCurrencyToDefaultCurrency(
              double.parse(_variantTypeList[index].controller.text), context),
        });
        fields.addAll(<String, dynamic>{
          'qty_${_variantTypeList[index].variantType}':
          int.parse(_variantTypeList[index].qtyController.text),
        });
        fields.addAll(<String, dynamic>{
          'sku_${_variantTypeList[index].variantType}':
          "sku_${_variantTypeList[index].variantType}",
        });

        // Update total quantity
        totalQuantity += int.parse(_variantTypeList[index].qtyController.text);
      }

      // Debug print total quantity
      if (kDebugMode) {
        debugPrint('=====Total_Quantity======>$totalQuantity');
      }
    }

    return fields;
  }

void onClearColorVariations(AddProductModel addProduct) {

  if(_attributeList?.isNotEmpty ?? false) {
    if(!(_attributeList?.first.active ?? false)) {
      addProduct.colorCodeList = [];
    }
  }
}



  void addAiAttribute(List<ChoiceAttributes>? choiceAttribute, Product? product, List<GenereateVariation>? genereateVariation) {
    for(ChoiceAttributes attribute in choiceAttribute ?? []) {
      for(int i = 0; i< _attributeList!.length; i++) {
        if(attribute.id == _attributeList?[i].attribute.id) {
          if(!_attributeList![i].active) {
            _attributeList![i].active = true;
          }

          if(product != null) {
            generateVariantTypes(Get.context!, product);
          }

          for(String option in attribute.values ?? []) {
            if(!checkExistVariant(_attributeList![i].variants,  option)) {
              addVariant(Get.context!, i, option, product, true, genereateVariation: genereateVariation);
            }
          }


        }
      }
    }
    notifyListeners();
  }


  void addAiColorVariation(int? isColorActive, List<AiColors> aiColors, Product? product) {
    if((isColorActive == 0 ? false : true) != _attributeList![0].active) {
      toggleAttribute(Get.context!, 0, product);
    }

    for(AiColors aiColor in aiColors) {
      if(!checkExistVariant(_attributeList![0].variants, aiColor.name!)) {
        addVariant(Get.context!, 0, aiColor.name, product, true);
        addColorCode(aiColor.code);
      }
    }
    notifyListeners();
  }

  bool checkExistVariant(List<String?> variants, String value) {
    for(int index = 0; index< (variants.length); index++) {
      if(variants[index] == value) {
        return true;
      }
    }
    return false;
  }

}