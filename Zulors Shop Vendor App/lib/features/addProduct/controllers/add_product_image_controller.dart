import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/image_full_url.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/image_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/product_image_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/services/add_product_service_interface.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';


class AddProductImageController extends ChangeNotifier {
  final AddProductServiceInterface shopServiceInterface;

  AddProductImageController({required this.shopServiceInterface});

  XFile? _selectedLogoFile;
  XFile? _selectedCoverFile;
  XFile? _selectedMetaImageFile;
  XFile? _selectedCoveredImageFile;
  List <XFile>_productImage = [];
  bool _isMultiply = false;
  bool get isMultiply => _isMultiply;
  XFile? get selectedLogoFile => _selectedLogoFile;
  XFile? get selectedCoverFile => _selectedCoverFile;
  XFile? get selectedMetaImageFile => _selectedMetaImageFile;
  XFile? get selectedCoveredImageFile => _selectedCoveredImageFile;
  List<XFile> get productImage => _productImage;



  late ImageModel thumbnailImageModel;
  late ImageModel metaImageModel;
  List<ImageModel> imagesWithColor = [];
  List<ColorImage> previousColorImage = [];
  List<ImageModel> withoutColor = [];
  List<String> imageKeysWithColor = [];
  List<String> imageKeysWithoutColor = [];
  List<ColorImage> colorImageObject = [];
  int totalSelectedImages = 0;


  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>>? productReturnImageList  = [];
  List<String> imagesWithColorForUpdate = [];


