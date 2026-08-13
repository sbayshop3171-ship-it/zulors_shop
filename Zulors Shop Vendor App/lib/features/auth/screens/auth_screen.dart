import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/auth/screens/login_screen.dart';



class AuthScreen extends StatelessWidget{
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthController>(context, listen: false).isActiveRememberMe;
    return Scaffold(
      body: Consumer<AuthController>(
        builder: (context, auth, child) {
          return SingleChildScrollView(
            child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  Align(alignment: Alignment.topCenter,
                    child: Padding(
                      padding:  EdgeInsets.only(top : MediaQuery.of(context).size.height/12,
                      bottom: 38),
                      child: Column( children: [
                          Hero( tag: 'logo',
                              child: Padding(
                                padding: const EdgeInsets.only(top : Dimensions.paddingSizeExtraLarge),
                                child: Image.asset(Images.logo,width: 80),
                              )),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(getTranslated('seller', context)!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLargeTwenty, color: Theme.of(context).textTheme.bodyLarge?.color)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(getTranslated('app', context)!,
                                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeExtraLargeTwenty)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],),

                Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Text(getTranslated('login', context)!,
                    style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeOverlarge, color: Theme.of(context).textTheme.bodyLarge?.color))),

                Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
                  child: Text(getTranslated('manage_your_business_from_app', context)!,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                const LoginScreen()

              ],
            ),
          );
        }
      ),
    );
  }
}



