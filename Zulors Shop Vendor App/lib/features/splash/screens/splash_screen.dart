import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/chat/screens/inbox_screen.dart';
import 'package:zulors_shop_vendor/features/maintenance/maintenance_screen.dart';
import 'package:zulors_shop_vendor/features/notification/screens/notification_screen.dart';
import 'package:zulors_shop_vendor/features/order_details/screens/order_details_screen.dart';
import 'package:zulors_shop_vendor/features/product/screens/product_list_screen.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/features/refund/screens/refund_details_screen.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/features/update/screen/update_screen.dart';
import 'package:zulors_shop_vendor/features/wallet/screens/wallet_screen.dart';
import 'package:zulors_shop_vendor/helper/network_info.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/notification/models/notification_body.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/auth/screens/auth_screen.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/splash/widgets/splash_painter_widget.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  const SplashScreen({super.key, this.body});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Provider.of<AuthController>(Get.context!,listen: false).setUnAuthorize(false, update: false);
    initCall();
  }

  Future<void> initCall() async {
    NetworkInfo.checkConnectivity(context);
    Provider.of<SplashController>(context, listen: false).initConfig().then((bool isSuccess) {
      if(isSuccess) {
        Provider.of<SplashController>(Get.context!, listen: false).getBusinessPagesList('default');
        Provider.of<SplashController>(Get.context!, listen: false).initShippingTypeList(Get.context!,'');
        Timer(const Duration(seconds: 1), () async {
          final config = Provider.of<SplashController>(Get.context!, listen: false).configModel;
          SellerAppVersionControl? appVersion = Provider.of<SplashController>(Get.context!, listen: false).configModel?.sellerAppVersionControl;
          String? minimumVersion = '0';

          if(Platform.isAndroid) {
            minimumVersion =  appVersion?.forAndroid?.version ?? '0';
          } else if(Platform.isIOS) {
            minimumVersion = appVersion?.forIos?.version ?? '0';
          }


          if(compareVersions(minimumVersion, AppConstants.appVersion) == 1) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const UpdateScreen()));
          } else if(config?.maintenanceModeData?.maintenanceStatus == 1 && config?.maintenanceModeData?.selectedMaintenanceSystem?.vendorApp == 1) {
            Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(
              builder: (_) => const MaintenanceScreen(),
              settings: const RouteSettings(name: 'MaintenanceScreen'),
            ));
          } else {
            if(widget.body != null) {
              String notificationType = widget.body?.type??"";

              switch(notificationType.toLowerCase()) {
                case 'chatting' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => InboxScreen(fromNotification: true, initIndex: widget.body?.messageKey ==  'message_from_delivery_man' ? 1 : 0)));
                }
                break;

                case 'theme' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => const NotificationScreen()));
                }
                break;

                case 'order' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: int.parse(widget.body!.orderId.toString()), fromNotification: true)));
                }
                break;

                case 'wallet' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => const WalletScreen(fromNotification: true)));
                }
                break;

                case 'wallet_withdraw' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => const WalletScreen(fromNotification: true)));
                }
                break;

                case 'product_request_approved_message' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => const ProductListMenuScreen(fromNotification: true)));
                }
                break;

                case 'refund' : {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) =>  RefundDetailsScreen(fromNotification: true, refundModel: RefundModel(id: widget.body!.refundId), orderDetailsId: widget.body!.orderDetailsId)));
                }
                break;

                default: {
                  Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (context) => const NotificationScreen()));
                } break;
              }

            } else {
              if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
                await Provider.of<AuthController>(context, listen: false).updateToken(context);
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()));
              } else {
                Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const AuthScreen()));
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          clipBehavior: Clip.none, children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CustomPaint(
              painter: SplashPainterWidget(),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                    tag:'logo',
                    child: Image.asset(Images.whiteLogo, height: 80.0,
                        fit: BoxFit.cover, width: 80.0)),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                Text(AppConstants.appName, style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeWallet,
                    color: Colors.white),
                ),
              ],
            ),
          ),
        ],
        )
    );
  }

  int compareVersions(String version1, String version2) {
    List<String> v1Components = version1.split('.');
    List<String> v2Components = version2.split('.');

    int maxLength = v1Components.length > v2Components.length
        ? v1Components.length
        : v2Components.length;

    for (int i = 0; i < maxLength; i++) {
      int v1Part = i < v1Components.length ? int.tryParse(v1Components[i]) ?? 0 : 0;
      int v2Part = i < v2Components.length ? int.tryParse(v2Components[i]) ?? 0 : 0;

      if (v1Part > v2Part) return 1;
      if (v1Part < v2Part) return -1;
    }

    return 0;
  }


}
