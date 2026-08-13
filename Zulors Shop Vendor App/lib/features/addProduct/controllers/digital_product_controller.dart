import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/add_product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/author_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/edt_product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/file_upload_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/services/add_product_service_interface.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/helper/product_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';

class DigitalProductController extends ChangeNotifier {
  final AddProductServiceInterface addProductServiceInterface;

  DigitalProductController({required this.addProductServiceInterface});

  int _digitalProductTypeIndex = 0;
  int get digitalProductTypeIndex => _digitalProductTypeIndex;

  List<AuthorModel> _authorsList = [];
  List<AuthorModel> _publishingHouseList = [];

  List<String> _selectedAuthors = [];
  List<String> _selectedPublishingHouse = [];

  List<String>? get selectedAuthors => _selectedAuthors;
  List<String>? get selectedPublishingHouse => _selectedPublishingHouse;

  List<AuthorModel>? get authorsList => _authorsList;
  List<AuthorModel>? get publishingHouseList => _publishingHouseList;

  List<String> _selectedDigitalVariation = [];
  List<List<String>> _digitalVariationExtension = [];
  List<List<FileUploadModel>> _variationFileList = [];
  List<TextEditingController> extentionControllerList = [];
  List<List<String>> editVariantKeys = [];
  List<List<bool>> _isDigitalVariationLoading = [];


  List<String> get selectedDigitalVariation => _selectedDigitalVariation;
  List<List<String>> get digitalVariationExtantion => _digitalVariationExtension;
  List<List<FileUploadModel>> get variationFileList => _variationFileList;
  List<List<bool>> get isDigitalVariationLoading => _isDigitalVariationLoading;

  File? selectedDigitalProductFile ;
  File? get selectedFileForImport =>selectedDigitalProductFile;

  String? _digitalProductFileName;
  String?  get digitalProductFileName =>_digitalProductFileName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  XFile ? _digitalProductPreview;
  XFile? get digitalProductPreview => _digitalProductPreview;

  bool _isPreviewLoading = false;
  bool get isPreviewLoading => _isPreviewLoading;

  bool isPreviewNull = true;


  void setDigitalProductTypeIndex(int index, bool notify) {
    _digitalProductTypeIndex = index;
    if(notify) {
      notifyListeners();
    }
  }

