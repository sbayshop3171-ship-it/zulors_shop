import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/models/chearance_slale_add_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/models/clearance_config_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/models/clearnace_sale_product_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/services/clearance_sale_service_interface.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/show_custom_time_picker.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';

class ClearanceSaleController extends ChangeNotifier {
  final ClearanceSaleServiceInterface chatServiceInterface;
  ClearanceSaleController({required this.chatServiceInterface});

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  bool _isClearanceSaleActive = false;
  bool get isClearanceSaleActive => _isClearanceSaleActive;


  int _selectedDiscountType = 1;
  int get selectedDiscountType => _selectedDiscountType;


  int _selectedOfferActiveType = 1;
  int get selectedOfferActiveType => _selectedOfferActiveType;

  String? _offerStartTime ;
  String? get offerStartTime => _offerStartTime;
  set setOfferStartTime(String? time) {
    _offerStartTime = time;
    notifyListeners();
  }


  String? _offerEndTime;
  String? get offerEndTime => _offerEndTime;
  set setServiceEndTime(String? time) {
    _offerEndTime = time;
    notifyListeners();
  }

  List<ClearanceSaleAddModel> _clearanceSaleAddModel =  [];
  List<ClearanceSaleAddModel> get clearanceSaleAddModel => _clearanceSaleAddModel;

  ProductModel? _sellerProductModel;
  ProductModel? get sellerProductModel => _sellerProductModel;


  List<Product>? _selectedProductModel = [];
  List<Product>?  get selectedProductModel => _selectedProductModel;

  List<int>? _selectedProductIds = [];
  List<int>?  get selectedProductIds => _selectedProductIds;

  List<String> nameList = [];

  ClearanceSaleProductModel? _clearanceSaleProductModel;
  ClearanceSaleProductModel? get clearanceSaleProductModel => _clearanceSaleProductModel;

  ClearanceConfigModel? _clearanceConfigModel;
  ClearanceConfigModel? get clearanceConfigModel => _clearanceConfigModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  bool _isConfigLoading = false;
  bool get isConfigLoading => _isConfigLoading;


  final DateFormat _dateFormat = DateFormat('d MMM yy, h:mm a');
  DateFormat get dateFormat => _dateFormat;

  final TextEditingController discountController = TextEditingController();


  void setClearanceStatus(bool value, {bool isUpdate = true}) {
    _isClearanceSaleActive = value;
    if(isUpdate) {
      notifyListeners();
    }
  }

  Future <void> setSelectedDiscountType (int type, {bool isUpdate = true}) async {
    _selectedDiscountType = type;
    notifyListeners();
  }


  Future <void> setSelectedOfferActiveType (int type, {bool isUpdate = true}) async {
    _selectedOfferActiveType = type;
    notifyListeners();
  }


  String formatDateString(String dateString) {
    List<String> dateParts = dateString.split('-');
    String formattedDateString = "${dateParts[0]}-${dateParts[1].padLeft(2, '0')}-${dateParts[2].padLeft(2, '0')}";

    return formattedDateString;
  }

