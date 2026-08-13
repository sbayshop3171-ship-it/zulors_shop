

import 'dart:io';

import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/product_details/domain/repositories/product_details_repository_interface.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';

class ProductDetailsRepository implements ProductDetailsRepositoryInterface{

  final DioClient? dioClient;
  ProductDetailsRepository({required this.dioClient});

  @override
  Future<ApiResponse> getProductDetails(int? productId) async {
    try {
      final response = await dioClient!.get('${AppConstants.productDetails}$productId',
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> productStatusOnOff(int? productId, int status) async {
    try {
      final response = await dioClient!.post(AppConstants.productStatusOnOff,
          data: {
            "id": productId,
            "status": status,
            "_method":"put"
          }
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<HttpClientResponse> previewDownload(String? url) async {
    HttpClient client = HttpClient();
    final response = await client.getUrl(Uri.parse(url!)).then((HttpClientRequest request) {
      return request.close();
    },
    );
    return response;
  }


}