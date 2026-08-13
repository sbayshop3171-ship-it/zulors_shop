import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/add_product_model.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/attribute_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/product_image_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/services/add_product_service_interface.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/ai_meta_seo_model.dart';
import 'package:zulors_shop_vendor/features/ai/domain/models/genara_setup_model.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/edt_product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/image_model.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/product_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';



class AddProductController extends ChangeNotifier {
  final AddProductServiceInterface shopServiceInterface;

  AddProductController({required this.shopServiceInterface});

  int _totalQuantity = 0;
  int get totalQuantity => _totalQuantity;
  String? _unitValue;
  String? get unitValue => _unitValue;
  int _discountTypeIndex = 0;
  int _taxTypeIndex = -1;
  String _imagePreviewSelectedType = 'large';
  int _unitIndex = 0;

  MetaSeoInfo? _metaSeoInfo = MetaSeoInfo();
  final TextEditingController maxSnippetController = TextEditingController();
  final TextEditingController maxImagePreviewController = TextEditingController();


  int get unitIndex => _unitIndex;
  bool _isLoading = false;
  bool get isLoading => _isLoading;


  EditProductModel? _editProduct;
  EditProductModel? get editProduct => _editProduct;
  int get discountTypeIndex => _discountTypeIndex;
  int get taxTypeIndex => _taxTypeIndex;
  String get imagePreviewSelectedType => _imagePreviewSelectedType;

  bool _isMultiply = false;
  bool get isMultiply => _isMultiply;

  final picker = ImagePicker();
  List<TextEditingController> _titleControllerList = [];
  List<TextEditingController> _descriptionControllerList = [];

  List<TextEditingController>  get titleControllerList=> _titleControllerList;
  List<TextEditingController> get descriptionControllerList=> _descriptionControllerList;
  final TextEditingController _productCode = TextEditingController();
  TextEditingController get productCode => _productCode;
  List<FocusNode>? _titleNode;
  List<FocusNode>? _descriptionNode;
  List<FocusNode>? get titleNode => _titleNode;
  List<FocusNode>? get descriptionNode => _descriptionNode;
  int _productTypeIndex = 0;
  int get productTypeIndex => _productTypeIndex;


  int _totalVariantQuantity = 0;
  int get totalVariantQuantity => _totalVariantQuantity;

  List<Map<String, dynamic>>? productReturnImage  = [];
  int _variationTotalQuantity = 0;
  int get variationTotalQuantity  => _variationTotalQuantity;
  final bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;
  int? _selectedPageIndex = 0;
  int? get selectedPageIndex => _selectedPageIndex;

  MetaSeoInfo? get metaSeoInfo => _metaSeoInfo;

  List<String> pages = ['general_info', 'variation_setup', 'product_seo'];
  List<String> imagePreviewType = ['large', 'medium', 'small'];

  void setTitle(int index, String title) {
    _titleControllerList[index].text = title;
  }
  
  void setDescription(int index, String description) {
    _descriptionControllerList[index].text = description;
  }
  
  void getTitleAndDescriptionList(List<Language> languageList, EditProductModel? edtProduct){
    _titleControllerList = [];
    _descriptionControllerList = [];
    for(int i= 0; i<languageList.length; i++){
      if(edtProduct != null){
        if(i==0){
          String plainProductDetails = ProductHelper.htmlToPlainText(edtProduct.details ?? '');
          _titleControllerList.insert(i,TextEditingController(text: edtProduct.name)) ;
          _descriptionControllerList.add(TextEditingController(text: plainProductDetails)) ;
        } else{
          for (var lan in edtProduct.translations!) {
            if(lan.locale == languageList[i].code && lan.key == 'name'){
              _titleControllerList.add(TextEditingController(text: lan.value)) ;
            }
            if(lan.locale == languageList[i].code && lan.key == 'description'){
              String plainText = ProductHelper.htmlToPlainText(lan.value ?? '');
              _descriptionControllerList.add(TextEditingController(text: plainText));

              debugPrint('--------description---------${lan.value}');

            }
          }
        }
      }
      else{
        _titleControllerList.add(TextEditingController());
        _descriptionControllerList.add(TextEditingController());
      }
    }
    if(edtProduct != null){
      if(_titleControllerList.length < languageList.length) {
        int l1 = languageList.length-_titleControllerList.length;
        for(int i=0; i<l1; i++) {
          _titleControllerList.add(TextEditingController(text: editProduct!.name));
          debugPrint('--------name---------${editProduct!.name}');
        }
      }
      if(_descriptionControllerList.length < languageList.length) {
        int l0 = languageList.length-_descriptionControllerList.length;
        for(int i=0; i<l0; i++) {
          _descriptionControllerList.add(TextEditingController(text: editProduct!.details));
          debugPrint('--------description---------${editProduct!.details}');
        }
      }
    }else {
      if(_titleControllerList.length < languageList.length) {
        int l = languageList.length-_titleControllerList.length;
        for(int i=0; i<l; i++) {
          _titleControllerList.add(TextEditingController());
        }
      }
      if(_descriptionControllerList.length < languageList.length) {
        int l2 = languageList.length-_descriptionControllerList.length;
        for(int i=0; i<l2; i++) {
          _descriptionControllerList.add(TextEditingController());
        }
      }
    }
  }


