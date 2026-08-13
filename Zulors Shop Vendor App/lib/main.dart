import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/barcode/controllers/barcode_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/dashboard/widgets/custom_tutorial_dialog.dart';
import 'package:zulors_shop_vendor/features/notification/controllers/notification_controller.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/barcode_scan_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/coupon_discount_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/customer_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/widgets/cookies_widget.dart';
import 'package:zulors_shop_vendor/features/product_details/controllers/product_details_controller.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/features/vat_management/controllers/vat_controller.dart';
import 'package:zulors_shop_vendor/features/wallet/controllers/wallet_controller.dart';
import 'package:zulors_shop_vendor/localization/app_localization.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/settings/controllers/business_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop_vendor/features/coupon/controllers/coupon_controller.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/features/emergency_contract/controllers/emergency_contact_controller.dart';
import 'package:zulors_shop_vendor/features/language/controllers/language_controller.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:zulors_shop_vendor/features/order/controllers/location_controller.dart';
import 'package:zulors_shop_vendor/features/order/controllers/order_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/review/controllers/product_review_controller.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/shipping/controllers/shipping_controller.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/notification/models/notification_body.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/features/bank_info/controllers/bank_info_controller.dart';
import 'package:zulors_shop_vendor/features/transaction/controllers/transaction_controller.dart';
import 'package:zulors_shop_vendor/theme/dark_theme.dart';
import 'package:zulors_shop_vendor/theme/light_theme.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/features/splash/screens/splash_screen.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'di_container.dart' as di;
import 'notification/my_notification.dart';
import 'package:zulors_shop_vendor/common/controller/show_bottom_sheet_controller.dart';
import 'package:zulors_shop_vendor/common/controller/tutorial_controller.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(Firebase.apps.isEmpty){
    if(Platform.isAndroid){
      try{
        ///todo you need to configure that firebase Option with your own firebase to run your app
        await Firebase.initializeApp(
          name: 'project_name_here',
          options: const FirebaseOptions(
              apiKey: "current_key here",
              projectId: "project_id here",
              messagingSenderId: "project_number here",
              appId: "mobilesdk_app_id here"
          )
        );
      } catch(_) {
        await Firebase.initializeApp();
      }
    }else {
      await Firebase.initializeApp();
    }
  }
  await FlutterDownloader.initialize(debug: true , ignoreSsl: true);
  await di.init();


  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  NotificationBody? body;

  try {
    final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      body = NotificationBody.fromJson(remoteMessage.data);
    }
  } catch(e) {
    if (kDebugMode) {
      print(e);
    }
  }

  await MyNotification.initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => di.sl<ThemeController>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LanguageController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocalizationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShopController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BankInfoController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ChatController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BusinessController>()),
      ChangeNotifierProvider(create: (context) => di.sl<TransactionController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductReviewController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShippingController>()),
      ChangeNotifierProvider(create: (context) => di.sl<DeliveryManController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RefundController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BottomMenuController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CartController>()),
      ChangeNotifierProvider(create: (context) => di.sl<EmergencyContactController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponController>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<NotificationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<WalletController>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductDetailsController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BarcodeController>()),
      ChangeNotifierProvider(create: (context) => di.sl<RestockController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ClearanceSaleController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CustomerController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponDiscountController>()),
      ChangeNotifierProvider(create: (context) => di.sl<BarcodeScanController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddProductImageController>()),
      ChangeNotifierProvider(create: (context) => di.sl<VariationController>()),
      ChangeNotifierProvider(create: (context) => di.sl<DigitalProductController>()),
      ChangeNotifierProvider(create: (context) => di.sl<CategoryController>()),
      ChangeNotifierProvider(create: (context) => di.sl<ShowBottomSheetController>()),
      ChangeNotifierProvider(create: (context) => di.sl<TutorialController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AddProductTaxController>()),
      ChangeNotifierProvider(create: (context) => di.sl<VatController>()),
      ChangeNotifierProvider(create: (context) => di.sl<AiController>())
    ],

    child: _GlobalScrollListener(
      child: MyApp(body: body)
    ),
  ));
}

class MyApp extends StatelessWidget {
  final NotificationBody? body;
  const MyApp({super.key, this.body});

