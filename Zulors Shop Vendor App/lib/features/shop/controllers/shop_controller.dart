import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/data/model/response/response_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/show_custom_time_picker.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/payment_information_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/vacation_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/withdrawal_method_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/services/shop_service_interface.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart' hide Data;
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:http/http.dart' as http;
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';

class ShopController extends ChangeNotifier {
  final ShopServiceInterface shopServiceInterface;

  ShopController({required this.shopServiceInterface});


  int _selectedIndex = 0;
  int get selectedIndex =>_selectedIndex;
  String countryDialCode = '+880';

  String ? _vacationDurationType = 'one_day';
  String ? get vacationDurationType => _vacationDurationType;

  final DateFormat _dateFormat = DateFormat('d MMM yy, h:mm a');
  DateFormat get dateFormat => _dateFormat;

  DateTime? _startDateTime;
  DateTime? get startDateTime => _startDateTime;

  DateTime? _endDateTime;
  DateTime? get endDateTime => _endDateTime;

  DateTime? _tinExpireDate;
  DateTime? get tinExpireDate => _tinExpireDate;

  XFile ? _tinCertificateFile;
  XFile? get tinCertificateFile => _tinCertificateFile;

  int _myShopPageIndex = 0;
  int get myShopPageIndex => _myShopPageIndex;

  VacationModel? _vacationModel;
  VacationModel? get vacationModel => _vacationModel;

  WithdrawalMethodModel? _withdrawalMethodModel;
  WithdrawalMethodModel? get withdrawalMethodModel => _withdrawalMethodModel;

  String ? _selectedPaymentMethod = '';
  String ? get selectedPaymentMethod => _selectedPaymentMethod;

  bool ? _selectedPaymentStatus = true;
  bool ? get selectedPaymentStatus => _selectedPaymentStatus;

  PaymentInformationModel ? _paymentInformationModel;
  PaymentInformationModel ? get paymentInformationModel => _paymentInformationModel;

  List<MethodFields> paymentMethodFields = [];

  bool _showAddProductWarning = true;
  bool get showAddProductWarning => _showAddProductWarning;

  bool _isDownloadLoading = false;
  bool get isDownloadLoading => _isDownloadLoading;


  void updateSelectedIndex(int index){
    _selectedIndex = index;
    notifyListeners();
  }


  void setCountryCode( String countryCode, {bool notify = true}) {
    countryDialCode  = countryCode;
    if(notify){
      notifyListeners();
    }
  }


  ShopModel? _shopModel;
  ShopModel? get shopModel => _shopModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  File? _file;

  File? get file => _file;
  final picker = ImagePicker();

