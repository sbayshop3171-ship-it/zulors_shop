import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/interface/repo_interface.dart';

abstract class DataSyncRepoInterface extends RepositoryInterface {
  Future<ApiResponseModel<T>> fetchData<T>(String uri, DataSourceEnum source);
}