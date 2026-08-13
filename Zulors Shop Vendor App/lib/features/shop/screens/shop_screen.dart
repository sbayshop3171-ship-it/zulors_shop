import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/shop/screens/other_setup_screen.dart';
import 'package:zulors_shop_vendor/features/shop/screens/payment_info_screen.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/my_shop_appbar.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_details_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_loader_widget.dart';

import '../../../main.dart';

class ShopScreen extends StatefulWidget {
  final int? tabIndex;
  const ShopScreen({super.key, this.tabIndex});

  @override
  ShopScreenState createState() => ShopScreenState();
}

class ShopScreenState extends State<ShopScreen> {
  String sellerId = '0';
  TextEditingController vacationNote = TextEditingController();
  bool freeDeliveryOver = false;
  TextEditingController minimumOrderAmountController = TextEditingController();
  TextEditingController freeDeliveryOverAmountController = TextEditingController();
  bool freeDeliveryOn = false;

  ShopController shopController = Provider.of<ShopController>(Get.context!, listen: false);


  @override
  void initState() {
    if(widget.tabIndex != null || widget.tabIndex != 0) {
      shopController.setShopPageIndex(widget.tabIndex ?? 0, isUpdate: false);
    }
    Provider.of<ShopController>(context, listen: false).getPaymentWithdrawalMethodList();
    freeDeliveryOn = Provider.of<ProfileController>(context, listen: false).userInfoModel?.freeOverDeliveryAmountStatus == 1;
    minimumOrderAmountController.text = Provider.of<ProfileController>(context, listen: false).userInfoModel!.minimumOrderAmount.toString();
    freeDeliveryOverAmountController.text = Provider.of<ProfileController>(context, listen: false).userInfoModel!.freeOverDeliveryAmount.toString();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Provider.of<ShopController>(context, listen: false).selectedIndex;
    sellerId = Provider.of<ProfileController>(context, listen: false).userInfoModel!.id.toString();
    Provider.of<ShopController>(context, listen: false).getShopInfo();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final navigator = Navigator.of(Get.context!);

        if(shopController.myShopPageIndex != 0) {
          shopController.setShopPageIndex(0, isUpdate: true);
        }else if (navigator.canPop()){
          Future.microtask(() {
            Navigator.of(Get.context!).pop();
          });
        }else{
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
          });
        }
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: MyShopAppBar(title: getTranslated('my_shop', context)),
          body: RefreshIndicator(
            onRefresh: () async{
              Provider.of<SplashController>(context, listen: false).initConfig();
            },
            child: Consumer<ShopController>(
                builder: (context, shopInfo, child) {
                  return shopInfo.shopModel != null?
                  Consumer<ProfileController>(
                    builder: (context, profileProvider,_) {
                      return Consumer<SplashController>(
                        builder: (context, splashProvider,_) {
                          return shopInfo.myShopPageIndex == 0 ?
                            const ShopDetailsWidget() :
                            shopInfo.myShopPageIndex == 1 ?
                            const PaymentInfoScreen() :
                            const OtherSetupScreen();
                        }
                      );
                    }
                  ):const CustomLoaderWidget();
                }),
          ),
      ),
    );
  }
}

class ShopSettingWidget extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool? mode;
  final Function(bool value)? onTap;
  final Function()? onPress;
  final bool dateSelection;
  const ShopSettingWidget({super.key, this.title, this.icon, this.mode, this.onTap, this.dateSelection = false, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
      builder: (context, shop,_) {
        return Container(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.125))),
          child: Row(children: [
            Expanded(child: Text(getTranslated(title, context)!,style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),)),
            dateSelection?
            InkWell(onTap: onPress ,
              child: Container(decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor, width: .25),
                  borderRadius: BorderRadius.circular(50)),
                child: Padding(padding: const EdgeInsets.all(8.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text((shop.shopModel != null && shop.shopModel!.vacationStartDate != null) ? shop.shopModel!.vacationStartDate!:'${getTranslated('start_date', context)}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Icon(Icons.arrow_forward_rounded,size: Dimensions.iconSizeDefault,
                            color:  Theme.of(context).primaryColor)),
                      Text((shop.shopModel != null && shop.shopModel!.vacationEndDate != null)? shop.shopModel!.vacationEndDate! : '${getTranslated("end_date", context)}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ],
                  ),
                ),
              ),
            ):
            FlutterSwitch(
              value: mode!,
              width: 50,
              height: 27,
              activeColor: Theme.of(context).primaryColor,
              toggleSize: 20,
              padding: 2,
              onToggle: onTap!)

          ],),
        );
      }
    );
  }
}