  @override
  Widget build(BuildContext context) {
    final bool isLtr  = Provider.of<LocalizationController>(context, listen: false).isLtr;

    List<Locale> locals = [];
    for (var language in AppConstants.languages) {
      locals.add(Locale(language.languageCode!, language.countryCode));
    }

    return MaterialApp(
      navigatorObservers: [_BottomSheetObserver(context: context)],
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: Provider.of<ThemeController>(context).darkTheme ? dark : light,
      locale: Provider.of<LocalizationController>(context).locale,
      builder:(context,child) {
        return Consumer<ShopController>(
          builder: (context, shopController, _) {
            return Consumer<ProductController>(
                builder: (context, productController, _) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                    child: Stack(children: [
                      SafeArea(top: false, child: child!),


                      if(Provider.of<AuthController>(context, listen: false).isLoggedIn() && shopController.shopModel != null &&
                        (100 != (shopController.shopModel?.setupGuideApp?.values.where((v) => v == 1).length ?? 0) / (shopController.shopModel?.setupGuideApp?.length ?? 0) * 100))
                        Selector<ShowBottomSheetController, bool>(
                          selector: (_, provider) => provider.isBottomSheetOpen,
                          builder: (_, isBottomSheetOpen, __) {
                            return  (!isBottomSheetOpen || TutorialDialogController().isDialogOpen) ? Positioned.fill(
                              child: Align(alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: Platform.isIOS ? 130 : 100, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault),
                                  child: GestureDetector(
                                    onTap: () {
                                      TutorialDialogController().show(context);
                                    },
                                    child: Stack(
                                      children: [
                                        Selector<TutorialController, bool>(
                                          selector: (_, provider) => provider.isVisible,
                                          builder: (_, isVisible, __) {
                                            return isVisible ? Container(
                                              margin: EdgeInsets.only(
                                                top: Dimensions.radiusDefault,
                                                right: isLtr ? Dimensions.radiusDefault : 0,
                                                left: isLtr ? 0 : Dimensions.radiusDefault
                                              ),
                                              height: 50, width: 50,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(TutorialDialogController().isDialogOpen && isLtr ? Dimensions.radiusDefault : 0),
                                                  topLeft: Radius.circular(TutorialDialogController().isDialogOpen && isLtr ? 0 : Dimensions.radiusDefault),
                                                  bottomLeft: const Radius.circular(Dimensions.radiusDefault),
                                                  bottomRight: const Radius.circular(Dimensions.radiusDefault),
                                                ),
                                                boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 3, spreadRadius: 1)],
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(Dimensions.paddingSize),
                                                child: CustomAssetImageWidget(Images.tutorialFlowIcon, width: 20, height: 20)
                                              ),
                                            ) : const SizedBox();
                                          }
                                        ) ,

                                        if((Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp?.length ?? 0) > 0)
                                          Positioned(
                                            top: 0,
                                            right: isLtr ? 0 : null,
                                            left: isLtr ? null : 0,
                                            child: const Material(color: Colors.transparent, child: TutorialCountWidget()),
                                          ),
                                      ],
                                    )
                                  )
                                )
                              ),
                            ) : const SizedBox();
                          }
                        ),

                      if((productController.stockLimitStatus != null
                          && Provider.of<AuthController>(context, listen: false).isLoggedIn()
                          && productController.showCookies
                          && !productController.isShowCookies()
                          && (productController.stockLimitStatus?.productCount ?? 0) < 0))
                        const Positioned.fill(child: Align(alignment: Alignment.bottomCenter, child: CookiesWidget())),


                    ]),
                  );
                }
            );
          }
        );
      },
      localizationsDelegates: const [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: locals,
      home: SplashScreen(body: body),
    );
  }
}
class Get {
  static BuildContext? get context => navigatorKey.currentContext;
  static NavigatorState? get navigator => navigatorKey.currentState;
}

class TutorialDialogController {
  static final TutorialDialogController _instance = TutorialDialogController._internal();
  factory TutorialDialogController() => _instance;
  TutorialDialogController._internal();

  bool _isDialogOpen = false;
  bool get isDialogOpen => _isDialogOpen;

  Future<void> show(BuildContext context) async {
    if (_isDialogOpen) return;

    _isDialogOpen = true;

    await showDialog(
      context: Get.context!,
      useRootNavigator: true,
      barrierColor: Colors.black54,
      builder: (_) => const CustomTutorialDialog(),
    );

    _isDialogOpen = false;
  }

  void close(BuildContext context) {
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }
}


class _GlobalScrollListener extends StatelessWidget {
  final Widget child;

  const _GlobalScrollListener({required this.child});

  @override
  Widget build(BuildContext context) {
    bool isUserScrolling = false;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {

        if(TutorialDialogController().isDialogOpen) {
          return false;
        }

        final tutorialController = Provider.of<TutorialController>(context, listen: false);

        if (notification is ScrollStartNotification) {
          tutorialController.setVisibility(false);

        }else if (notification is ScrollEndNotification) {
          tutorialController.setVisibility(true);
        }

        if (notification is UserScrollNotification) {
          isUserScrolling = notification.direction != ScrollDirection.idle;
        }

        if(notification.metrics.pixels >= notification.metrics.maxScrollExtent && isUserScrolling) {
          tutorialController.setVisibility(false);
        }

        return false;
      },
      child: child,
    );
  }
}


class _BottomSheetObserver extends NavigatorObserver {
  final BuildContext context;
  final Set<Route> _activeOverlayRoutes = {};

  _BottomSheetObserver({required this.context});

  bool _isOverlay(Route route) =>
      route is ModalBottomSheetRoute || route is DialogRoute;

  void _updateState() {
    final hasActiveOverlay = _activeOverlayRoutes.isNotEmpty;
    final controller = Provider.of<ShowBottomSheetController>(context, listen: false);
    hasActiveOverlay ? controller.openBottomSheet() : controller.closeBottomSheet();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (_isOverlay(route)) {
      _activeOverlayRoutes.add(route);
      _updateState();
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (_isOverlay(route)) {
      _activeOverlayRoutes.remove(route);
      _updateState();
    }
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (_isOverlay(route)) {
      _activeOverlayRoutes.remove(route);
      _updateState();
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (_isOverlay(oldRoute!)) _activeOverlayRoutes.remove(oldRoute);
    if (_isOverlay(newRoute!)) _activeOverlayRoutes.add(newRoute);
    _updateState();
  }
}
