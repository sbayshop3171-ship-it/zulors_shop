import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/vat_management/domain/repositories/vat_repository_interface.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';

class VatRepository implements VatRepositoryInterface{
  final DioClient? dioClient;
  VatRepository({required this.dioClient});

  @override
  Future<ApiResponse> getVatReport(int? limit, int? offset, String? startDate, String? endDate) async {
    String url = '${AppConstants.getVatTaxReportList}?limit=$limit&offset=$offset';

    if (startDate != null && endDate != null && startDate != 'null' && endDate != 'null') {
      url += '&start_date=$startDate&end_date=$endDate';
    }

    try {
      final response = await dioClient!.get(url);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future add(value) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }
  
  
  
}