  Future<void> getDigitalAuthor() async {
    ApiResponse response = await addProductServiceInterface.getDigitalAuthor();
    if (response.response!.statusCode == 200) {
      _authorsList = [];
      response.response!.data.forEach((brand) => _authorsList.add(AuthorModel.fromJson(brand)));
      debugPrint("===AuthorList===>>${_authorsList.length}");
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }


  Future<void> getPublishingHouse() async {
    ApiResponse response = await addProductServiceInterface.getPublishingHouse();
    if (response.response?.statusCode == 200) {
      _publishingHouseList = [];
      response.response!.data.forEach((brand) => _publishingHouseList.add(AuthorModel.fromJson(brand)));
    } else {
      ApiChecker.checkApi(response);
    }
    notifyListeners();
  }


  void addAuthor(String authorName) {
    if(!_selectedAuthors.contains(authorName)) {
      _selectedAuthors.add(authorName);
    }
    notifyListeners();
  }

  void removeAuthor(int index) {
    _selectedAuthors.removeAt(index);
    notifyListeners();
  }

  void addPublishingHouse(String publishingHouse) {
    if(!_selectedPublishingHouse.contains(publishingHouse)) {
      _selectedPublishingHouse.add(publishingHouse);
    }
    notifyListeners();
  }

  void removePublishingHouse(int index) {
    _selectedPublishingHouse.removeAt(index);
    notifyListeners();
  }



  void setAuthorPublishingData(Product product) {
    _selectedPublishingHouse = [];
    _selectedAuthors = [];

    if(product.publishingHouse != null){
      _selectedPublishingHouse.addAll(product.publishingHouse! as Iterable<String>);
    }

    if(product.authors != null){
      _selectedAuthors.addAll(product.authors! as Iterable<String>);
    }
  }


  void emptyDigitalProductData() {
    selectedDigitalProductFile = null;
    _digitalProductFileName = '';
    _selectedDigitalVariation = [];
    _digitalVariationExtension = [];
    _variationFileList = [];
    extentionControllerList = [];
    editVariantKeys = [];
    _isDigitalVariationLoading = [];
    _digitalProductPreview = null;
    _selectedPublishingHouse = [];
    _selectedAuthors = [];
  }



  void initDigitalProductVariation(EditProductModel editProduct) {
    _selectedDigitalVariation = [];
    _digitalVariationExtension = [];
    extentionControllerList = [];
    editVariantKeys = [];
    _variationFileList = [];
    _isDigitalVariationLoading = [];

    if(editProduct.digitalProductFileTypes != null) {
      for(int i=0; i< editProduct.digitalProductFileTypes!.length; i++) {
        _digitalVariationExtension.add([]);
        extentionControllerList.add(TextEditingController());
        editVariantKeys.add([]);
        _variationFileList.add([]);
        _isDigitalVariationLoading.add([]);
        _selectedDigitalVariation.add(ProductHelper.capitalizeFirstLetter(editProduct.digitalProductFileTypes![i]));
      }
    }

    if(editProduct.digitalProductExtensions != null){
      editProduct.digitalProductExtensions!.forEach((key, value) {
        for(int i=0; i<_selectedDigitalVariation.length; i++){
          if(key.toLowerCase() == _selectedDigitalVariation[i].toLowerCase()){
            _digitalVariationExtension[i].addAll(value);
          }
        }
      });
    }


    for (int i=0; i<_selectedDigitalVariation.length; i++) {
      for(int index = 0; index < _digitalVariationExtension[i].length; index++) {
        String ext = ProductHelper.removeSpacesAndLowercase(_digitalVariationExtension[i][index]);
        editVariantKeys[i].add('${_selectedDigitalVariation[i].toLowerCase()}-$ext');
      }
    }

    for (int i=0; i<_selectedDigitalVariation.length; i++) {
      for(int index = 0; index < editVariantKeys[i].length; index++) {
        for(int j=0; j < editProduct.digitalVariation!.length;  j++) {
          if(editVariantKeys[i][index] == editProduct.digitalVariation![j].variantKey){
            _variationFileList[i].add(
              FileUploadModel(
                priceController: TextEditingController(text: editProduct.digitalVariation![j].price.toString()),
                skuController: TextEditingController(text: editProduct.digitalVariation![j].sku.toString()),
                file: null,
                fileName: editProduct.digitalVariation![j].file?.toString(),
              ),
            );
            _isDigitalVariationLoading[i].add(false);
          }
        }
      }
    }
  }


  DigitalVariationModel  getDigitalVariationModel() {
    DigitalVariationModel  digitalvariationModel = DigitalVariationModel();
    digitalvariationModel.variationType = [];
    digitalvariationModel.digitalVariantKey = [];
    digitalvariationModel.digitalVariantFiles = {};
    digitalvariationModel.digitalVariantSku = {};
    digitalvariationModel.digitalVariantPrice = {};
    digitalvariationModel.digitalVariantKeyMap = {};
    digitalvariationModel.variationKeys = [];
    digitalvariationModel.authors = [];
    digitalvariationModel.publishingHouse = [];

    digitalvariationModel.variationType = ProductHelper.processList(_selectedDigitalVariation);

    digitalvariationModel.variationKeys?.addAll(_digitalVariationExtension);

    for (int i=0; i<digitalvariationModel.variationType!.length; i++) {
      for(int index = 0; index < _digitalVariationExtension[i].length; index++) {
        String ext = ProductHelper.removeSpacesAndLowercase(_digitalVariationExtension[i][index]);
        digitalvariationModel.digitalVariantKey?.add('${digitalvariationModel.variationType![i]}_$ext');
      }
    }


    int count = -1;
    for (int i=0; i<digitalvariationModel.variationType!.length; i++) {
      for(int index = 0; index < _variationFileList[i].length; index++) {
        count++;
        String key = digitalvariationModel.digitalVariantKey![count];
        digitalvariationModel.digitalVariantFiles?.addAll(
            <String,dynamic>{
              key : _variationFileList[i][index].file
            }
        );
        if(i==1 && index ==0){
          debugPrint("=======>>${digitalvariationModel.digitalVariantFiles}");
        }

        digitalvariationModel.digitalVariantSku?.addAll(
            <String,dynamic>{
              key : _variationFileList[i][index].skuController!.text
            }
        );

        digitalvariationModel.digitalVariantPrice?.addAll(
            <String,dynamic>{
              key : _variationFileList[i][index].priceController!.text
            }
        );

        digitalvariationModel.digitalVariantKeyMap?.addAll(
            <String,dynamic>{
              key : ProductHelper.replaceUnderscoreWithHyphen(key),
            }
        );
      }
    }

    digitalvariationModel.digitalProductPreview = _digitalProductPreview;
    digitalvariationModel.authors!.addAll(_selectedAuthors);
    digitalvariationModel.publishingHouse!.addAll(_selectedPublishingHouse);

    return digitalvariationModel;
  }

  Future<void> deleteDigitalVariationFile(int productId, int index, int subIndex) async {
    _isDigitalVariationLoading[index][subIndex] = true;
    notifyListeners();

    String vKey = editVariantKeys[index][subIndex];

    ApiResponse apiResponse = await addProductServiceInterface.deleteDigitalVariationFile(productId, vKey);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _variationFileList[index][subIndex].fileName = null;
      _isLoading = false;
      showCustomSnackBarWidget(getTranslated('digital_product_deleted_successfully', Get.context!), Get.context!, sanckBarType: SnackBarType.success);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }

    _isDigitalVariationLoading[index][subIndex] = false;
    notifyListeners();
  }