  void resetDiscountTypeIndex() {
    _discountTypeIndex = 0;
  }


  String discountType= 'percent';

  void setDiscountTypeIndex(int index, bool notify) {
    _discountTypeIndex = index;
    if(_discountTypeIndex == 0){
      discountType = 'percent';
    }else{
      discountType = 'flat';
    }
    if(notify) {
      notifyListeners();
    }
  }
  
  void setTaxTypeIndex(int index, bool notify) {
    _taxTypeIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  void setImagePreviewType(String type, bool notify) {
    _imagePreviewSelectedType = type;
    if(notify) {
      notifyListeners();
    }
  }

  void toggleMultiply(BuildContext context) {
    _isMultiply = !_isMultiply;
    notifyListeners();
  }

  ///Move to Add Product Directory
  Future<void> getEditProduct(BuildContext context,int? id) async {
    _editProduct = null;
    ApiResponse response = await shopServiceInterface.getEditProduct(id);
    if (response.response != null && response.response!.statusCode == 200) {
      _editProduct = EditProductModel.fromJson(response.response!.data);
      if(_editProduct?.seoInfo != null) {
        convertSeoInfoToMetaSeoInfo(_editProduct!.seoInfo!);
      }

      getTitleAndDescriptionList(Provider.of<SplashController>(Get.context!,listen: false).configModel!.languageList!, _editProduct);
      Provider.of<DigitalProductController>(Get.context!,listen: false).initDigitalProductVariation(_editProduct!);
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }

  void convertSeoInfoToMetaSeoInfo(SeoInfo seoInfo) {
    _metaSeoInfo = MetaSeoInfo(
      metaIndex: seoInfo.index,
      metaNoFollow: seoInfo.noFollow,
      metaNoImageIndex: seoInfo.noImageIndex,
      metaNoArchive: seoInfo.noArchive,
      metaNoSnippet: seoInfo.noSnippet,
      metaMaxSnippet: seoInfo.maxSnippet,
      metaMaxSnippetValue: seoInfo.maxSnippetValue,
      metaMaxVideoPreview: seoInfo.maxVideoPreview,
      metaMaxVideoPreviewValue: seoInfo.maxVideoPreviewValue,
      metaMaxImagePreview: seoInfo.maxImagePreview,
      metaMaxImagePreviewValue: seoInfo.maxImagePreviewValue,
      imageFullUrl: seoInfo.imageFullUrl
    );
  }



  void setUnitIndex(int index, bool notify) {
    _unitIndex = index;
    if(notify) {
      notifyListeners();
    }
  }


  int totalUploaded = 0;
  void initUpload(){
    totalUploaded = 0;
    notifyListeners();
  }





  Future<void> addProduct(BuildContext context, Product product, AddProductModel addProduct, String? thumbnail, String? metaImage, bool isAdd, List<String?> tags) async {
    _isLoading = true;
    notifyListeners();

    final addProductImageController = Provider.of<AddProductImageController>(context, listen: false);
    bool isDigitalVariationEmpty =  Provider.of<DigitalProductController>(context, listen: false).selectedDigitalVariation.isNotEmpty;

    DigitalVariationModel? digitalVariationModel;
    String? token;

    List<AttributeModel>? attributeList = Provider.of<VariationController>(context, listen: false).attributeList;

    Map<String, dynamic> variationFields = Provider.of<VariationController>(context, listen: false).processVariantData(context);

    Provider.of<VariationController>(context, listen: false).onClearColorVariations(addProduct);

    List<Map<String, dynamic>>? productReturnImages = addProductImageController.productReturnImageList;

    List<ColorImage> colorImageObjects = addProductImageController.colorImageObject;

    String? digitalProductFileName = Provider.of<DigitalProductController>(context, listen: false).digitalProductFileName;

    if(_productTypeIndex == 1) {
      digitalVariationModel = Provider.of<DigitalProductController>(context, listen: false).getDigitalVariationModel();
    } else {
      digitalVariationModel =  DigitalVariationModel();
    }

    token = Provider.of<AuthController>(context,listen: false).getUserToken();

    setMetaSeoData(product);



    ApiResponse response = await shopServiceInterface.addProduct(product, addProduct ,variationFields, productReturnImages, thumbnail, metaImage, isAdd, attributeList![0].active, colorImageObjects, tags, digitalProductFileName, digitalVariationModel, isDigitalVariationEmpty, token);
    if(response.response != null && response.response?.statusCode == 200) {

    await addProductImageController.onDeleteColorImages(product);

     _productCode.clear();
      Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
      showCustomSnackBarWidget(isAdd ? getTranslated('product_added_successfully', Get.context!): getTranslated('product_updated_successfully', Get.context!),Get.context!, isError: false);
       titleControllerList.clear();
      descriptionControllerList.clear();
      Provider.of<AddProductImageController>(Get.context!, listen: false).removeProductImage();
      emptyDigitalProductData();
      _isLoading = false;
      _metaSeoInfo = MetaSeoInfo();
     }else {
      Provider.of<AddProductImageController>(Get.context!,listen: false).emptyWithColorImage();
      _isLoading = false;
      ApiChecker.checkApi( response);
      showCustomSnackBarWidget(getTranslated('product_add_failed', Get.context!), Get.context!, sanckBarType: SnackBarType.error);
    }
    _isLoading = false;
    notifyListeners();
  }



  void setMetaSeoData(Product product) {
    metaSeoInfo?.metaMaxImagePreviewValue = _imagePreviewSelectedType;
    product.metaSeoInfo = metaSeoInfo;
  }

  void loadingFalse() {
    _isLoading = false;
    notifyListeners();
  }




  void setValueForUnit (String? setValue){
    if (kDebugMode) {
      debugPrint('------$setValue====$_unitValue');
    }
    _unitValue = setValue;
  }

  void setProductTypeIndex(int index, bool notify) {
    _productTypeIndex = index;
    if(notify) {
      notifyListeners();
    }
  }
  
  void setTotalVariantTotalQuantity(int total){
    _totalVariantQuantity = total;
  }

  Future<void> updateProductQuantity(BuildContext context, int? productId, int currentStock, List<Variation> variations) async {
    if(kDebugMode){
      debugPrint("variation======>${variations.length}/${variations.toList()}");
    }
    List<Variation> updatedVariations = [];
    for(int i=0; i<variations.length; i++){
      updatedVariations.add(Variation(type: variations[i].type,
          sku: variations[i].sku,
          price: variations[i].price,
          qty: int.parse( Provider.of<VariationController>(context, listen: false).variantTypeList[i].qtyController.text)
      ));
    }
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.updateProductQuantity(productId, currentStock, updatedVariations);
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


  Future<void> updateRestockProductQuantity(BuildContext context, int? productId, int currentStock, List<Variation> variations,{int? index}) async {
    if(kDebugMode){
      debugPrint("variation======>${variations.length}/${variations.toList()}");
    }
    List<Variation> updatedVariations = [];
    for(int i=0; i<variations.length; i++){
      updatedVariations.add(Variation(type: variations[i].type,
          sku: variations[i].sku,
          price: variations[i].price,
          qty: int.parse(Provider.of<VariationController>(context, listen: false).variantTypeList[i].qtyController.text)
      ));
    }
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.updateRestockProductQuantity(productId, currentStock, updatedVariations);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      Navigator.pop(Get.context!);
      showCustomSnackBarWidget(getTranslated('quantity_updated_successfully', Get.context!), Get.context!, isError: false);
      await Provider.of<RestockController>(Get.context!, listen: false).getRestockProductList(1);
      // Provider.of<RestockController>(Get.context!, listen: false).removeItem(index);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }



  List<String> imagesWithoutColor = [];
  List<String> imagesWithColorForUpdate = [];
  ProductImagesModel? productImagesModel;


  void  setSelectedPageIndex (int index, {bool isUpdate = true}){
    _selectedPageIndex = index;
    if(isUpdate) {
      notifyListeners();
    }
  }


  List<String> processList(List<String> inputList) {
    return inputList.map((str) => str.toLowerCase().trim()).toList();
  }



  void updateState(){
    notifyListeners();
  }


  void emptyDigitalProductData() {
    Provider.of<DigitalProductController>(Get.context!, listen: false).emptyDigitalProductData();
  }





  Future<void> generateAndSetOtherData({String? title, String? description, String? langCode}) async {
    AiController aiController = Provider.of<AiController>(Get.context!, listen: false);

    await aiController.generateGeneralSetup(
      title: title ?? '',
      description: description ?? '',
      langCode: langCode ?? '',
    ).then((value) {
      GeneralSetupModel? generalSetupModel = aiController.generalSetupModel;

      //Set brand
      if(generalSetupModel != null) {
        ProductController productController = Provider.of<ProductController>(Get.context!, listen: false);
        productController.setAiBrandIndex(generalSetupModel.data?.brandId ?? 0);
      }

      //Set category
      if(generalSetupModel != null) {
        CategoryController categoryController = Provider.of<CategoryController>(Get.context!, listen: false);
        categoryController.setAiCategoryIndex(generalSetupModel.data?.categoryId, generalSetupModel.data?.subCategoryId, generalSetupModel.data?.subSubCategoryId);
      }


      // print('---UnitValue---${generalSetupModel?.data?.unitName}--');

      //print('---UnitValue--01--${generalSetupModel != null && generalSetupModel.data?.unitName != null && generalSetupModel.data!.unitName!.isNotEmpty}--');

      if(generalSetupModel != null && generalSetupModel.data?.unitName != null && generalSetupModel.data!.unitName!.isNotEmpty ) {
        _unitValue = generalSetupModel.data?.unitName;
      }

      if(generalSetupModel != null && generalSetupModel.data?.productType != null) {
        _productTypeIndex = generalSetupModel.data?.productType == 'physical' ? 0 : 1;
      }

      if(generalSetupModel != null && generalSetupModel.data?.productType != null && generalSetupModel.data?.productType == 'digital' && generalSetupModel.data?.deliveryType != null) {
        Provider.of<DigitalProductController>(Get.context!, listen: false).setDigitalProductTypeIndex(
          generalSetupModel.data?.deliveryType == 'ready_product' ? 1 : 0, true
        );
      }


      notifyListeners();
    });
  }


  void updateMetaSeoInfo(AiMetaSEOModel? aiMetaSeoModel) {
    if(aiMetaSeoModel != null) {
      _metaSeoInfo?.metaIndex = aiMetaSeoModel.data?.metaIndex == '0' ? '0' : '1';
      _metaSeoInfo?.metaNoFollow = aiMetaSeoModel.data?.metaNoFollow == 0 ? '0' : 'nofollow';
      _metaSeoInfo?.metaNoIndex = aiMetaSeoModel.data?.metaNoImageIndex == 0 ? '0' : '1';
      _metaSeoInfo?.metaNoArchive = aiMetaSeoModel.data?.metaNoArchive == 0 ? '0' : '1';
      _metaSeoInfo?.metaNoSnippet = aiMetaSeoModel.data?.metaNoSnippet == 0 ? '0' : '1';
      _metaSeoInfo?.metaMaxSnippet = aiMetaSeoModel.data?.metaMaxSnippet == 0 ? '0' : '1';
      _metaSeoInfo?.metaMaxVideoPreview = aiMetaSeoModel.data?.metaMaxVideoPreview == 0 ? '0' : '1';
      _metaSeoInfo?.metaMaxImagePreview = aiMetaSeoModel.data?.metaMaxImagePreview == 0 ? '0' : '1';

      _metaSeoInfo?.metaMaxSnippetValue = aiMetaSeoModel.data?.metaMaxSnippetValue.toString();
      _metaSeoInfo?.metaMaxVideoPreviewValue = aiMetaSeoModel.data?.metaMaxVideoPreviewValue.toString();
      _metaSeoInfo?.metaMaxImagePreviewValue = aiMetaSeoModel.data?.metaMaxImagePreviewValue.toString();
      notifyListeners();
    }
  }


}
