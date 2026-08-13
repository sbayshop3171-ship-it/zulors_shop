import 'package:http/http.dart' as http;
import 'package:zulors_shop_vendor/features/profile/domain/models/profile_body.dart';
import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/features/profile/domain/models/profile_info.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class BankInfoRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> chartFilterData(String? type);
  Future<http.StreamedResponse> updateBank(ProfileInfoModel userInfoModel, ProfileBody seller, String token);
  String getBankToken();
  Future<ApiResponse> getOrderFilterData(String? type);
}