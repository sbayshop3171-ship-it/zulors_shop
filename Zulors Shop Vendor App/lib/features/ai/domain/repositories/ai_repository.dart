import 'package:dio/dio.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop_vendor/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/ai/domain/repositories/ai_repository_interface.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:image_picker/image_picker.dart';

class AiRepository implements AiRepositoryInterface {
  final DioClient? dioClient;

  AiRepository({ required this.dioClient });

  @override
  Future<ApiResponse?> generateTitle({required String title, required String langCode}) async {
    try {

      Map<String,String> dta =  {
        'name' : title,
        'langCode' : langCode
      };

      final response = await dioClient?.post(
          AppConstants.productTitleGenerate,
          data: dta,
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateDescription({required String title, required String langCode}) async {
    try {
      final response = await dioClient?.post(
          AppConstants.productDescriptionGenerate,
          data: {
            'name' : title,
            'langCode' : langCode
          }
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse?> generateGeneralData({required String title,  required String description, required String langCode}) async {
    try {
      final response = await dioClient?.post(
          AppConstants.productGeneralSetupGenerate,
          data: {
            'name' : title,
            'description' : description,
            'langCode' : langCode
          }
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateTitleSuggestions({required String keywords}) async {
    try {
      final response = await dioClient?.post(
          AppConstants.productGenerateTitleGenerate,
          data: {
            'keywords' : keywords,
          }
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse?> generateFromImage({required XFile image}) async {
    try {
      MultipartFile multiPartFile = MultipartFile.fromBytes(
        await image.readAsBytes(),
        filename: image.name
      );

      final response = await dioClient?.postMultipart(
        AppConstants.productAnalyzeImageAutoGenerate,
        data: {},
        files: [MultipartWithKey(key: 'image', multipartFile: multiPartFile)]
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse?> generatePricing({required String title, required String langCode}) async {
    try {
      final response = await dioClient?.post(
          AppConstants.productPricingGenerate,
          data: {
            'name' : title,
            'description' : langCode
          }
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse?> generateVariationData({required String title,  required String description}) async {
    try {
      final response = await dioClient?.post(
        AppConstants.productVariationSetupGenerate,
        data: {
          'name' : title,
          'description' : description,
        }
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse?> generateMetaSeoData({required String title,  required String description}) async {
    try {
      final response = await dioClient?.post(
        AppConstants.productSeoSectionGenerate,
        data: {
          'name' : title,
          'description' : description,
        }
      );
      return ApiResponse.withSuccess(response!);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }


  @override
  Future<ApiResponse?> generateLimitCheck() async {
    try {
      final response = await dioClient?.get(
          AppConstants.generateLimitCheck,
      );
      return ApiResponse.withSuccess(response!);
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