  void choosePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 500, maxWidth: 500);
    if (pickedFile != null) {
      _file = File(pickedFile.path);
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
    notifyListeners();
  }

  bool vacationIsOn = false;

  void checkVacation(String vacationEndDate) {
    DateTime vacationDate = DateTime.parse(vacationEndDate);
    final today = DateTime.now();
    final difference = vacationDate.difference(today).inDays;
    if(difference >=0 ){
      vacationIsOn = true;
    }else{
      vacationIsOn = false;
    }
  }


  Future<ResponseModel> getShopInfo() async {
    ResponseModel responseModel;
    ApiResponse apiResponse = await shopServiceInterface.getShop();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _shopModel = ShopModel.fromJson(apiResponse.response!.data);
      responseModel = ResponseModel(true, 'successful');
      if(shopModel!.vacationEndDate != null){
        checkVacation(shopModel!.vacationEndDate!);
      }
      setVacationData(_shopModel);
    } else {
      String? errorMessage;
      if (apiResponse.error is String) {
        errorMessage = apiResponse.error.toString();
      } else {
        errorMessage = apiResponse.error.errors[0].message;
      }
      if (kDebugMode) {
        print(errorMessage);
      }
      responseModel = ResponseModel(false, errorMessage);
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return responseModel;
  }


  void setVacationData(ShopModel? shopModel, {bool isUpdate = false}) {
    if(shopModel != null) {
      _vacationModel = VacationModel(
      vacationStatus: shopModel.vacationStatus,
      vacationDurationType: shopModel.vacationDurationType,
      vacationStartDate: shopModel.vacationStartDate,
      vacationEndDate: shopModel.vacationEndDate,
      vacationNote: shopModel.vacationNote
    );
    }

    if(isUpdate) {
      _startDateTime = null;
      _endDateTime = null;
      _vacationDurationType = shopModel?.vacationDurationType;

      notifyListeners();
    }
  }

  Future<void> updateShopInfo({ShopModel? updateShopModel, File? file,String? minimumOrderAmount,
    String? freeDeliveryStatus,
    String? freeDeliveryOverAmount, String? taxIdentificationNumber, String? tinExpireDate, XFile? tinCertificate, String? stockLimit, bool fromOnOff = false}) async {
    _isLoading = true;
    notifyListeners();

    http.StreamedResponse response = await shopServiceInterface.updateShop(shopModel!, file,
      Provider.of<AuthController>(Get.context!, listen: false).shopBanner,
      Provider.of<AuthController>(Get.context!, listen: false).secondaryBanner,
      Provider.of<AuthController>(Get.context!, listen: false).offerBanner,minimumOrderAmount: minimumOrderAmount,
      freeDeliveryOverAmount: freeDeliveryOverAmount, freeDeliveryStatus: freeDeliveryStatus,
      taxIdentificationNumber: taxIdentificationNumber, tinExpireDate: tinExpireDate, tinCertificate: tinCertificate,
      stockLimit: stockLimit,
    );

    if (response.statusCode == 200) {
      if(fromOnOff){
        Provider.of<ProfileController>(Get.context!, listen: false).setFreeDeliveryStatus(freeDeliveryStatus!);
      }
      showCustomSnackBarWidget(getTranslated('shop_info_updated_successfully', Get.context!), Get.context!, isError: false, sanckBarType: SnackBarType.success);
      _tinCertificateFile = null;
      if(_shopModel?.reorderLevel != int.tryParse(stockLimit ?? '0')) {
        Provider.of<ProductController>(Get.context!, listen: false).getStockOutProductList(1, 'en');
      }
      getShopInfo();
      Provider.of<ProfileController>(Get.context!, listen: false).getSellerInfo();
    }

    _isLoading = false;
    notifyListeners();
  }



  Future<void> shopTemporaryClose(BuildContext context, int status) async {
    Navigator.of(context).pop();
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.temporaryClose(status);

    if (apiResponse.response!.statusCode == 200) {
      _isLoading = false;

      showCustomSnackBarWidget(getTranslated('status_updated_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      getShopInfo();

    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  Future<void> shopVacation(BuildContext context, VacationModel vacationModel) async {

    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.vacation(vacationModel);

    if (apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      showCustomSnackBarWidget(getTranslated('status_updated_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      getShopInfo();

    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  final int _selectedItem = 0;
  int get selectedItem => _selectedItem;
  String _startDate = 'Start Date';
  String get startDate => _startDate;
  String _endDate = 'End Date';
  String get endDate => _endDate;


  Future <void> selectDate(BuildContext context,String startDate, String endDate) async {
    _startDate = startDate;
    _endDate = endDate;
    notifyListeners();
  }






  void setVacationDurationType(String index, {bool isUpdate = true}) {
    _vacationDurationType = index;
    _vacationModel?.vacationDurationType = index;
    if(isUpdate) {
      notifyListeners();
    }
  }

  void selectDateTime(String type, bool is24Hour,BuildContext context, {DateTime? dateTime}) async {
    TimeOfDay? time;

    showDatePicker(
      context: context,
      initialDate: dateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((date) async {
      date = date;
      if(date == null){
      }

      if(date != null) {
        time = await showCustomTimePicker(
          dateTime: dateTime,
        );
      }

      DateTime?  combinedDateTime;
      if(date != null) {
        combinedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time!.hour,
          time!.minute,
        );
      }

      if(is24Hour) {
        setVacationDurationType('custom');
      }
      if (type == 'start') {
        _startDateTime = combinedDateTime;
        if(_startDateTime != null) {
          _vacationModel?.vacationStartDate = _startDateTime.toString();
        }
      } else {
        _endDateTime = combinedDateTime;
        if(_endDateTime != null) {
          _vacationModel?.vacationEndDate = _endDateTime.toString();
        }
      }
      notifyListeners();
    });
  }

  void set24HourVacation({bool isUpdate = false}) {
    _startDateTime = DateTime.now();
    _endDateTime = _startDateTime?.add(const Duration(hours: 24));

    _vacationModel?.vacationStartDate = _startDateTime.toString();
    _vacationModel?.vacationEndDate = _endDateTime.toString();
    if(isUpdate) {
      notifyListeners();
    }
  }

  void setShopPageIndex(int index, {bool isUpdate = true}) {
    _myShopPageIndex = index;
    if(isUpdate) {
      notifyListeners();
    }
  }


  void setVacationStatus() {
    _vacationModel?.vacationStatus = !(_vacationModel?.vacationStatus ?? false);
    notifyListeners();
  }



  Future<ResponseModel> getPaymentWithdrawalMethodList() async {
    ResponseModel responseModel;
    ApiResponse apiResponse = await shopServiceInterface.getPaymentWithdrawalMethodList();

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _withdrawalMethodModel = null;
      _withdrawalMethodModel = WithdrawalMethodModel.fromJson(apiResponse.response!.data);
      responseModel = ResponseModel(true, 'successful');
    } else {
      String? errorMessage;
      if (apiResponse.error is String) {
        errorMessage = apiResponse.error.toString();
      } else {
        errorMessage = apiResponse.error.errors[0].message;
      }
      if (kDebugMode) {
        print(errorMessage);
      }
      responseModel = ResponseModel(false, errorMessage);
      ApiChecker.checkApi(apiResponse);
    }

    return responseModel;
  }


  void setSelectedPaymentMethod (String method) {
    _selectedPaymentMethod = method;
    setMethodFields(method);
    notifyListeners();
  }




  void setMethodFields(String paymentMethod) {
    paymentMethodFields = [];
    for(Data method in  (_withdrawalMethodModel?.data ?? [])) {

      if(method.methodName == paymentMethod) {

        for(MethodFields methodField in (method.methodFields ?? []) ) {
          methodField.textEditingController = TextEditingController();
          paymentMethodFields.add(methodField);
        }
        break;
      }
    }
  }


  int? getPaymentMethodId (String paymentMethod) {
    int? id;
    for(Data method in  (_withdrawalMethodModel?.data ?? [])) {
      if(method.methodName == paymentMethod) {
        id = method.id;
        break;
      }
    }
    return id;
  }

  void setPaymentStatus(bool value, {bool isUpdate = true}) {
    _selectedPaymentStatus = value;
    if(isUpdate) {
      notifyListeners();
    }
  }


  void setMethodCountryCode(int index, String code) async {
    paymentMethodFields[index].countryCode = code;
    notifyListeners();
  }

  Future<DateTime?> pickDate(BuildContext context, index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );

    paymentMethodFields[index].dateTime = picked;
    notifyListeners();
    return picked;
  }



  Future<ApiResponse> addPaymentInfo(BuildContext context, WithdrawAddModel vacationModel, {bool isUpdate = false}) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await shopServiceInterface.addPaymentInfo(vacationModel, isUpdate);
    if (apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      if(!isUpdate) {
        showCustomSnackBarWidget(getTranslated('payment_method_added_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      } else {
        showCustomSnackBarWidget(getTranslated('status_updated_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      }
      getPaymentInfoList(1);
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();

    return apiResponse;
  }


  Future<void> getPaymentInfoList(int? offset) async {
    ApiResponse apiResponse = await shopServiceInterface.getPaymentInfoList(offset);
    if(apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        _paymentInformationModel = PaymentInformationModel.fromJson(apiResponse.response?.data);
      }else {
        _paymentInformationModel!.data!.addAll(PaymentInformationModel.fromJson(apiResponse.response?.data).data ?? []);
        _paymentInformationModel!.offset = PaymentInformationModel.fromJson(apiResponse.response?.data).offset;
        _paymentInformationModel!.totalSize = PaymentInformationModel.fromJson(apiResponse.response?.data).totalSize;
        _paymentInformationModel!.limit = PaymentInformationModel.fromJson(apiResponse.response?.data).limit;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }



  Future<void> updatePaymentMethodStatus(bool status, int index, int id,) async {
    ApiResponse apiResponse  = await shopServiceInterface.updateConfigStatus(status, id);
    if (apiResponse.response!.statusCode == 200) {
      showCustomSnackBarWidget(getTranslated('status_updated_successfully', Get.context!), Get.context!, isError: false, sanckBarType: SnackBarType.success);
      _paymentInformationModel?.data?[index].isActive = status;
    }
    notifyListeners();
  }

  Future<void> deletePaymentMethodStatus(int id, int index) async {
    ApiResponse apiResponse  = await shopServiceInterface.deletePaymentMethod(id);
    if (apiResponse.response!.statusCode == 200) {
      showCustomSnackBarWidget(getTranslated('payment_method_deleted_successfully', Get.context!), Get.context!, isError: false, sanckBarType: SnackBarType.success);
      _paymentInformationModel?.data?.removeAt(index);
    }
    notifyListeners();
  }


  Future<void> setDefaultPaymentMethod(int id) async {
    ApiResponse apiResponse  = await shopServiceInterface.setDefaultPaymentMethod(id);
    if (apiResponse.response!.statusCode == 200) {
      showCustomSnackBarWidget(getTranslated('payment_method_deleted_successfully', Get.context!), Get.context!, isError: false, sanckBarType: SnackBarType.success);
      getPaymentInfoList(1);
    }
    notifyListeners();
  }


  Future<DateTime?> pickTinExpireDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    _tinExpireDate = picked;
    notifyListeners();
    return picked;
  }


  void pickTinCertificateFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withReadStream: true,
      withData: true,
      allowedExtensions: ['pdf', 'jpg', "doc"],
    );

    if(result != null){
      Uint8List? imageBytes = result.files.first.bytes;
      File? file = await File(result.files.first.path!).writeAsBytes(imageBytes!);

      XFile xFile =  XFile(file.path);

      double fileSizeInMB = await ImageSize.getImageSizeFromXFile(xFile);

      ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

      if(fileSizeInMB > (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
        showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
      } else {
        _tinCertificateFile = xFile;
      }
    }
    notifyListeners();
  }

  void removeTinCertificateFile() {
    _tinCertificateFile = null;
    notifyListeners();
  }

  void setExpireDate(DateTime? date) {
    _tinExpireDate = date;
  }


  Future<void> updateSetupGuideApp(String key, int value) async {
    ApiResponse apiResponse  = await shopServiceInterface.updateSetupGuideApp(key, value);
    if (apiResponse.response!.statusCode == 200) {
      getShopInfo();
    }
    notifyListeners();
  }


  void setShowAddProductWarning (bool value) {
    _showAddProductWarning = value;
    notifyListeners();
  }


  void resetPaymentInfoData() {
    _selectedPaymentMethod = '';
    paymentMethodFields = [];
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

    if (true) {
      HttpClientResponse apiResponse = await  shopServiceInterface.downloadTinCertificate(url);
      if (apiResponse.statusCode == 200) {

        List<int> downloadData = [];
        Directory downloadDirectory;

        if (Platform.isIOS) {
          downloadDirectory = await getApplicationDocumentsDirectory();
        } else {
          downloadDirectory = Directory('/storage/emulated/0/Download');
          if (!await downloadDirectory.exists()) {
            downloadDirectory = (await getExternalStorageDirectory())!;
          }
        }

        String filePathName = "${downloadDirectory.path}/$fileName";

          List<String> parts = fileName.split('.');
          String filename = parts[0];
          String extention = parts[1];


          int fileCounter = 1;

          while (await File(filePathName).exists()) {
            fileName = '${filename+fileCounter.toString()}.$extention';
            filePathName = "${downloadDirectory.path}/$fileName";
            fileCounter++;
          }

          File savedFile = File(filePathName);

          apiResponse.listen((d) => downloadData.addAll(d), onDone: () {
            savedFile.writeAsBytes(downloadData);
          });
          showCustomSnackBarWidget( getTranslated('file_downloaded_successfully', Get.context!),
            Get.context!, isError: false);

          await openFileManager(
            androidConfig: AndroidConfig(
              folderType: selectedFolderType,
            ),
            iosConfig: IosConfig(
              folderPath: subFolderPathCtrl.text.trim(),
            ),
          );

          _isDownloadLoading = false;
          notifyListeners();
      } else {
        _isDownloadLoading = false;

        showCustomSnackBarWidget(getTranslated('file_download_failed', Get.context!), Get.context!);
        Navigator.of(Get.context!).pop();
      }
    }
  }


  void clearShopModel({bool isUpdate = true}) {
    _tinCertificateFile = null;
    _tinExpireDate = null;
    _shopModel = null;
    if(isUpdate) {
      notifyListeners();
    }
  }

  void updateTutorialFlow(String key) {
    _shopModel?.setupGuideApp?[key] = 1;
    notifyListeners();
  }


}


