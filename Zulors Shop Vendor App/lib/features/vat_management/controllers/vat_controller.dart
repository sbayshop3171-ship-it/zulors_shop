import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/vat_management/domain/models/vat_report_model.dart';
import 'package:zulors_shop_vendor/features/vat_management/domain/services/vat_service_interface.dart';
import 'package:zulors_shop_vendor/helper/api_checker.dart';



class VatController extends ChangeNotifier {
  VatServiceInterface vatServiceInterface;

  VatController({required this.vatServiceInterface});


  VatReportModel?  _vatReportModel;
  VatReportModel? get vatReportModel => _vatReportModel;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;


  bool? _isLoading;
  bool? get isLoading => _isLoading;

  bool? _isFilterActive = false;
  bool? get isFilterActive => _isFilterActive;

  final DateFormat _dateFormat = DateFormat('d MMM yy');
  DateFormat get dateFormat => _dateFormat;






  Future<void> getVatReportList(int offset, {String? startDate, String? endDate}) async {
    if(offset <1 || startDate != null) {
      _isLoading = true;
      notifyListeners();
    }

    ApiResponse apiResponse = await vatServiceInterface.getVatReport(10, 1, startDate, endDate);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _vatReportModel = VatReportModel.fromJson(apiResponse.response?.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }


  void selectDate(String type, BuildContext context) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2030),
    ).then((date) async {
      date = date;
      if(date == null){
      }


      DateTime combinedDateTime = DateTime(
        date!.year,
        date.month,
        date.day,
      );

      if (type == 'start'){
        _startDate = combinedDateTime;
      }else{
        _endDate = combinedDateTime;
      }

      notifyListeners();
    });
  }


  void resetReviewData({bool isUpdate = true}) {
    _startDate = null;
    _endDate = null;
    _isFilterActive = false;

    if(isUpdate) {
      notifyListeners();
    }
  }

  void setFilterActive(bool value) {
    _isFilterActive = value;
    notifyListeners();
  }


}