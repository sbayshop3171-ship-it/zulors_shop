import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/model/api_response.dart';

abstract class FeaturedDealServiceInterface {
  Future<ApiResponseModel<T>> getFeaturedDeal<T>({required DataSourceEnum source});
}