  Future<void> getClearanceSaleProductList(int offset, {bool reload = false}) async {
    if(reload){
      _clearanceSaleProductModel = null;
    }
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.getClearanceSaleProductList( offset);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        _clearanceSaleProductModel = null;
        _clearanceSaleProductModel = ClearanceSaleProductModel.fromJson(apiResponse.response!.data);
      }else {
        _clearanceSaleProductModel!.totalSize = ClearanceSaleProductModel.fromJson(apiResponse.response!.data).totalSize;
        _clearanceSaleProductModel!.offset = ClearanceSaleProductModel.fromJson(apiResponse.response!.data).offset;
        _clearanceSaleProductModel!.products!.addAll(ClearanceSaleProductModel.fromJson(apiResponse.response!.data).products!);
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> deleteClearanceSaleProductList(int? productId, int? index) async {
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.clearanceSaleProductDelete(productId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(index != null) {
        _clearanceSaleProductModel!.totalSize = _clearanceSaleProductModel!.totalSize! - 1;
        _clearanceSaleProductModel!.products!.removeAt(index);
      }
      showCustomSnackBarWidget(apiResponse.response?.data['message'], Get.context!, isToaster: true, isError: false);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> deleteClearanceSaleAllProduct() async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await chatServiceInterface.clearanceSaleProductDeleteAll();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(_clearanceSaleProductModel != null) {
        _clearanceSaleProductModel!.products = [];
        _clearanceSaleProductModel!.totalSize = 0;
      }
      showCustomSnackBarWidget(apiResponse.response?.data['message'], Get.context!, isToaster: true, isError: false);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> updateClearanceSaleProductStatus(int productId, int isActive, int index) async {
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.clearanceSaleProductStatusUpdate(productId, isActive);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _clearanceSaleProductModel!.products![index].isActive =  (_clearanceSaleProductModel!.products![index].isActive == 0 ? 1 : 0);

      showCustomSnackBarWidget(apiResponse.response?.data['message'], Get.context!, isToaster: true, isError: false);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> getSearchProductList(String sellerId, int offset, BuildContext context, String languageCode,String search, {bool reload = true}) async {

    if(reload) {
      _isLoading = true;
      _sellerProductModel = null ;
      notifyListeners();
    }
    ApiResponse apiResponse = await chatServiceInterface.getSellerProductList(sellerId, offset,languageCode, search);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        _sellerProductModel = ProductModel.fromJson(apiResponse.response!.data, fromGetProducts: true);
      } else {
        _sellerProductModel!.products!.addAll(ProductModel.fromJson(apiResponse.response!.data, fromGetProducts: true).products??[],);
        _sellerProductModel!.offset = ProductModel.fromJson(apiResponse.response!.data).offset;
        _sellerProductModel!.totalSize = ProductModel.fromJson(apiResponse.response!.data).totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  void emptySearchListAddList() {
    _sellerProductModel = null;
    notifyListeners();
  }


  Future<void> getClearanceConfigData() async {
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.getConfigData();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _clearanceConfigModel = ClearanceConfigModel.fromJson(apiResponse.response?.data);

      _isClearanceSaleActive = _clearanceConfigModel?.isActive == 1;
      _selectedDiscountType = _clearanceConfigModel?.discountType == 'product_wise' ? 2 :1;
      discountController.text = '${_clearanceConfigModel?.discountAmount ?? 0}';
      _selectedOfferActiveType = _clearanceConfigModel?.offerActiveTime == 'specific_time' ? 2 : 1;

      _offerStartTime = _clearanceConfigModel!.offerActiveRangeStart != null ?
          formatTime(DateFormat('hh:mm:ss a').parse(_clearanceConfigModel!.offerActiveRangeStart!)) : null;

      _offerEndTime = _clearanceConfigModel!.offerActiveRangeEnd != null ?
      formatTime(DateFormat('hh:mm:ss a').parse(_clearanceConfigModel!.offerActiveRangeEnd!)) : null;

      _startDate = _clearanceConfigModel?.durationStartDate != null ?
        DateTime.parse(_clearanceConfigModel?.durationStartDate ?? '').toLocal() : null;


      _endDate = _clearanceConfigModel?.durationEndDate != null ?
        DateTime.parse(_clearanceConfigModel?.durationEndDate ?? '').toLocal() : null;

      await getClearanceSaleProductList(1, reload: false);

    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  String formatDurationDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MM/dd/yyyy hh:mm:ss a');
    return formatter.format(dateTime);
  }

  Future<void> saveClearanceConfigData() async {
    _isConfigLoading = true;
    notifyListeners();

    Map<String, dynamic> data = {
      "discount_type" : _selectedDiscountType ==1 ? 'flat' : 'product_wise',
      "discount_amount" : discountController.text,
      "offer_active_time" : _selectedOfferActiveType == 1 ? 'always' : 'specific_time',
      'clearance_sale_duration' : "${formatDurationDateTime(_startDate!)} - ${formatDurationDateTime(_endDate!)}"
    };

    if(_selectedOfferActiveType == 2){
      data.addAll(
        {
          "offer_active_range" : '$_offerStartTime - $_offerEndTime'
        }
      );
    }

    ApiResponse apiResponse = await chatServiceInterface.updateClearanceSaleConfigData(data);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      await getClearanceConfigData();
      showCustomSnackBarWidget(getTranslated('setup_updated_successfully', Get.context!), Get.context!, isError: false);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isConfigLoading = false;
    notifyListeners();
  }

  void resetConfig () {
    _isClearanceSaleActive = _clearanceConfigModel?.isActive == 1;
    _selectedDiscountType = _clearanceConfigModel?.discountType == 'product_wise' ? 2 :1;
    discountController.text = _clearanceConfigModel!.discountAmount.toString();
    _selectedOfferActiveType = _clearanceConfigModel?.offerActiveTime == 'specific_time' ? 2 : 1;

    _offerStartTime = _clearanceConfigModel!.offerActiveRangeStart != null ?
    formatTime(DateFormat('hh:mm:ss a').parse(_clearanceConfigModel!.offerActiveRangeStart!)) : null;

    _offerEndTime = _clearanceConfigModel!.offerActiveRangeEnd != null ?
    formatTime(DateFormat('hh:mm:ss a').parse(_clearanceConfigModel!.offerActiveRangeEnd!)) : null;


    _startDate = DateTime.parse(_clearanceConfigModel?.durationStartDate ?? '');
    _endDate = DateTime.parse(_clearanceConfigModel?.durationEndDate ?? '');

    notifyListeners();
  }


  String formatTime(DateTime dateTime) {
    final DateFormat timeFormatter = DateFormat('hh:mm a');
    return timeFormatter.format(dateTime);
  }


  Future<void> updateConfigStatus(int value) async {
    _isLoading = true;
    ApiResponse apiResponse = await chatServiceInterface.updateConfigStatus(value);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      getClearanceConfigData();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }



  void addClearanceSaleAddList(ClearanceSaleAddModel  product) {
    _clearanceSaleAddModel.add(product);
    notifyListeners();
  }

  ({double minPrice, double maxPrice}) getMinMaxValues(List<Variation> variations) {
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;

    for (var variation in variations) {
      if (variation.price != null) {
        minPrice = minPrice < variation.price! ? minPrice : variation.price!;
        maxPrice = maxPrice > variation.price! ? maxPrice : variation.price!;
      }
    }

    return (minPrice: minPrice, maxPrice: maxPrice);
  }


  void setSelectedProduct (Product product, int index) {
    _selectedProductModel!.add(product);
    _selectedProductIds!.add(product.id!);
    _clearanceSaleAddModel.add(
        ClearanceSaleAddModel(
          id: product.id,
          type: 'percent',
          amount: 0,
          isWrongAmount: true,
          amountController: TextEditingController(
            text: _clearanceConfigModel?.discountType == 'flat' ?  _clearanceConfigModel?.discountAmount.toString() : '0',
          ),
        )
    );
    notifyListeners();
  }


  void removeSelectedProduct (int index) {
    _selectedProductModel!.removeAt(index);
    _selectedProductIds!.removeAt(index);
    _clearanceSaleAddModel.removeAt(index);
    notifyListeners();
  }


  void setSelectedProductDiscountType(int index, String discountType) {
    _clearanceSaleAddModel[index].type = discountType;
    notifyListeners();
  }



  Future<void> clearanceSaleProductAdd() async {
    _isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> productList = [];

    for(ClearanceSaleAddModel product in _clearanceSaleAddModel) {
      productList.add(
        {
          "id" : product.id,
          "discount_amount" : product.amountController.text.toString(),
          "discount_type" : product.type == 'percent' ? 'percentage' : 'flat',
        }
      );
    }

    Map<String, dynamic> data = {
      "products" : productList
    };

    ApiResponse apiResponse = await chatServiceInterface.clearanceSaleProductAdd(data);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      clearSelectedProducts();
      getClearanceSaleProductList(1);
      showCustomSnackBarWidget(getTranslated('product_added_successfully', Get.context!), Get.context!, isError: false);
      Navigator.of(Get.context!).pop();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }


  Future<void> clearanceSaleProductUpdate(int productId, String amount, String discountType) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> data = {
      "product_id" : productId,
      "discount_amount" : amount,
      "discount_type" : discountType == 'percent' ? 'percentage' : 'flat'
    };

    ApiResponse apiResponse = await chatServiceInterface.updateClearanceSaleProductDiscount(data);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Navigator.of(Get.context!).pop();
      await getClearanceSaleProductList(1, reload: false);
      showCustomSnackBarWidget(getTranslated('product_discount_updated', Get.context!), Get.context!, isError: false);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }



  void clearSelectedProducts() {
    _selectedProductModel = [];
    _selectedProductIds = [];
    _clearanceSaleAddModel= [];
    notifyListeners();
  }



  void selectDate(String type, BuildContext context) async {
    TimeOfDay? time;

    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((date) async {
      date = date;
      if(date == null){
      }

      if(date != null) {
        time = await showCustomTimePicker();
      }


      DateTime combinedDateTime = DateTime(
        date!.year,
        date.month,
        date.day,
        time!.hour,
        time!.minute,
      );

      if (type == 'start'){
        _startDate = combinedDateTime;
      }else{
        _endDate = combinedDateTime;
      }

      notifyListeners();
    });
  }



  bool isEndDateValid(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }

  bool isEndTimeValid(String startTime, String endTime) {
    final DateFormat format = DateFormat.jm();

    final DateTime start = format.parse(startTime);
    final DateTime end = format.parse(endTime);

    return end.isAfter(start) || end.isAtSameMomentAs(start);
  }


  double getVariationMinimumPrice({
    List<DigitalVariation>? digitalVariation,
    List<Variation>? physicalVariation,
  }) {
    List<double> prices = [];

    if (digitalVariation != null) {
      prices.addAll(digitalVariation.map((variation) {
        return variation.price!;
      }));
    }

    if (physicalVariation != null) {
      prices.addAll(physicalVariation.map((variation) {
        return variation.price!;
      }));
    }

    return prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
  }


}
