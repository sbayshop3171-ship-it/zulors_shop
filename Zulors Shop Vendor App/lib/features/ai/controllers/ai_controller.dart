import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/ai_meta_seo_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/ai_variation_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/genara_setup_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/image_response_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/pricing_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/title_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/title_suggestion_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/services/ai_service_interface.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/product_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import '../../../main.dart';

class AiController extends ChangeNotifier {
  final AiServiceInterface aiServiceInterface;
  AiController({required this.aiServiceInterface});


  bool _titleLoading = false;
  bool get titleLoading => _titleLoading;

  bool _descLoading = false;
  bool get descLoading => _descLoading;

  bool _generalSetupLoading = false;
  bool get generalSetupLoading => _generalSetupLoading;

  TitleModel? _titleModel;
  TitleModel? get titleModel => _titleModel;

  TitleModel? _descriptionModel;
  TitleModel? get description => _descriptionModel;

  GeneralSetupModel? _generalSetupModel;
  GeneralSetupModel? get generalSetupModel => _generalSetupModel;

  List<String?> _keyWordList = [];
  List<String?> get keyWordList => _keyWordList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _pricingLoading = false;
  bool get pricingLoading => _pricingLoading;

  bool _variationLoading = false;
  bool get variationLoading => _variationLoading;

  bool _metaSeoLoading = false;
  bool get metaSeoLoading => _metaSeoLoading;

  bool _imageLoading = false;
  bool get imageLoading => _imageLoading;

  XFile? _pickedLogo;
  XFile? get pickedLogo => _pickedLogo;

  ImageResponseModel? _imageResponseModel;
  ImageResponseModel? get imageResponseModel => _imageResponseModel;

  PricingModel? _pricingModel;
  PricingModel? get pricingModel => _pricingModel;

  TitleSuggestionModel? _titleSuggestionModel;
  TitleSuggestionModel? get titleSuggestionModel => _titleSuggestionModel;

  AiVariationModel? _aiVariationModel;
  AiVariationModel? get aiVariationModel => _aiVariationModel;

  AiMetaSEOModel? _metaSeoInfo;
  AiMetaSEOModel? get metaSeoInfo => _metaSeoInfo;

  bool _requestTypeImage = false;
  bool get requestTypeImage => _requestTypeImage;

  bool _addProductSetupLoading = false;
  bool get addProductSetupLoading => _addProductSetupLoading;

  bool _addProductNextScreenLoading = false;
  bool get addProductNextScreenLoading => _addProductNextScreenLoading;

  bool _addProductMetaScreenLoading = false;
  bool get addProductMetaScreenLoading => _addProductMetaScreenLoading;

  int genLimit = 0;


  Future<void> generateTitle({required String title, required String langCode}) async {
    _titleLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await aiServiceInterface.generateTitle(title: title, langCode: langCode);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _titleModel = TitleModel.fromJson(apiResponse.response?.data);
    } else {
      _titleModel = null;
      ApiChecker.checkApi(apiResponse);
    }
    generateLimitCheck();


