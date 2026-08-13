import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product_details/domain/services/product_details_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/helper/product_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';

class ProductDetailsController extends ChangeNotifier{

  final ProductDetailsServiceInterface productDetailsServiceInterface;
  ProductDetailsController({required this.productDetailsServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Product? _productDetails;
  Product? get productDetails => _productDetails;
  bool _isDownloadLoading = false;
  bool get isDownloadLoading => _isDownloadLoading;

  bool _isShowMoreActive = false;
  String? _visibleProductDescription;
  String? get visibleProductDescription => _visibleProductDescription;



  Future<void> getProductDetails(int? productId) async {
    _isLoading = true;
    ApiResponse apiResponse = await productDetailsServiceInterface.getProductDetails(productId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _productDetails = Product.fromJson(apiResponse.response!.data);
      _isLoading = false;
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> productStatusOnOff( BuildContext context, int? productId, int status) async {
    ApiResponse apiResponse = await productDetailsServiceInterface.productStatusOnOff(productId, status);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _productDetails!.status = status;
      showCustomSnackBarWidget(getTranslated('status_updated_successfully', Get.context!), Get.context!, isError: false);
      getProductDetails(productId);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void previewDownload({required String url, required String fileName, bool isIos = false}) async {
    _isDownloadLoading = true;
    notifyListeners();

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var selectedFolderType = AndroidFolderType.download;
    final subFolderPathCtrl = TextEditingController();


    List<String> fileTypes = [ '.txt', '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.mp3', '.wav', '.ogg', '.m4a', '.aac',
      '.mp4', '.avi', '.mkv', '.webm', '.3gp', '.pdf', '.doc'];

    if(isIos) {
      HttpClientResponse apiResponse = await productDetailsServiceInterface.previewDownload(url);
      if (apiResponse.statusCode == 200) {

        List<int> downloadData = [];
        Directory downloadDirectory;

        if (Platform.isIOS) {
          downloadDirectory = await getApplicationDocumentsDirectory();
        } else {
          downloadDirectory = Directory('/storage/emulated/0/Download');
          if (!await downloadDirectory.exists()) downloadDirectory = (await getExternalStorageDirectory())!;
        }

        String filePathName = "${downloadDirectory.path}/$fileName";
        File savedFile = File(filePathName);
        bool fileExists = await savedFile.exists();

        if (fileExists) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(content: Text("File already downloaded")));
          _isDownloadLoading = false;
        } else {
          apiResponse.listen((d) => downloadData.addAll(d), onDone: () {
            savedFile.writeAsBytes(downloadData);
          });
          showCustomSnackBarWidget(getTranslated('product_downloaded_successfully', Get.context!), Get.context!, isError: false);

          _isDownloadLoading = false;
          Navigator.of(Get.context!).pop();
        }
      } else {
        _isDownloadLoading = false;

        showCustomSnackBarWidget(getTranslated('product_download_failed', Get.context!), Get.context!);
        Navigator.of(Get.context!).pop();
      }
    } else {
      String? task;
      Directory downloadDirectory = Directory('/storage/emulated/0/Download');
      String filePathName = "${downloadDirectory.path}/$fileName";
      File savedFile = File(filePathName);
      bool fileExists = await savedFile.exists();

      if(fileExists) {
        showCustomSnackBarWidget(getTranslated('file_already_downloaded', Get.context!), Get.context!);
      } else{
        task  = await FlutterDownloader.enqueue(
          url: url,
          savedDir: downloadDirectory.path,
          fileName: fileName,
          showNotification: true,
          saveInPublicStorage: true,
          openFileFromNotification: true,
        );

        if(task != null) {
          if(!fileTypes.contains(ProductHelper.getFileExtension(fileName))){
            showCustomSnackBarWidget(getTranslated('product_downloaded_successfully', Get.context!), Get.context!, isError: false);
            await openFileManager(
              androidConfig: AndroidConfig(
                folderType: selectedFolderType,
              ),
              iosConfig: IosConfig(
                folderPath: subFolderPathCtrl.text.trim(),
              ),
            );
          }else {
            Navigator.of(Get.context!).pop();
          }
        } else{
          showCustomSnackBarWidget(getTranslated('product_download_failed', Get.context!), Get.context!);
          Navigator.of(Get.context!).pop();
        }
      }
      _isDownloadLoading = false;
    }
    notifyListeners();
  }



  void updateVisibleProductDescription(String description, {bool isInitialize = false, bool isUpdate = true}) {

    if (isInitialize) {
      _isShowMoreActive = false;
    }

    if(description.length > 300){
      _isShowMoreActive = !_isShowMoreActive;
    }

    if (description.length > 300 && _isShowMoreActive) {
      _visibleProductDescription = '${description.substring(0, 300)} <span style="color: cornflowerblue;  font-size: 12px;"> ... Show more</span>';
    } else if (description.length > 300 && !_isShowMoreActive) {
      _visibleProductDescription = '${description.trim()} <span style="color: cornflowerblue; font-size: 12px;"> Show less</span>';
    } else {
      _visibleProductDescription = description;
    }

    if(isUpdate){
      notifyListeners();
    }
  }





}