  void pickImage(bool isLogo,bool isMeta, bool isRemove, int? index, {bool update = false, bool isAddProduct = false}) async {
    if(isRemove) {
      totalSelectedImages--;
      _selectedLogoFile = null;
      _selectedCoverFile = null;
      _selectedMetaImageFile = null;
      _selectedCoveredImageFile = null;
      _productImage = [];
      imagesWithColor =[];
      withoutColor =[];
    }else {
      ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

      totalSelectedImages ++;
      if (isLogo) {
        _selectedLogoFile = await ImagePicker().pickImage(source: ImageSource.gallery);

        if(_selectedLogoFile != null) {
          double fileSizeInMB = await ImageSize.getImageSizeFromXFile(_selectedLogoFile!);

          if(fileSizeInMB > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
            _selectedLogoFile = null;
            showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
          } else {
            thumbnailImageModel = ImageModel(type: 'thumbnail', color: '', image: _selectedLogoFile);
            if(isAddProduct){
              metaImageModel = ImageModel(type: 'meta', color: '', image: _selectedLogoFile);
              _selectedMetaImageFile = selectedLogoFile;
            }
          }
        }
      } else if(isMeta){
        _selectedMetaImageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

        double fileSizeInMB = await ImageSize.getImageSizeFromXFile(_selectedMetaImageFile!);

        if(fileSizeInMB > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit) && _selectedMetaImageFile != null) {
          showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
          _selectedMetaImageFile = null;
        }else {
          metaImageModel = ImageModel(type: 'meta', color: '', image: _selectedMetaImageFile);
        }
      }else {
        _selectedCoveredImageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

        double fileSizeInMB = await ImageSize.getImageSizeFromXFile(_selectedCoveredImageFile!);

        if(fileSizeInMB > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
          showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
        } else if (_selectedCoveredImageFile != null && index != null) {
          if(update) {
            totalSelectedImages --;
          }
          imagesWithColor[index].image =  _selectedCoveredImageFile;
          imagesWithColor[index].type =  'product';
        }else if(_selectedCoveredImageFile != null) {
          withoutColor.add(ImageModel(image: _selectedCoveredImageFile, type: 'product',color: ''));
        }
      }
    }
    notifyListeners();
  }



  Future addProductImage(BuildContext context, ImageModel imageForUpload, Function callback, {bool update =false, int? index, int? productId}) async {

    bool isColorVariationActive = Provider.of<VariationController>(context, listen: false).attributeList![0].active;

    _isLoading = true;
    notifyListeners();

    ApiResponse response = await shopServiceInterface.addImage(context, imageForUpload, isColorVariationActive);


    if(response.response != null && response.response!.statusCode == 200) {
      totalUploaded ++;
      _isLoading = false;
      Map map = jsonDecode(response.response!.data);


      String? name = map["image_name"];
      String? type = map["type"];
      if(type == 'product'){
        if(map["image_name"] != null && map["image_name"] != "null"){
          productReturnImageList?.add({
            "image_name" : name,
            "storage" : map['storage'] ?? "public",
          });
        }

        if(isColorVariationActive){

          if(update && map["color_image"]['color'] != null && index != null && (index < imagesWithColorForUpdate.length )){


            String? previousColor = map["color_image"]['color'];

            int imageIndex = colorImageObject.indexWhere((v) => v.color == previousColor);

            if(imageIndex != -1) {
              colorImageObject[imageIndex] = ColorImage(
                color: previousColor,
                imageName: ImageFullUrl(key: name),
                storage: map['storage'],
              );
            }else {
              int i = imagesWithColor.indexWhere((v) => v.color == previousColor);
              ///if previous color remove form previous screen and add new that time it will return -1
              if(i == -1) {
                colorImageObject.add(ColorImage(
                  color: previousColor,
                  imageName: ImageFullUrl(key: name),
                  storage: map['storage'],
                ));
              }
            }

          }else{
            colorImageObject.add(ColorImage(color:  map['color_image'] != null ? map['color_image']['color'] : null, imageName: ImageFullUrl(key: name), storage: map['storage']));
          }
        }
      }

      callback(true, name, type, map['color_image'] != null ? map['color_image']['color'] : null);
      notifyListeners();
    }else {
      _isLoading = false;
      ApiChecker.
      checkApi( response);
      showCustomSnackBarWidget(getTranslated('image_upload_failed', Get.context!), Get.context!);
    }
    notifyListeners();
  }



  int totalUploaded = 0;
  void initUpload(){
    totalUploaded = 0;
    notifyListeners();
  }

  void removeImage(int index,bool fromColor){
    if(fromColor){
      if (kDebugMode) {
        debugPrint('==$index/${imagesWithColor[index].image}/${imagesWithColor[index].color}');
      }
      imagesWithColor[index].image = null;
    }else{
      withoutColor.removeAt(index);
    }
    notifyListeners();
  }


  List<String> imagesWithoutColor = [];
  ProductImagesModel? productImagesModel;

  Future<void> getProductImage(String id, {bool isStorePreviousImage = false}) async {
    imagesWithoutColor = [];
    productReturnImageList = [];
    colorImageObject = [];
    imagesWithColorForUpdate =[];
    imageKeysWithColor = [];
    imageKeysWithoutColor = [];
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.getProductImage(id);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      imagesWithoutColor = [];
      productReturnImageList = [];
      imagesWithColorForUpdate =[];
      colorImageObject.clear();
      _isLoading = false;
      productImagesModel = ProductImagesModel.fromJson(apiResponse.response?.data);

      if(productImagesModel!.colorImage!.isNotEmpty) {
        colorImageObject = productImagesModel?.colorImage ?? [];

        if(isStorePreviousImage) {
          previousColorImage = [];
          previousColorImage.addAll(productImagesModel?.colorImage ?? []);
          // previousColorImage = productImagesModel?.colorImage ?? [];
          for (var v in previousColorImage) {
            debugPrint('-----------previous image value------${v.imageName?.key} || ${v.imageName?.path} || ${v.color} || ${v.storage}');
          }
        }

        for(int i = 0; i<productImagesModel!.colorImage!.length; i++) {
          ColorImage img = productImagesModel!.colorImage![i];

          if(img.color != null){
            imagesWithColorForUpdate.add(img.imageName?.key ??'');
            log("===>vai response ==> ${img.color}");
          }


          if(imagesWithColor.isNotEmpty) {
            for(int index=0; index<imagesWithColor.length; index++) {
              log("withcolor==> ${imagesWithColor[index].color}----> ${img.color}");
              String retColor = imagesWithColor[index].color!;
              String? bb;
              if(retColor.contains('#')){
                bb = retColor.replaceAll('#', '');
              }
              log("withcolor==>chk $bb----> ${img.color}");
              if(bb == img.color) {
                setStringImage(index, img.imageName?.key  ?? '', img.color ?? '', path: img.imageName?.path);
                imageKeysWithColor.add(img.imageName?.key ?? '');
              }
            }
          }
          // if(img.color == null){
          //   imagesWithoutColor.add(img.imageName?.path ?? '');
          //   withoutColorKeys.add(img.imageName?.key ?? '');
          // }
        }
      }

      List<String> pathList = [];
      List<Map<String, dynamic>> keyList = [];
      final Set<String> colorImagesPaths = {};

      for(final imageModel in imagesWithColor) {
        if(imageModel.colorImage?.imageName?.path != null) {
          colorImagesPaths.add(imageModel.colorImage!.imageName!.path!);

        }
      }


      for(int i = 0; i < (productImagesModel?.images?.length ?? 0); i++) {
        if(productImagesModel?.images?[i].path != '') {

          if(!colorImagesPaths.contains(productImagesModel?.images?[i].path)) {
            pathList.add(productImagesModel?.images![i].path ?? '');

          }

          keyList.add({
            "image_name" : productImagesModel?.images![i].key ?? '',
            "storage" : productImagesModel?.imagesStorage![i].storage ?? 'public',
          });

          imageKeysWithoutColor.add(productImagesModel?.images![i].key ?? '');

        }
      }

      imagesWithoutColor.addAll(pathList);
      productReturnImageList?.addAll(keyList);

    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }

    debugPrint('===============get product images-----------');
    notifyListeners();
  }

  void setStringImage(int index, String image, String colorCode, {String? path}) {
    imagesWithColor[index].imageString = image;
    imagesWithColor[index].colorImage = ColorImage(color: colorCode, imageName: ImageFullUrl(key: image, path: path));
  }



  void removeProductImage ({bool isUpdate = false}) {
    _selectedLogoFile = null;
    _selectedCoverFile = null;
    _selectedMetaImageFile = null;
    _selectedCoveredImageFile = null;

    withoutColor = [];
    productReturnImageList = [];
    colorImageObject = [];
    imagesWithColor = [];
    _productImage = [];

    if(isUpdate) {
      notifyListeners();
    }
  }

  Future<void> deleteProductImage(String id, String name, String? color, {bool updateProductImage = true, bool isCheckError = true}) async {
    //_isLoading = true;
    ApiResponse apiResponse = await shopServiceInterface.deleteProductImage(id, name, color);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(updateProductImage) {
        getProductImage(id);
      }
    } else {
      if(isCheckError) {
        ApiChecker.checkApi(apiResponse);

      }
    }
    notifyListeners();
  }

  void addWithColorImage(String? colorCode, {bool isUpdate = false}) {
    imagesWithColor.add(ImageModel(color: colorCode));

    if(isUpdate) {
      notifyListeners();
    }
  }

  void removeWithColorImage(int index){
    imagesWithColor.removeAt(index);
    notifyListeners();
  }


  void emptyWithColorImage() {
    imagesWithColor = [];
  }



  final List<ColorImage> _deletedColorImageList = [];

  Future<void> onUploadColorImages({required BuildContext context, required bool isUpdate, required int? productId, required Function callBack}) async {
    _deletedColorImageList.clear();

    if(imagesWithColor.isNotEmpty){
      for(int i = 0; i < imagesWithColor.length; i++) {

        ///get delete productImages before update new Color image
        await onDeleteAllProductImage(isUpdate, productId, i);

        if(imagesWithColor[i].image != null && context.mounted){
          await addProductImage(context, imagesWithColor[i], callBack, index: i, update: isUpdate);
        }

      }
    }
  }

  Future<void> onDeleteAllProductImage(bool update, int? productId, int? index) async {
    // Exit early if conditions aren't met
    if (!update || productId == null || previousColorImage.isEmpty || index != 0) {
      return;
    }

    bool isImageDeleted = false;

    // Iterate over withColor list
    for (var element in imagesWithColor) {
      String? imgColor = element.color?.replaceAll('#', '');

      // Find matching color index
      int i = previousColorImage.indexWhere((v) => v.color == imgColor);

      // Ensure valid index and both image and key are present
      if (i != -1 && previousColorImage[i].imageName?.key != null && element.image != null) {
        isImageDeleted = true;
      }
    }

    // If an image is marked for deletion, update state and delete images

    debugPrint('-------is delete-----$isImageDeleted');
    if (isImageDeleted) {
      _isLoading = true;
      notifyListeners();

      // Perform image deletion
      await Future.forEach(imagesWithColor, (element) async {
        String? imgColor = element.color?.replaceAll('#', '');

        int i = previousColorImage.indexWhere((v) => v.color == imgColor);

        if (i != -1 && previousColorImage[i].imageName?.key != null && element.image != null) {
          _deletedColorImageList.add(previousColorImage[i]);
        }
      });

      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> onDeleteColorImages(Product product) async {
    if(_deletedColorImageList.isNotEmpty){
      await Future.forEach(_deletedColorImageList, (image) async {
        await deleteProductImage(product.id.toString(), image.imageName!.key!, null, isCheckError: true);

      });
      await getProductImage(product.id.toString());

      _deletedColorImageList.clear();
    }
  }


}