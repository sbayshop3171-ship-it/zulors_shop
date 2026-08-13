
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/customer_controller.dart';
import 'package:zulors_shop_vendor/features/review/domain/models/product_review_model.dart';
import 'package:zulors_shop_vendor/features/review/domain/models/ratting_model.dart';
import 'package:zulors_shop_vendor/features/review/domain/models/review_model.dart';
import 'package:zulors_shop_vendor/features/review/domain/services/review_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/features/review/domain/models/review_model.dart' as rm;
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';

class ProductReviewController extends ChangeNotifier{
  final ReviewServiceInterface reviewServiceInterface;
  ProductReviewController({required this.reviewServiceInterface});


  List<ReviewModel> _reviewList = [];
  List<ReviewModel> get reviewList => _reviewList;
  List<int> _offsetList = [];
  int _offset = 1;
  int get offset => _offset;
  final List<bool> _isOn = [];
  List<bool> get isOn=>_isOn;
  ProductReviewModel? _productReviewModel;
  ProductReviewModel? get productReviewModel => _productReviewModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<rm.ReviewModel> _productReviewList =[];
  List<rm.ReviewModel> get productReviewList => _productReviewList;


  List<String> reviewStatusList = ['select_status','active', 'inactive'];
  int _reviewStatusIndex = 0;
  int get reviewStatusIndex => _reviewStatusIndex;
  String _reviewStatusName = 'select_status';
  String get reviewStatusName => _reviewStatusName;

  int? _selectedProductId = 0;
  int? get selectedProductId => _selectedProductId;
  String selectedProductName = 'Select Product';
  TextEditingController  reviewReplyController = TextEditingController();


  void setReviewProductIndex(int? index, int? productId, String? productName, bool notify) {
    _selectedProductId = productId;
    selectedProductName = productName ?? '';

    if (notify) {
      Navigator.of(Get.context!).pop();
      Future.delayed(Duration.zero, () {
        notifyListeners();
      });
    }
  }


  void setReviewStatusIndex(int index){
    _reviewStatusIndex = index;
    if(_reviewStatusIndex == 0){
      _reviewStatusName = reviewStatusList[0];
    }else if(_reviewStatusIndex == 1){
      _reviewStatusName = reviewStatusList[1];
    }else{
      _reviewStatusName = reviewStatusList[2];
    }
    notifyListeners();
  }

  bool _allFieldSelected = true;
  bool get allFieldSelected => _allFieldSelected;

  Future<void> getReviewList(BuildContext context) async{
    _isLoading = true;

    ApiResponse apiResponse = await reviewServiceInterface.productReviewList();

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      _reviewList = [];
        RattingModel reviewModel = RattingModel.fromJson(apiResponse.response!.data);
        _reviewList.addAll(reviewModel.reviews!);
        for(ReviewModel review in _reviewList){
          _isOn.add(review.status == 1? true:false);
        }
    }else{
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }




  Future<void> filterReviewList(BuildContext context, int? productId, int? customerId, ) async{
    ApiResponse apiResponse = await reviewServiceInterface.filterProductReviewList(productId, customerId,
        _reviewStatusIndex == 2 ? 0 : _reviewStatusIndex == 0 ? 3 : _reviewStatusIndex  , _startDate != null? dateFormat.format(_startDate!).toString(): null ,
        _endDate != null ? dateFormat.format(_endDate!).toString(): null);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Navigator.pop(Get.context!);
      _isLoading = false;
      _reviewList = [];
      RattingModel reviewModel = RattingModel.fromJson(apiResponse.response!.data);
      _reviewList.addAll(reviewModel.reviews!);
      for(ReviewModel review in _reviewList){
        _isOn.add(review.status == 1? true:false);
      }
      if (kDebugMode) {
        print(reviewList);
      }

    }else{
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  Future<void> searchReviewList(BuildContext context, String search) async{
    ApiResponse apiResponse = await reviewServiceInterface.searchProductReviewList(search);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      _reviewList = [];
      RattingModel reviewModel = RattingModel.fromJson(apiResponse.response!.data);
      _reviewList.addAll(reviewModel.reviews!);
      for(ReviewModel review in _reviewList){
        _isOn.add(review.status == 1? true:false);
      }
      if (kDebugMode) {
        print(reviewList);
      }

    }else{
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }



  void setToggleSwitch(int index){
    _isOn[index] = !_isOn[index];
    notifyListeners();
  }


  Future<void> reviewStatusOnOff(BuildContext context, int? reviewId, int status, int? index, {bool fromProduct = false}) async{
    ApiResponse apiResponse = await reviewServiceInterface.reviewStatusOnOff(reviewId,status);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(fromProduct){
        _productReviewList[index!].status = status;
      }else{
        _reviewList[index!].status = status;
      }
      showCustomSnackBarWidget(getTranslated('review_status_updated_successfully', Get.context!), Get.context!, isError: false);
    }else{
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  DateFormat get dateFormat => _dateFormat;

  void selectDate(String type, BuildContext context){
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    ).then((date) {
      if (type == 'start'){
        _startDate = date;
      }else{
        _endDate = date;
      }
      if(date == null){

      }
      notifyListeners();
    });
  }


  Future<void> getProductWiseReviewList(BuildContext context,int offset,int? productId, {bool reload = false}) async {
    if(reload || offset == 1) {
      _offset = 1;
      _offsetList = [];
      _productReviewList = [];
    }
    _isLoading = true;
    if(!_offsetList.contains(offset)){
      _offsetList.add(offset);
      ApiResponse apiResponse = await reviewServiceInterface.getProductWiseReviewList(productId, offset);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

        _productReviewModel = ProductReviewModel.fromJson(apiResponse.response!.data);
        _productReviewList.addAll(_productReviewModel!.reviews!);
        _isLoading = false;
      } else {
        ApiChecker.checkApi(apiResponse);
      }
      notifyListeners();

    }else{
      if(_isLoading) {
        _isLoading = false;
      }
    }
  }

  void emptyReplyText() {
    reviewReplyController.text = '';
  }


  Future<void> sendReviewReply (BuildContext context, int reviewId, int productId, String replyText, bool formProduct) async{
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await reviewServiceInterface.sendReviewReply(reviewId, replyText);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(formProduct){
        getProductWiseReviewList(Get.context!, 1, productId);
      } else{
        getReviewList(Get.context!);
      }
      _isLoading = false;
      showCustomSnackBarWidget(getTranslated('reply_added_successfully', Get.context!), Get.context!, isError: false);
      Navigator.of(Get.context!).pop();
    }else{
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setAllFieldSelected(bool value, {bool isUpdate = true}) {
    _allFieldSelected = value;
    if(isUpdate){
      notifyListeners();
    }
  }

  void resetReviewData() {
    _startDate = null;
    _endDate = null;
    _reviewStatusIndex = 0;
    _selectedProductId = 0;
    _reviewStatusName = 'select_status';
    selectedProductName = 'Select Product';
    Provider.of<CustomerController>(Get.context!, listen: false).resetCustomerId(isUpdate: true);
    Provider.of<CartController>(Get.context!, listen: false).emptyCustomerTextField();
    notifyListeners();
  }


}