import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/auth/screens/auth_screen.dart';

class RegisterSuccessfulWidget extends StatelessWidget {
  const RegisterSuccessfulWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall))),
        child: SizedBox(height: 250,width: 270,child: Stack(children: [

          Column(mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 40,),
              Padding( padding: const EdgeInsets.only(bottom : Dimensions.paddingSizeDefault),
                child: SizedBox(width: 50,child: Image.asset(Images.successIcon)),
              ),
              Text(getTranslated('shop_register_message1', context)!,style: robotoRegular,),
              Padding( padding: const EdgeInsets.all(8.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(getTranslated('been_sent', context)!,style: robotoRegular),
                    Padding( padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(getTranslated('successfully', context)!,style: robotoMedium.copyWith(color: Colors.green[600])),
                    ),
                    Text(getTranslated('to_admin', context)!,style: robotoRegular),
                  ],
                ),
              ),
              Padding(
                padding:  const EdgeInsets.symmetric(horizontal : 20),
                child: Text(getTranslated('shop_register_message2', context)!,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), textAlign: TextAlign.center,),
              ),
            ]),

          Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
            },
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: SizedBox(width: 18,child: Image.asset(Images.cross)),
            ),
          ),
        ),
      ],
    )));
  }
}