    _titleLoading = false;
    notifyListeners();
  }


  Future<void> generateDescription ({required String title, required String langCode}) async {
    _descLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await aiServiceInterface.generateDescription(title: title, langCode: langCode);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _descriptionModel = TitleModel.fromJson(apiResponse.response?.data);
      String plain = ProductHelper.htmlToPlainText(_descriptionModel?.data ?? '');
      if(plain.isNotEmpty) {
        _descriptionModel?.data = plain;
      }
    } else {
      _descriptionModel = null;
      ApiChecker.checkApi(apiResponse);
    }
    generateLimitCheck();

    _descLoading = false;
    notifyListeners();
  }




  Future<void> generateGeneralSetup({required String title, required String description, required String langCode}) async {
    _generalSetupLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await aiServiceInterface.generateGeneralData(title: title, langCode: langCode, description: description);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _generalSetupModel = GeneralSetupModel.fromJson(apiResponse.response?.data);
    } else {
      _generalSetupModel = null;
      ApiChecker.checkApi(apiResponse);
    }
    generateLimitCheck();

    _generalSetupLoading =  false;
    notifyListeners();
  }


  Future<void> generatePricing ({
    required String title,
    required String langCode,
    required TextEditingController uniPriceController,
    required TextEditingController discountController,
    required TextEditingController stockQuantityController,
    required TextEditingController minQuantityController,
    required TextEditingController shippingCostController,
  }) async {
    _pricingLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await aiServiceInterface.generatePricing(title: title, langCode: langCode);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _pricingModel = PricingModel.fromJson(apiResponse.response?.data);
    } else {
      _pricingModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    if(_pricingModel != null) {
      if(_pricingModel?.data?.unitPrice != null) {
        uniPriceController.text = _pricingModel?.data?.unitPrice.toString() ?? '0';
      }
      if(_pricingModel?.data?.discountAmount != null) {
        discountController.text = _pricingModel?.data?.discountAmount.toString() ?? '0';
      }
      if(_pricingModel?.data?.currentStock != null) {
        stockQuantityController.text = _pricingModel?.data?.currentStock.toString() ?? '0';
      }
      if(_pricingModel?.data?.minimumOrderQuantity != null) {
        minQuantityController.text = _pricingModel?.data?.minimumOrderQuantity.toString() ?? '0';
      }

      if(_pricingModel?.data?.shippingCost != null) {
        shippingCostController.text = _pricingModel?.data?.shippingCost.toString() ?? '0';
      }
    }

    if(_pricingModel?.data?.vatTax != null && _pricingModel!.data!.vatTax!.isNotEmpty) {
      Provider.of<AddProductTaxController>(Get.context!,listen: false).setAIProductVatTax(_pricingModel?.data?.vatTax);
    }

    if(_pricingModel?.data?.discountType != null) {
      Provider.of<AddProductController>(Get.context!,listen: false).setDiscountTypeIndex(_pricingModel?.data?.discountType == 'percent' ? 0 : 1, true);
    }

    if(_pricingModel?.data?.isShippingCostMultil != null) {
      if((_pricingModel?.data?.isShippingCostMultil == 0 ? false : true) !=  Provider.of<AddProductController>(Get.context!,listen: false).isMultiply) {
        Provider.of<AddProductController>(Get.context!,listen: false).toggleMultiply(Get.context!);
      }
    }
    generateLimitCheck();

    _pricingLoading = false;
    notifyListeners();
  }


  Future<void> generateVariationSetup({required String title, required String description, Product? product}) async {
    _variationLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await aiServiceInterface.generateVariationData(title: title, description: description);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _aiVariationModel = AiVariationModel.fromJson(apiResponse.response?.data);
    } else {
      _aiVariationModel = null;
      ApiChecker.checkApi(apiResponse);
    }

    if(apiResponse.response?.statusCode == 200) {
      VariationController variationController = Provider.of<VariationController>(Get.context!, listen: false);

      variationController.addAiColorVariation(_aiVariationModel?.data?.colorsActive, _aiVariationModel?.data?.colors ?? [], product);

      variationController.addAiAttribute(_aiVariationModel?.data?.choiceAttributes, product, _aiVariationModel?.data?.genereateVariation);
    }
    generateLimitCheck();

    _variationLoading = false;
    notifyListeners();
  }


  Future<void> generateMetaSeoSetup({
    required String title,
    required String description,
    required TextEditingController seoTitleController,
    required TextEditingController seoDescriptionController,
    bool formInit = false
  }) async {
    _metaSeoLoading = true;
    if(formInit) {
      _addProductMetaScreenLoading = true;
    }
    notifyListeners();

    ApiResponse apiResponse = await aiServiceInterface.generateMetaSeoData(title: title, description: description);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _metaSeoInfo = AiMetaSEOModel.fromJson(apiResponse.response?.data);
    } else {
      _metaSeoInfo = null;
      ApiChecker.checkApi(apiResponse);
    }

    if(_metaSeoInfo != null) {
      if(_metaSeoInfo?.data?.metaTitle != null && _metaSeoInfo!.data!.metaTitle!.isNotEmpty) {
        seoTitleController.text = _metaSeoInfo?.data?.metaTitle ?? '';
      }
      if(_metaSeoInfo?.data?.metaDescription  != null && _metaSeoInfo!.data!.metaDescription!.isNotEmpty) {
        seoDescriptionController.text = _metaSeoInfo?.data?.metaDescription ?? '';
      }
      Provider.of<AddProductController>(Get.context!,listen: false).updateMetaSeoInfo(_metaSeoInfo);
    }
    generateLimitCheck();

    _metaSeoLoading = false;

    if(formInit) {
      _addProductMetaScreenLoading = false;
    }
    notifyListeners();
  }


  void setKeyWord(String? name, {bool willUpdate = true}) {
    _keyWordList.add(name);
    if(willUpdate) {
      notifyListeners();
    }
  }

  void removeKeyWord(int index){
    _keyWordList.removeAt(index);
    notifyListeners();
  }


  Future<void> generateTitleSuggestions() async {
    _isLoading = true;
    notifyListeners();

    String keyWord = '';
    for (var element in _keyWordList) {
      keyWord = keyWord + (keyWord.isEmpty ? '' : ',') + element!.replaceAll(' ', '');
    }

    ApiResponse apiResponse = await aiServiceInterface.generateTitleSuggestions(keywords: keyWord);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _titleSuggestionModel = TitleSuggestionModel.fromJson(apiResponse.response?.data);
    } else {
      Navigator.of(Get.context!).pop();
      Navigator.of(Get.context!).pop();
      _titleSuggestionModel = null;
      ApiChecker.checkApi(apiResponse);
    }
    generateLimitCheck();

    _isLoading = false;
    notifyListeners();
  }

  void initializeKeyWords(){
    _keyWordList = [];
  }



  void pickImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
    }else {
      // jpeg,png,jpg,gif
      _pickedLogo = await ImagePicker().pickImage(source: ImageSource.gallery, );
      notifyListeners();
    }
  }


  Future<ApiResponse> generateFromImage({required XFile image}) async {
    _imageLoading = true;
    notifyListeners();

    XFile compressedImage = await compressImageFile(imageFile: File(image.path), quality: 10);

    ApiResponse apiResponse = await aiServiceInterface.generateFromImage(image: compressedImage);

    generateLimitCheck();
    _imageLoading = false;
    notifyListeners();

    return apiResponse;
  }


  Future<ApiResponse> generateLimitCheck() async {
    ApiResponse apiResponse = await aiServiceInterface.generateLimitCheck();

    if(apiResponse.response?.statusCode == 200) {
      if(apiResponse.response?.data['message'] == 'Success') {
        genLimit = apiResponse.response?.data['data'];
      }
    }

    notifyListeners();
    return apiResponse;
  }


  Future<XFile> compressImageFile({required File imageFile, int quality = 80, CompressFormat format = CompressFormat.jpeg}) async {

    DateTime time = DateTime.now();
    final String targetPath = path.join(Directory.systemTemp.path, 'imagetemp-${format.name}-$quality-${time.second}.${format.name}');

    final XFile? compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: quality,
      format: format,
      minHeight: 800, minWidth: 800,
    );

    if (compressedImageFile == null){
      throw ("Image compression failed! Please try again.");
    }
    debugPrint("Compressed image saved to: ${compressedImageFile.path}");
    return compressedImageFile;
  }

  void setRequestType(bool type, {bool willUpdate = true}){
    _requestTypeImage = type;
    if(willUpdate) {
      notifyListeners();
    }
  }

  void removeImage() {
    _pickedLogo = null;
  }


  Future<ImageResponseModel?>? generateAndSetDataFromImage({required XFile image, List<Language>? languageList, TabController? tabController, List<TextEditingController>? nameControllerList  }) async {
    ApiResponse response = await generateFromImage(image: image);
    ImageResponseModel? imageResponseModel;

    if(response.response?.statusCode == 200) {
      imageResponseModel = ImageResponseModel.fromJson(response.response?.data);

      if(imageResponseModel.data != null) {
        nameControllerList![tabController?.index ?? 0].text = imageResponseModel.data ?? '';
        _requestTypeImage = true;
      }
    }  else {
      Navigator.of(Get.context!).pop();
      Navigator.of(Get.context!).pop();
      await Future.delayed(Duration(milliseconds: 500));
      ApiChecker.checkApi(response);
      if(response.response?.statusCode == 403) {
        showCustomSnackBarWidget(response.response?.data['message'], Get.context!, sanckBarType: SnackBarType.error);
      }
    }

    notifyListeners();

    return imageResponseModel;
  }


  void generateAddProductPageSetup(String title, TabController? tabController, List<Language>? languageList, List<TextEditingController>? descriptionControllerList) async {
    _addProductSetupLoading = true;
    notifyListeners();
    


    await generateDescription(
      title: title ,
      langCode: languageList?[tabController?.index ?? 0].code ?? ''
    ).then((_) {
      if(_descriptionModel?.data != null && _descriptionModel!.data!.isNotEmpty) {
        descriptionControllerList![tabController?.index ?? 0].text =  _descriptionModel?.data ?? '';
        notifyListeners();
      }
    });

    await Provider.of<AddProductController>(Get.context!,listen: false).generateAndSetOtherData(
      title: title,
      description: descriptionControllerList![tabController?.index ?? 0].text,
      langCode: languageList?[tabController?.index ?? 0].code ?? '',
    );

    showCustomSnackBarWidget(getTranslated('tap_next_to_automatically_generate', Get.context!), Get.context!, sanckBarType: SnackBarType.warning);

    _addProductSetupLoading = false;
    notifyListeners();
  }



  void generateAddProductNextSerenSetup(String title, TabController? tabController, List<Language>? languageList, List<TextEditingController>? descriptionControllerList) async {
    _addProductNextScreenLoading = true;
    notifyListeners();



    _addProductNextScreenLoading = false;
    notifyListeners();
  }



  void setNextProductNextScreen (bool value, {bool isUpdate = true}) {
    _addProductNextScreenLoading = value;

    if(isUpdate) {
      notifyListeners();
    }
  }




}

