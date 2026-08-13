
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class BarcodeRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> barCodeDownLoad(int? id, int quantity);
}