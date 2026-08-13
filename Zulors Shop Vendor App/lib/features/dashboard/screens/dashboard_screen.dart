import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/transaction/controllers/transaction_controller.dart';
import 'package:zulors_shop_vendor/features/wallet/controllers/wallet_controller.dart';
import 'package:zulors_shop_vendor/helper/network_info.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/home/screens/home_page_screen.dart';
import 'package:zulors_shop_vendor/features/menu/widgets/menu_widget.dart';
import 'package:zulors_shop_vendor/features/order/screens/order_screen.dart';
import 'package:zulors_shop_vendor/features/refund/screens/refund_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US'?
    'en':Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    Provider.of<ProfileController>(context, listen: false).getSellerInfo();
    Provider.of<DigitalProductController>(context, listen: false).getDigitalAuthor();
    Provider.of<DigitalProductController>(context, listen: false).getPublishingHouse();
    Provider.of<CategoryController>(context,listen: false).getCategoryList(context, null, languageCode);
    Provider.of<CartController>(context,listen: false).getCartData();
    Provider.of<ShopController>(context, listen: false).getShopInfo();

    Provider.of<TransactionController>(context, listen: false).getTransactionList(context,'all','','');
    Provider.of<WalletController>(context, listen: false).getPaymentInfoList();

    if(Provider.of<SplashController>(context,listen: false).configModel?.isAiFeatureActive == 1) {
      Provider.of<AiController>(context,listen: false).generateLimitCheck();
    }

    _screens = [
      HomePageScreen(callback: () {
        setState(() {
          setPage(1);
        });
      }),

      const OrderScreen(),
      const RefundScreen(fromNotification: false),
    ];

    NetworkInfo.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (_pageIndex != 0) {
          setPage(0);
        } else {
          _onWillPop(context);
        }
        if(didPop) return;
      },

      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).hintColor,
          selectedFontSize: Dimensions.fontSizeSmall,
          unselectedFontSize: Dimensions.fontSizeSmall,
          selectedLabelStyle: robotoBold,
          showUnselectedLabels: true,
          currentIndex: _pageIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            _barItem(Images.home, getTranslated('home', context), 0),
            _barItem(Images.order, getTranslated('my_order', context), 1),
            _barItem(Images.refund, getTranslated('refund', context), 2),
            _barItem(Images.menu, getTranslated('menu', context), 3)
          ],
          onTap: (int index) {
            if (index != 3) {
              setState(() {
                setPage(index);
              });
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (con) => const MenuBottomSheetWidget()
              );
            }
          },
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(String icon, String? label, int index) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom : Dimensions.paddingSizeExtraSmall),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(width: index == _pageIndex ? Dimensions.iconSizeLarge : Dimensions.iconSizeMedium,
              child: Image.asset(icon, color: index == _pageIndex ?
              Theme.of(context).primaryColor : Theme.of(context).hintColor)
            ),
          ],
        ),
      ),
      label: label,
    );
  }

  void setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }


  Future<bool> _onWillPop(BuildContext context) async {
    showAnimatedDialogWidget(context,  ConfirmationDialogWidget(icon: Images.logOut,
      title: getTranslated('exit_app', context),
      description: getTranslated('do_you_want_to_exit_the_app', context),
      onYesPressed: (){
        SystemNavigator.pop();
      },
    ), isFlip: true);

    return true;
  }

}
