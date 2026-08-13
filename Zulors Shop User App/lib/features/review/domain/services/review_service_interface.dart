import 'dart:io';
import 'package:zulors_shop/features/review/domain/models/review_body.dart';

abstract class ReviewServiceInterface{

  Future<dynamic> submitReview(ReviewBody reviewBody, List<File> files, bool update);

  Future<dynamic> get(String id);

  Future<dynamic> getOrderWiseReview(String productID, String orderId);

  Future<dynamic> deleteOrderWiseReviewImage(String id, String name);

  Future<dynamic> getDeliveryManReview(String orderId);

  Future<dynamic> submitDeliveryManReview(String orderId, String comment, String rating);

}