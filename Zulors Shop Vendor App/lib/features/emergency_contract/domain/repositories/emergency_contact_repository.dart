
import 'package:flutter/foundation.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/emergency_contract/domain/repositories/emergency_contract_repository_interface.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';


class EmergencyContactRepository implements EmergencyContractRepositoryInterface{
  final DioClient? dioClient;
  EmergencyContactRepository({required this.dioClient});

  @override
  Future<ApiResponse> addNewEmergencyContact(String name, String phone,int? id, {bool isUpdate = false}) async {
    try {
      if (kDebugMode) {
        print('==id=$id, name=$name, phone = $phone, isUpdate=$isUpdate');
      }
      final response = await dioClient!.post(isUpdate? AppConstants.emergencyContactUpdate : AppConstants.emergencyContactAdd,
          data: {
            'id': id,
            'name' : name,
            'phone' : phone,
            '_method' : isUpdate? 'put' :'post'


          });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> statusOnOffEmergencyContact(int? id, int status) async {
    try {
      final response = await dioClient!.post(AppConstants.emergencyContactStatusOnOff,
          data: {'_method': 'put',
            'id' : id,
            'status' : status
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
  Future delete(int id) async{
    try {
      final response = await dioClient!.post(AppConstants.emergencyContactDelete, data: {
        '_method': 'delete',
        'id' : id
      });
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future getList({int? offset = 1}) async{
    try {
      final response = await dioClient!.get(AppConstants.getEmergencyContactList);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> getEmergencyContactListSearch(String key) async{
    try {
      final response = await dioClient!.get('${AppConstants.getEmergencyContactList}?search=$key');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }

}