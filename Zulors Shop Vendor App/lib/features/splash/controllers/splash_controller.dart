import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/maintenance/maintenance_screen.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/business_pages_model.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/features/splash/domain/services/splash_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/main.dart';

class SplashController extends ChangeNotifier {
  final SplashServiceInterface serviceInterface;
  SplashController({required this.serviceInterface});

  ConfigModel? _configModel;
  BaseUrls? _baseUrls;
  CurrencyList? _myCurrency;
  CurrencyList? _defaultCurrency;
  CurrencyList? _usdCurrency;
  int? _currencyIndex;
  int? _shippingIndex;
  bool _hasConnection = true;
  bool _fromSetting = false;
  bool _firstTimeConnectionCheck = true;
  List<String>? _unitList;
  List<ColorList>? _colorList;
  final int _unitIndex = 0;
  final int _colorIndex = 0;
  List<String>? get unitList => _unitList;
  List<ColorList>? get colorList => _colorList;
  int get unitIndex => _unitIndex;
  int get colorIndex =>_colorIndex;
  List<String?> _shippingTypeList = [];
  final String _shippingStatusType = '';
  List<String?> get shippingTypeList => _shippingTypeList;
  String get shippingStatusType => _shippingStatusType;
  List<BusinessPageModel>? _defaultBusinessPages;
  List<BusinessPageModel>? get defaultBusinessPages => _defaultBusinessPages;


  ConfigModel? get configModel => _configModel;
  BaseUrls? get baseUrls => _baseUrls;
  CurrencyList? get myCurrency => _myCurrency;
  CurrencyList? get defaultCurrency => _defaultCurrency;
  CurrencyList? get usdCurrency => _usdCurrency;
  int? get currencyIndex => _currencyIndex;
  int? get shippingIndex => _shippingIndex;
  bool get hasConnection => _hasConnection;
  bool get fromSetting => _fromSetting;
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  final bool _isLoading = false;
  bool get isLoading => _isLoading;


  BuildContext? _buildContext;

  ///Refector this
  Future<bool> initConfig() async {
    _configModel = null;
    _hasConnection = true;
    ApiResponse apiResponse = await serviceInterface.getConfig();
    bool isSuccess;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _configModel = ConfigModel.fromJson(apiResponse.response!.data);
      _baseUrls = ConfigModel.fromJson(apiResponse.response!.data).baseUrls;
      String? currencyCode = serviceInterface.getCurrency();
      for(CurrencyList currencyList in _configModel!.currencyList!) {
        if(currencyList.id == _configModel!.systemDefaultCurrency) {
          if(currencyCode == null || currencyCode.isEmpty) {
            currencyCode = currencyList.code;
          }
          _defaultCurrency = currencyList;
        }
        if(currencyList.code == 'USD') {
          _usdCurrency = currencyList;
        }
      }

      getCurrencyData(currencyCode);

      if(_configModel?.maintenanceModeData?.maintenanceStatus == 0){
        if(_configModel?.maintenanceModeData?.selectedMaintenanceSystem?.vendorApp == 1 ) {
          if(_configModel?.maintenanceModeData?.maintenanceTypeAndDuration?.maintenanceDuration == 'customize'){

            DateTime now = DateTime.now();
            DateTime specifiedDateTime = DateTime.parse(_configModel!.maintenanceModeData!.maintenanceTypeAndDuration!.startDate!);

            Duration difference = specifiedDateTime.difference(now);


            if(difference.inMinutes > 0 && (difference.inMinutes < 60 || difference.inMinutes == 60)){
              _startTimer(specifiedDateTime);
            }

          }
        }
      }

      isSuccess = true;
    } else {
      isSuccess = false;
      ApiChecker.checkApi(apiResponse);
      if(apiResponse.error.toString() == 'Connection to API server failed due to internet connection') {
        _hasConnection = false;
      }
    }
    notifyListeners();
    return isSuccess;
  }


  Future<void> getBusinessPagesList(String type) async {
    ApiResponse apiResponse = await serviceInterface.getBusinessPages(type);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      if(type == 'default') {
        _defaultBusinessPages = [];
        apiResponse.response?.data.forEach((data) { _defaultBusinessPages?.add(BusinessPageModel.fromJson(data));});
      }
    } else {
      ApiChecker.checkApi( apiResponse);
    }

    notifyListeners();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void getCurrencyData(String? currencyCode) {
    for (var currency in _configModel!.currencyList!) {
      if(currencyCode == currency.code) {
        _myCurrency = currency;
        _currencyIndex = _configModel!.currencyList!.indexOf(currency);
        continue;
      }
    }
  }

  Future<List<int?>> getColorList() async {
    List<int?> colorIds = [];
    _colorList = [];
    for (ColorList item in _configModel!.colors!) {
      _colorList!.add(item);
      colorIds.add(item.id);
    }
    return colorIds;
  }



  void setCurrency(int index) {
    serviceInterface.setCurrency(_configModel!.currencyList![index].code!);
    getCurrencyData(_configModel!.currencyList![index].code);
    notifyListeners();
  }
  void setShippingType(int index) {
    serviceInterface.setShippingType(_shippingTypeList[index]!);
    notifyListeners();
  }

  void initShippingType(String? type) {
    _shippingIndex = _shippingTypeList.indexOf(type);
    notifyListeners();
  }


  void initSharedPrefData() {
    serviceInterface.initSharedData();
  }

  void setFromSetting(bool isSetting) {
    _fromSetting = isSetting;
  }




  void initShippingTypeList(BuildContext context, String type) async {
    _shippingTypeList.clear();
    _shippingTypeList =[];
    ApiResponse apiResponse = await serviceInterface.getShippingTypeList(context,type);
    _shippingTypeList.addAll(apiResponse.response!.data);
    notifyListeners();
  }

  void _startTimer (DateTime startTime){
    Timer.periodic(const Duration(seconds: 30), (Timer timer) {

      DateTime now = DateTime.now();

      if (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) {
        timer.cancel();
        Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
          builder: (_) => const MaintenanceScreen(),
          settings: const RouteSettings(name: 'MaintenanceScreen'),
        )
        );
      }

    });
  }



  void setMaintenanceContext(BuildContext context){
    _buildContext = context;
  }

  void removeMaintenanceContext(){
    _buildContext = null;
  }

  bool isMaintenanceModeScreen() {
    if (_buildContext == null || configModel?.maintenanceModeData?.maintenanceStatus == 1) {
      return false;
    }
    return ModalRoute.of(_buildContext!)?.settings.name == 'MaintenanceScreen';
  }

}
