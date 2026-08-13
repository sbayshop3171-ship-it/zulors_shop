import 'dart:io';
import 'package:zulors_shop_vendor/features/profile/domain/models/profile_body.dart';
import 'package:zulors_shop_vendor/features/profile/domain/models/profile_info.dart';

abstract class ProfileServiceInterface {
  Future<dynamic> getSellerInfo();
  Future<dynamic> updateProfile(ProfileInfoModel userInfoModel, ProfileBody seller,  File? file, String token, String password);
  Future<dynamic> deleteUserAccount();
}