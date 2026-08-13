import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/auth/screens/login_screen.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/maintenance/maintenance_screen.dart';
import 'package:zulors_shop_vendor/features/product/screens/product_list_screen.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/features/refund/screens/refund_details_screen.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/features/wallet/screens/wallet_screen.dart';
import 'package:zulors_shop_vendor/notification/models/notification_body.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/features/chat/screens/inbox_screen.dart';
import 'package:zulors_shop_vendor/features/notification/screens/notification_screen.dart';
import 'package:zulors_shop_vendor/features/order_details/screens/order_details_screen.dart';

import '../main.dart';

class MyNotification {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse data) async {



      try{
        NotificationBody payload;
        if(data.payload != null && data.payload!.isNotEmpty) {
          payload = NotificationBody.fromJson(jsonDecode(data.payload!));
          if(payload.type == 'chatting'){
            Get.navigator!.push(MaterialPageRoute(builder: (context) => InboxScreen(fromNotification: true, initIndex: payload.messageKey ==  'message_from_delivery_man' ? 1 : 0)));
          } else if(payload.type == 'Theme'){
            Get.navigator!.push(MaterialPageRoute(builder: (context) => const NotificationScreen( )));
          } else if(payload.orderId != null && payload.type != 'refund'){
            Get.navigator!.push(MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: payload.orderId, fromNotification: true)));
          } else if(payload.type  == 'wallet_withdraw'){
            Get.navigator!.push(MaterialPageRoute(builder: (context) => const WalletScreen(fromNotification: true)));
          } else if(payload.type == 'product_request_approved_message'){
            Get.navigator!.push(MaterialPageRoute(builder: (context) => const ProductListMenuScreen(fromNotification: true)));
          }else if(payload.type == 'refund'){
            Get.navigator!.push(MaterialPageRoute(builder: (context) => RefundDetailsScreen(fromNotification: true, refundModel: RefundModel(id: payload.refundId), orderDetailsId: payload.orderDetailsId)));
          }
        }
      }catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint("onMessage: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
      }
      if(message.notification!.title!.contains('chatting')){
        //Get.navigator!.push(MaterialPageRoute(builder: (context) => const InboxScreen( )));
      }else if(message.notification!.title!.contains('Theme')){
        Get.navigator!.push(MaterialPageRoute(builder: (context) => const NotificationScreen( )));
      }


      if(message.data['type'] == 'maintenance_mode') {
        final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
        await splashProvider.initConfig();

        ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;

        bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

        debugPrint("--------(NOTIFICATION HELPER)-----------${Provider.of<SplashController>(Get.context!, listen: false).isMaintenanceModeScreen()}-------");

        if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.vendorApp == 1)) {
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => const MaintenanceScreen(),
            settings: const RouteSettings(name: 'MaintenanceScreen'),
          ));
        }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
          final AuthController authController = Provider.of<AuthController>(Get.context!, listen: false);
          if(authController.isLoggedIn()) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
          } else {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
          }
        }
      }

      if(message.data['type'] != 'maintenance_mode') {
        showNotification(message, flutterLocalNotificationsPlugin, false);
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)  async {
      if (kDebugMode) {
        debugPrint("onOpenApp: ${message.notification!.title}/${message.toMap()}/${message.notification!.titleLocKey}");
      }
      NotificationBody? payload;
      if(message.data.isNotEmpty) {
        payload = NotificationBody.fromJson(message.data);
      }
      if(message.notification!.title!.contains('chatting')){
        Get.navigator!.push(MaterialPageRoute(builder: (context) => InboxScreen(fromNotification: true, initIndex: payload?.messageKey ==  'message_from_delivery_man' ? 1 : 0)));

      } else if(message.notification!.title!.contains('Theme')){
        Get.navigator!.push(MaterialPageRoute(builder: (context) => const NotificationScreen( )));
      } else if (message.notification!.title!.contains('Order') && payload != null && payload.orderId != null && payload.type != 'refund') {
        Get.navigator!.push(
          MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: int.parse(payload!.orderId.toString()), fromNotification: true)));
      } else if(payload?.type == 'wallet_withdraw'){
        Get.navigator!.push(MaterialPageRoute(builder: (context) => const WalletScreen(fromNotification: true)));
      } else if(payload?.type == 'product_request_approved_message'){
        Get.navigator!.push(MaterialPageRoute(builder: (context) => const ProductListMenuScreen(fromNotification: true)));
      }else if(payload?.type == 'refund'){
        Get.navigator!.push(MaterialPageRoute(builder: (context) => RefundDetailsScreen(fromNotification: true, refundModel: RefundModel(id: payload?.refundId), orderDetailsId: payload?.orderDetailsId)));
      }
      try{
        if(message.notification!.titleLocKey != null && message.notification!.titleLocKey!.isNotEmpty) {
          Get.navigator!.push(
              MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: int.parse(message.notification!.titleLocKey!), fromNotification: true,)));
        }
      }catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }


      if(message.data['type'] == 'maintenance_mode') {
        final SplashController splashProvider = Provider.of<SplashController>(Get.context!,listen: false);
        await splashProvider.initConfig();

        ConfigModel? config = Provider.of<SplashController>(Get.context!,listen: false).configModel;

        bool isMaintenanceRoute = Provider.of<SplashController>(Get.context!,listen: false).isMaintenanceModeScreen();

        debugPrint("--------(NOTIFICATION HELPER)-----------${Provider.of<SplashController>(Get.context!, listen: false).isMaintenanceModeScreen()}-------");

        if(config?.maintenanceModeData?.maintenanceStatus == 1 && (config?.maintenanceModeData?.selectedMaintenanceSystem?.vendorApp == 1)) {
          Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
            builder: (_) => const MaintenanceScreen(),
            settings: const RouteSettings(name: 'MaintenanceScreen'),
          ));
        }else if (config?.maintenanceModeData?.maintenanceStatus == 0 && isMaintenanceRoute) {
          final AuthController authController = Provider.of<AuthController>(Get.context!, listen: false);
          if(authController.isLoggedIn()) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
          } else {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
          }
        }
      }

    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    String? title;
    String? body;
    String? image;
    title = message.data['title'];
    body = message.data['body'];
    image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;


    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, message.data, image, fln);
      }catch(e) {
        await showBigTextNotification(title, body!, message.data, fln);
      }
    }else {
      await showBigTextNotification(title, body!, message.data, fln);
    }
  }


  static Future<void> showBigTextNotification(String? title, String body, Map<String, dynamic> data, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: jsonEncode(data));
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, Map<String, dynamic> data, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: jsonEncode(data));
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Response response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    final File file = File(filePath);
    await file.writeAsBytes(response.data);
    return filePath;
  }

}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint("onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.body}");
  }
}