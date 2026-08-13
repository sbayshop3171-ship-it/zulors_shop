
import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/model/api_response.dart';

abstract class CategoryServiceInterface {

  Future<dynamic> getSellerWiseCategoryList(int sellerId);
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source});


}