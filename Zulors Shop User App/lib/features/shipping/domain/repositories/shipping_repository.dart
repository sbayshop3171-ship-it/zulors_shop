import 'dart:developer';
import 'package:zulors_shop/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/features/shipping/domain/repositories/shipping_repository_interface.dart';
import 'package:zulors_shop/main.dart';
import 'package:zulors_shop/utill/app_constants.dart';
import 'package:provider/provider.dart';

class ShippingRepository implements ShippingRepositoryInterface{
  final DioClient? dioClient;
  ShippingRepository({required this.dioClient});



  @override
  Future<ApiResponseModel> getShippingMethod(int? sellerId, String? type) async {
    try {
      final response = await dioClient!.get('${AppConstants.getShippingMethod}/$sellerId/$type');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponseModel> addShippingMethod(int? id, String? cartGroupId) async {
    log('===>${{"id":id, "cart_group_id": cartGroupId}}');
    try {
      final response = await dioClient!.post(AppConstants.chooseShippingMethod,
          data: {"id":id, 'guest_id' : Provider.of<AuthController>(Get.context!, listen: false).getGuestToken(),
            "cart_group_id": cartGroupId});
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getChosenShippingMethod() async {
    try {
      final response =await dioClient!.get('${AppConstants.chosenShippingMethod}?guest_id=${Provider.of<AuthController>(Get.context!, listen: false).getGuestToken()}');
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
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
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }


  @override
  Future getList({int? offset}) {
    // TODO: implement getList
    throw UnimplementedError();
  }

  @override
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }
}