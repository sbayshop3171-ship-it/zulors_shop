import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/shipping/controllers/shipping_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/bank_info/screens/bank_info_screen.dart';
import 'package:zulors_shop_vendor/features/menu/widgets/sign_out_confirmation_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/settings/screens/order_wise_shipping_list_screen.dart';
import 'package:zulors_shop_vendor/features/settings/screens/setting_screen.dart';
import 'package:zulors_shop_vendor/features/shipping/screens/category_wise_shipping_screen.dart';
import 'package:zulors_shop_vendor/features/shipping/widgets/product_wise_shipping_widget.dart';

class ThemeChangerWidget extends StatelessWidget {
  const ThemeChangerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: ThemeShadow.getShadow(context),),
        height : Dimensions.profileCardHeight,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,),
          child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [SizedBox(width: Dimensions.iconSizeDefault, height: Dimensions.iconSizeDefault,
                child: Image.asset(Images.dark)),
              const SizedBox(width: Dimensions.paddingSizeSmall,),

              Text(!Provider.of<ThemeController>(context).darkTheme?
              '${getTranslated('dark_theme', context)}':'${getTranslated('light_theme', context)}',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const Expanded(child: SizedBox()),

              FlutterSwitch(width: 50.0, height: 28.0, toggleSize: 20.0,
                value: !Provider.of<ThemeController>(context).darkTheme,
                borderRadius: 20.0,
                activeColor: Theme.of(context).primaryColor.withValues(alpha:.5),
                padding: 3.0,
                activeIcon: Image.asset(Images.darkMode, width: 30,height: 30, fit: BoxFit.scaleDown),
                inactiveIcon: Image.asset(Images.lightMode, width: 30,height: 30,fit: BoxFit.scaleDown,),
                onToggle:(bool isActive) =>Provider.of<ThemeController>(context, listen: false).toggleTheme(),
              ),
            ],),
        ),
      ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

        Provider.of<SplashController>(context, listen: false).configModel!.shippingMethod == 'sellerwise_shipping'?
        SectionItemWidget(icon: Images.box, title: 'shipping_method',
          onTap: (){
          if(Provider.of<ShippingController>(context, listen: false).selectedShippingType == "category_wise"){
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoryWiseShippingScreen()));
          }else if(Provider.of<ShippingController>(context, listen: false).selectedShippingType == "order_wise"){
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderWiseShippingScreen()));
          }else{
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductWiseShippingWidget()));
          }},
        ):const SizedBox(),


        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

        SectionItemWidget(icon: Images.editProfile, title: 'settings',
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>const SettingsScreen()));
          },),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

        SectionItemWidget(icon: Images.bankCard, title: 'bank_info',
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> const BankInfoScreen()));
          },),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

        SectionItemWidget(icon: Images.delete, title: 'delete_account',
            onTap: () => showAnimatedDialogWidget(context, const SignOutConfirmationDialogWidget(isDelete: true), isFlip: true),),

      ],
    );
  }
}

class SectionItemWidget extends StatelessWidget {
  final String? icon;
  final String? title;
  final Function? onTap;
  const SectionItemWidget({super.key, this.onTap, this.icon, this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: ThemeShadow.getShadow(context)),
        height: Dimensions.profileCardHeight,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Row(children: [SizedBox(width: Dimensions.iconSizeDefault, height: Dimensions.iconSizeDefault,
              child: Image.asset(icon!)),
            const SizedBox(width: Dimensions.paddingSizeSmall,),

            Expanded(child: Text(getTranslated(title, context)!,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),),

            SizedBox(width: Dimensions.iconSizeDefault,
                child: Icon(Icons.arrow_forward_ios,color: Theme.of(context).primaryColor,size: Dimensions.iconSizeDefault,))
          ],),
        ),
      ),
    );
  }
}
