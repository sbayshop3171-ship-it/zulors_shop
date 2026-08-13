import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/interface/repo_interface.dart';

abstract class CategoryRepoInterface extends RepositoryInterface{
  Future<dynamic> getSellerWiseCategoryList(int sellerId);

  Future<ApiResponseModel<T>> getCategoryList<T>({required DataSourceEnum source});


}