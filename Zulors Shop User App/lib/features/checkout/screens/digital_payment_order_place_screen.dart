import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/features/checkout/controllers/checkout_controller.dart';
import 'package:zulors_shop/features/checkout/widgets/order_place_bottomsheet_widget.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/main.dart';
import 'package:zulors_shop/utill/app_constants.dart';
import 'package:zulors_shop/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:zulors_shop/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:provider/provider.dart';

class DigitalPaymentScreen extends StatefulWidget {
  final String url;
  final bool fromWallet;
  const DigitalPaymentScreen({super.key, required this.url,  this.fromWallet = false});

  @override
  DigitalPaymentScreenState createState() => DigitalPaymentScreenState();
}

class DigitalPaymentScreenState extends State<DigitalPaymentScreen> {
  String? selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;

  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  bool _allowExitAction = true;

  @override
  void initState() {
    super.initState();
    selectedUrl = widget.url;
    _initData();
  }

  void _initData() async {
    browser = MyInAppBrowser(
      context,
      onStartRedirect: () {
        _allowExitAction = false;
      },
    );

    final settings = InAppBrowserClassSettings(
      browserSettings: InAppBrowserSettings(hideUrlBar: false),
      webViewSettings: InAppWebViewSettings(javaScriptEnabled: true, isInspectable: kDebugMode, useShouldOverrideUrlLoading: false, useOnLoadResource: false),
    );

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl ?? '')),
      settings: settings,
    );

  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (val, _) => _exitApp(context),
      child: Scaffold(
        appBar: AppBar(title: const Text(''),backgroundColor: Theme.of(context).cardColor),
        body: Column(crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,children: [
            _isLoading ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))) : const SizedBox.shrink()
          ]
        )
      ),
    );
  }


  Future<void> _exitApp(BuildContext context) async {

    if(!_allowExitAction) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);

      showAnimatedDialog(
        context,
        OrderPlaceDialogWidget(
          icon: Icons.clear,
          title: getTranslated('payment_cancelled', context),
          description: getTranslated('your_payment_cancelled', context),
          isFailed: true,
        ),
        dismissible: false,
        willFlip: true,
      );
    });
  }

}



class MyInAppBrowser extends InAppBrowser {
  final BuildContext context;
  final VoidCallback onStartRedirect;

  MyInAppBrowser(this.context,  {
    required this.onStartRedirect,
    super.windowId,
    super.initialUserScripts,
  });

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    bool isNewUser = getIsNewUser(url.toString());
    String? orderIds = getOrderIds(url.toString());
    _pageRedirect(url.toString(), isNewUser, orderIds: orderIds);
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    bool isNewUser = getIsNewUser(url.toString());
    _pageRedirect(url.toString(), isNewUser);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }


  bool getIsNewUser(String url) {
    List<String> parts = url.split('?');
    if (parts.length < 2) {
      return false;
    }



    String queryString = parts[1];
    List<String> queryParams = queryString.split('&');


    for (String param in queryParams) {
      List<String> keyValue = param.split('=');
      if (keyValue.length == 2) {
        if (keyValue[0] == 'new_user') {
          return keyValue[1] == '1';
        }
      }
    }
    return false;
  }


  String? getOrderIds(String url) {
    String orderIds = '';


    List<String> parts = url.split('?');
    if (parts.length < 2) {
      return null;
    }


    String queryString = parts[1];
    List<String> queryParams = queryString.split('&');


    for (String param in queryParams) {
      List<String> keyValue = param.split('=');
      if (keyValue.length == 2) {
        String key = keyValue[0];
        String value = Uri.decodeComponent(keyValue[1]); // decode %3D safely

        if (key == 'order_ids') {
          try {
            // Decode from base64
            String decoded = utf8.decode(base64.decode(value));

            // Handle empty or invalid decoded value
            if (decoded.trim().isEmpty || decoded == '[]') {
              debugPrint('⚠️ order_ids is empty');
              return '';
            }

            // Extract IDs safely
            String orderIds = Provider.of<CheckoutController>(context, listen: false).extractId(decoded) ?? '';

            debugPrint('✅ Decoded order IDs: $orderIds');
            return orderIds;
          } catch (e) {
            debugPrint('❌ Error decoding order_ids: $e');
            return '';
          }
        }
      }
    }
    return '';
  }


  @override
  void onExit() {
    if(_canRedirect) {
      _canRedirect = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');

        Future.delayed(Duration(milliseconds: 300), () {
          showAnimatedDialog(Get.context!, OrderPlaceDialogWidget(
            icon: Icons.clear,
            title: getTranslated('payment_failed', Get.context!),
            description: getTranslated('your_payment_failed', Get.context!),
            isFailed: true,
          ), dismissible: false, willFlip: true);
        });

      });
    }

    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    if (kDebugMode) {
      print("\n\nOverride ${navigationAction.request.url}\n\n");
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }


  @override
  void onCloseWindow() {
    onExit();
  }

  void _pageRedirect(String url, bool isNewUser, {String? orderIds}) {
    if (_canRedirect) {
      final isSuccess = url.contains('success') && url.contains(AppConstants.baseUrl);
      final isFailed = url.contains('fail') && url.contains(AppConstants.baseUrl);
      final isCancel = url.contains('cancel') && url.contains(AppConstants.baseUrl);

      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }
      bool isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();


      if(isSuccess) {
        if(isLoggedIn && orderIds != null && orderIds.isNotEmpty) {
          String? orderId = Provider.of<CheckoutController>(context, listen: false).getFirstOrderId(orderIds);
          RouterHelper.getOrderScreenRoute(isBackButtonExist: true, action: RouteAction.push, fromPlaceOrder: true);
        } else {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          onStartRedirect();

          Future.delayed(Duration(milliseconds: 300), () {
            showModalBottomSheet(
              isDismissible: false,
              enableDrag: false,
              context: Get.context!,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: OrderPlaceBottomSheetWidget(
                    orderID: orderIds,
                    icon: Icons.check,
                    title: getTranslated(
                      isNewUser
                          ? 'order_placed_Account_Created'
                          : 'order_placed',
                      Get.context!,
                    ),
                    description: getTranslated('your_order_placed', Get.context!),
                    isFailed: false,
                  ),
                );
              },
            );
          });
        });

      } else if (isFailed || isCancel) {
        final icon = isSuccess ? Icons.done : Icons.clear;
        final title = getTranslated(
          isSuccess
              ? (isNewUser ? 'order_placed_Account_Created' : 'order_placed')
              : isFailed
              ? 'payment_failed'
              : 'payment_cancelled',
          context,
        );
        final description = getTranslated(
          isSuccess
              ? 'your_order_placed'
              : isFailed
              ? 'your_payment_failed'
              : 'your_payment_cancelled',
          context,
        );
        final isDialogFailed = !isSuccess;


        WidgetsBinding.instance.addPostFrameCallback((_) {
          onStartRedirect();

          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');

          Future.delayed(Duration(milliseconds: 300), () {
            showAnimatedDialog(
              Get.context!,
              OrderPlaceDialogWidget(
                icon: icon,
                title: title,
                description: description,
                isFailed: isDialogFailed,
              ),
              dismissible: false,
              willFlip: true,
            );
          });

        });

      }
    }
  }
}