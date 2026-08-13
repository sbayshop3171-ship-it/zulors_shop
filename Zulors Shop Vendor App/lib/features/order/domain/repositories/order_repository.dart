import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/order/domain/repositories/order_repository_interface.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';

class OrderRepository implements OrderRepositoryInterface{
  final DioClient? dioClient;
  OrderRepository({required this.dioClient});

  @override
  Future<ApiResponse> getOrderList(int offset, String status) async {
    try {
      final response = await dioClient!.get('${AppConstants.orderListUri}?limit=10&offset=$offset&status=$status');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse> orderAddressEdit({String? orderID, String? addressType, String? contactPersonName, String? phone, String? city, String? zip,
    String? address, String? email, String? latitude, String? longitude,
  }) async {
    try {
      final response = await dioClient!.post(AppConstants.orderAddressEdit, data: {
        "order_id": orderID,
        "contact_person_name": contactPersonName,
        "phone": phone,
        "city" : city,
        "zip" : zip,
        "email" : email,
        "address" : address,
        "latitude": latitude,
        "longitude": longitude,
        "address_type" : addressType,
      });
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
