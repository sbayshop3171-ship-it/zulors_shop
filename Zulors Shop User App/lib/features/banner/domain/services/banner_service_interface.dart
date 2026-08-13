import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/model/api_response.dart';

abstract class BannerServiceInterface{
  Future<ApiResponseModel<T>> getList<T>({required DataSourceEnum source});

}