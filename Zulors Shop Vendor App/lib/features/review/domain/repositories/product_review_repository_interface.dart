

import 'package:zulors_shop_vendor/data/model/response/base/api_response.dart';
import 'package:zulors_shop_vendor/interface/repository_interface.dart';

abstract class ProductReviewRepositoryInterface implements RepositoryInterface{
  Future<ApiResponse> productReviewList();
  Future<ApiResponse> filterProductReviewList(int? productId, int? customerId, int status, String? from, String? to);
  Future<ApiResponse> searchProductReviewList(String search);
  Future<ApiResponse> reviewStatusOnOff(int? reviewId, int status);
  Future<ApiResponse> getProductWiseReviewList(int? productId,int offset);
  Future<ApiResponse> sendReviewReply(int? reviewId,String replyText);

}