  void addDigitalProductVariation(String value) {
    _selectedDigitalVariation.add(value);
    _digitalVariationExtension.add([]);
    _variationFileList.add([]);
    extentionControllerList.add(TextEditingController());
    _isDigitalVariationLoading.add([]);
    notifyListeners();
  }

  void removeDigitalVariant(BuildContext context, int index) {
    _selectedDigitalVariation.removeAt(index);
    _digitalVariationExtension.removeAt(index);
    _variationFileList.removeAt(index);
    extentionControllerList.removeAt(index);
    _isDigitalVariationLoading.removeAt(index);
    notifyListeners();
  }


  void addExtension(int index, String text){
    _digitalVariationExtension[index].add(text);
    extentionControllerList[index].text = '';
    _variationFileList[index].add(
        FileUploadModel(
          priceController: TextEditingController(),
          skuController: TextEditingController(text: ProductHelper.generateSKU()),
          file: null,
        )
    );
    _isDigitalVariationLoading[index].add(false);
    notifyListeners();
  }


  void removeExtension(int index, int subIndex){
    _digitalVariationExtension[index].removeAt(subIndex);
    _variationFileList[index].removeAt(subIndex);
    _isDigitalVariationLoading[index].removeAt(subIndex);
    notifyListeners();
  }


  void pickFileForDigitalProduct (int index, int subIndex) async{

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withReadStream: true,
      withData: true,
      allowedExtensions: ['pdf', 'zip', 'jpg', 'png', "jpeg", "gif",  "mp4", "avi", "mov", "mkv", "webm", "mpeg", "mpg", "3gp", "m4v", "mp3", "wav", "aac", "wma", "amr"],
    );

    if(result != null) {
      Uint8List? imageBytes = result.files.first.bytes;
      File? file = await File(result.files.first.path!).writeAsBytes(imageBytes!);

      XFile xFile =  XFile(file.path);

      double fileSizeInMB = await ImageSize.getImageSizeFromXFile(xFile);

      ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

      if(fileSizeInMB >  (configModel?.systemImageFileUploadMaxSize ??  AppConstants.fileImageMaxLimit)) {
        showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ??  AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
      } else {
        _variationFileList[index][subIndex].file = xFile;
        PlatformFile? fileNamed = result.files.first;
        _variationFileList[index][subIndex].fileName = fileNamed.name;
      }
    }

    notifyListeners();
  }

  void removeFileForDigitalProduct (int index, int subIndex) async{
    _variationFileList[index][subIndex].file = null;
    _variationFileList[index][subIndex].fileName = null;
    notifyListeners();
  }

  bool shouldShowUploadFile() {
    for (int index = 0; index < _selectedDigitalVariation.length; index++) {
      if (_digitalVariationExtension[index].isNotEmpty) {
        return true;
      }
    }
    return false;
  }


  void pickFileDigitalProductPreview () async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withReadStream: true,
      withData: true,
      allowedExtensions: ['pdf', 'zip', 'jpg', 'png', "jpeg", "gif",  "mp4", "avi", "mov", "mkv", "webm", "mpeg", "mpg", "3gp", "m4v", "mp3", "wav", "aac", "wma", "amr"],
    );

    if(result != null) {
      Uint8List? imageBytes = result.files.first.bytes;
      File? file = await File(result.files.first.path!).writeAsBytes(imageBytes!);

      XFile xFile =  XFile(file.path);
      double value =  await ImageSize.getImageSizeFromXFile(xFile);
      ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

      if(value > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
        showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
      } else {
        _digitalProductPreview = xFile;
      }
    }
    notifyListeners();
  }


  Future<void>  deleteDigitalPreviewFile(int? id) async {

    if(_digitalProductPreview != null) {
      _digitalProductPreview = null;
    }else if (id != null) {
      _isPreviewLoading = true;
      notifyListeners();
      ApiResponse apiResponse = await addProductServiceInterface.deleteProductPreview(id);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        isPreviewNull = true;
        _isPreviewLoading = false;
      } else {
        _isPreviewLoading = false;
        ApiChecker.checkApi(apiResponse);
      }
    }
    notifyListeners();
  }

  void setPreviewData(bool isNull) {
    isPreviewNull = isNull;
  }


  void setSelectedFileName(File? fileName){
    selectedDigitalProductFile = fileName;
    if (kDebugMode) {
      debugPrint('Here is your file ===>$selectedDigitalProductFile');
    }
    notifyListeners();
  }

  Future<ApiResponse> uploadDigitalProduct(String token) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await addProductServiceInterface.uploadDigitalProduct(selectedDigitalProductFile, token);

    if(response.response!.statusCode == 200) {
      if (kDebugMode) {
        debugPrint('digital product uploaded');
      }
      _isLoading = false;
      Map map = jsonDecode(response.response!.data);
      _digitalProductFileName = map["digital_file_ready_name"];
      if (kDebugMode) {
        debugPrint('-----digital product uploaded---->$_digitalProductFileName');
      }

    }else {
      _isLoading = false;
    }
    _isLoading = false;
    notifyListeners();
    return response;
  }





}