import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_details_model.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/features/refund/domain/services/refund_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';

class RefundController extends ChangeNotifier {
  final RefundServiceInterface refundServiceInterface;
  RefundController({required this.refundServiceInterface});


  List<RefundModel>? _refundList;
  List<RefundModel>? get refundList => _refundList ?? _refundList;

  List<RefundModel>? _pendingList;
  List<RefundModel>? _approvedList;
  List<RefundModel>? _deniedList;
  List<RefundModel>? _doneList;

  List<RefundModel>? get pendingList => _pendingList ?? _pendingList;
  List<RefundModel>? get approvedList => _approvedList ?? _approvedList;
  List<RefundModel>? get deniedList => _deniedList ?? _deniedList;
  List<RefundModel>? get doneList => _doneList ?? _doneList;

  RefundModel? _refundModel;
  RefundModel? get refundModel => _refundModel;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _refundTypeIndex = 0;
  int get refundTypeIndex => _refundTypeIndex;

  final List<String> _refundStatusList = [];
  String _refundStatusType = '';
  List<String> get refundStatusList => _refundStatusList;
  String get refundStatusType => _refundStatusType;

  RefundDetailsModel? _refundDetailsModel;
  RefundDetailsModel? get refundDetailsModel => _refundDetailsModel;
  final bool _isSendButtonActive = false;
  bool get isSendButtonActive => _isSendButtonActive;
  final bool _adminReplied = true;
  bool get adminReplied => _adminReplied;

  bool _showRejectButton = false;
  bool get showRejectButton => _showRejectButton;




  Future<ApiResponse> updateRefundStatus(BuildContext context,int? id, String status, String note) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse;
    apiResponse = await refundServiceInterface.refundStatus(id, status, note);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBarWidget(getTranslated('successfully_updated_refund_status', Get.context!), Get.context!,isError: false);
      _isLoading = false;
      if(status == 'approved'){
        _refundTypeIndex = 1;
      } else if(status == 'rejected') {
        _refundTypeIndex = 2;
      }
    } else {
      Navigator.of(Get.context!).pop();
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }


  Future<ApiResponse> getRefundReqInfo(BuildContext context, int? orderDetailId) async {
    _isLoading = true;

    ApiResponse apiResponse = await refundServiceInterface.getRefundReqDetails(orderDetailId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _refundDetailsModel = RefundDetailsModel.fromJson(apiResponse.response!.data);

      if(refundDetailsModel?.refundRequest != null && refundDetailsModel!.refundRequest!.isNotEmpty) {
        setShowResetButton(refundDetailsModel?.refundRequest![0].refundStatus);
      }
      _isLoading = false;
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  Future<void> getRefundList(BuildContext context, {bool isReload = false}) async {
    if(isReload) {
      _refundList = null;
      _pendingList = null;
      _approvedList = null;
      _deniedList = null;
      _doneList = null;

      notifyListeners();
    }

    ApiResponse apiResponse = await refundServiceInterface.getRefundList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _refundList = [];
      _pendingList = [];
      _approvedList = [];
      _deniedList = [];
      _doneList = [];
      apiResponse.response!.data.forEach((refund) {

        RefundModel refundModel = RefundModel.fromJson(refund);
        _refundList!.add(refundModel);
        if (refundModel.status == AppConstants.pending) {
          _pendingList!.add(refundModel);
        } else if (refundModel.status == AppConstants.approved) {
          _approvedList!.add(refundModel);
        }else if (refundModel.status == AppConstants.rejected) {
          _deniedList!.add(refundModel);
        }else if (refundModel.status == AppConstants.done) {
          _doneList!.add(refundModel);
        }
      });
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }


  void setIndex(int index) {
    _refundTypeIndex = index;
    notifyListeners();
  }

  void updateStatus(String value) {
    _refundStatusType = value;
    notifyListeners();
  }

  void setShowResetButton(List<RefundStatus>? refundStatus) {
    List<RefundStatus>? status = refundStatus;

    String changeBy = '';
    for(RefundStatus action in status!){
      if(action.changeBy == 'admin'){
        changeBy = 'admin';
        _showRejectButton = false;
      }
    }

    if(changeBy != 'admin'){
      _showRejectButton = true;
    }
  }

  void setInitialResetButton() {
    _showRejectButton = false;
  }

  void emptyRefundModel() {
    _refundModel = null;
  }


  Future<ApiResponse> getSingleRefundModel(BuildContext context, int? refundId) async {
    _isLoading = true;

    ApiResponse apiResponse = await refundServiceInterface.getSingleRefundModel(refundId);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _refundModel = RefundModel.fromJson(apiResponse.response!.data);
      _isLoading = false;
    } else {
      _isLoading = false;
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  void emptyRefundDetailsModel() {
    _refundDetailsModel = null;
  }

}
