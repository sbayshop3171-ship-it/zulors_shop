import 'package:flutter/material.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/features/notification/domain/models/notification_model.dart';
import 'package:zulors_shop/features/notification/domain/services/notification_service_interface.dart';
import 'package:zulors_shop/helper/api_checker.dart';

class NotificationController extends ChangeNotifier {
  final NotificationServiceInterface notificationServiceInterface;

  NotificationController({required this.notificationServiceInterface});

  NotificationItemModel? notificationModel;


  Future<void> getNotificationList(int offset) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.getList(offset : offset);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      if(offset == 1){
        notificationModel = NotificationItemModel.fromJson(apiResponse.response?.data);
      }else{
        notificationModel?.notification?.addAll(NotificationItemModel.fromJson(apiResponse.response?.data).notification!);
        notificationModel?.offset = NotificationItemModel.fromJson(apiResponse.response?.data).offset!;
        notificationModel?.totalSize = NotificationItemModel.fromJson(apiResponse.response?.data).totalSize!;
      }
    } else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
  }



  Future<void> seenNotification(int id) async {
    ApiResponseModel apiResponse = await notificationServiceInterface.seenNotification(id);
    if (apiResponse.response != null && apiResponse.response?.statusCode == 200) {
      getNotificationList(1);
    }
    notifyListeners();
  }
}
