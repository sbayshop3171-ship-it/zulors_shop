import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/features/category/domain/repositories/category_repo_interface.dart';
import 'package:zulors_shop/features/category/domain/services/category_service_interface.dart';

class CategoryService implements CategoryServiceInterface{
  CategoryRepoInterface categoryRepoInterface;
  CategoryService({required this.categoryRepoInterface});

  @override
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source}) async{
    return await categoryRepoInterface.getCategoryList(source: source);
  }

  @override
  Future getSellerWiseCategoryList(int sellerId) async{
    return await categoryRepoInterface.getSellerWiseCategoryList(sellerId);
  }

}