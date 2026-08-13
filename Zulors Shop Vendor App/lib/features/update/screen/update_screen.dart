import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../main.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            Image.asset(
              color: Theme.of(context).primaryColor,
              Images.update,
              width: MediaQuery.of(context).size.height * 0.4,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            Text(
              getTranslated('update', context)!,
              style: robotoBold.copyWith(fontSize: MediaQuery.of(context).size.height * 0.023, color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            Text(
              getTranslated('your_app_is_deprecated', context)!,
              style: robotoRegular.copyWith(fontSize: MediaQuery.of(context).size.height * 0.0175, color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),

            CustomButtonWidget(btnTxt: getTranslated('update_now', context)!, onTap: () async {
              String? appUrl = 'https://google.com';
              if(Platform.isAndroid) {
                appUrl = Provider.of<SplashController>(context, listen: false).configModel?.sellerAppVersionControl?.forAndroid?.link;
              }else if(Platform.isIOS) {
                appUrl = Provider.of<SplashController>(context, listen: false).configModel?.sellerAppVersionControl?.forIos?.link;
              }

              if(appUrl?.isNotEmpty ?? false) {
                launchUrlString(appUrl!, mode: LaunchMode.externalApplication);
              }else {
                showCustomSnackBarWidget('${getTranslated('can_not_launch', Get.context!)!}  $appUrl', Get.context!);
              }

            }),
          ]),
        ),
      ),
    );
  }
}
