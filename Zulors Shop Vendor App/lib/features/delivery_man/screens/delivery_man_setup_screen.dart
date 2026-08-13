import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/features/emergency_contract/screens/emergency_contact_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/screens/add_new_delivery_man_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/screens/delivery_man_list_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/screens/withdraw/withdraw_screen.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class DeliveryManSetupScreen extends StatelessWidget {
  const DeliveryManSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('delivery_man_setup', context), isBackButtonExist: true),
        body: ListView(
          children: const [
            SizedBox(height: Dimensions.paddingSizeSmall),
            DeliveryManSetupCard(title: 'delivery_man_list',icon: Images.deliveryManGroupIcon, widget: DeliveryManListScreen()),
            DeliveryManSetupCard(title: 'add_new_delivery_man',icon: Images.deliveryManIcon, widget: AddNewDeliveryManScreen()),
            DeliveryManSetupCard(title: 'delivery_withdraws',icon: Images.deliveryManWithdrawIcon, widget: DeliveryManWithdrawScreen()),
            DeliveryManSetupCard(title: 'emergency_contact_list',icon: Images.deliveryManEmergencyIcon, widget: EmergencyContactScreen()),

          ],
        ));
  }
}

class DeliveryManSetupCard extends StatelessWidget {
  final String? icon;
  final String? title;
  final Widget? widget;
  const DeliveryManSetupCard({super.key, this.icon, this.title, this.widget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.iconSizeDefault, 0, Dimensions.iconSizeDefault, Dimensions.paddingSizeMedium),
      child: GestureDetector(
        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=>widget!)),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.09), blurRadius: 1,spreadRadius: 1, offset: const Offset(1,1))]
          ),
          child: Column(children: [
            SizedBox(width: Dimensions.deliveryManIconSize,
                child: Image.asset(icon!)),
            const SizedBox(height: Dimensions.paddingSizeSmall,),
            Text(getTranslated(title, context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),)
          ],),
        ),
      ),
    );
  }
}
