import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/datasource/remote/dio/dio_client.dart';
import 'package:zulors_shop/data/datasource/remote/exception/api_error_handler.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/data/services/data_sync_service.dart';
import 'package:zulors_shop/features/category/domain/repositories/category_repo_interface.dart';
import 'package:zulors_shop/utill/app_constants.dart';

class CategoryRepository extends DataSyncService implements CategoryRepoInterface {
  final DioClient? dioClient;
  CategoryRepository({required this.dioClient, required super.dataSyncRepoInterface});

  @override
  Future<ApiResponseModel> getList({int? offset}) async {
    try {
      final response = await dioClient!.get(
        AppConstants.categoriesUri);
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponseModel> getSellerWiseCategoryList(int sellerId) async {
    try {
      final response = await dioClient!.get('${AppConstants.sellerWiseCategoryList}$sellerId');
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
  Future get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }



  @override
  Future update(Map<String, dynamic> body, int id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source}) async {
    return await fetchData<T>('${AppConstants.categoriesUri}?guest_id=1',  source);
  }
}