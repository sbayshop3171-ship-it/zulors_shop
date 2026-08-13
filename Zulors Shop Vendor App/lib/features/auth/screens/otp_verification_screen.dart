import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/auth/enums/from_page.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/auth/widgets/reset_password_widget.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class VerificationScreen extends StatelessWidget {
  final String mobileNumber;
  final String? session;

  const VerificationScreen(this.mobileNumber,  {super.key, this.session});

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =  Provider.of<SplashController>(context, listen: false).configModel!;

    return Scaffold(
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: SizedBox( width: 1170,
                child: Consumer<AuthController>(
                  builder: (context, authProvider, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 55),
                      Image.asset(Images.logo, width: 100, height: 100,),
                      const SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Center(child: Text('${getTranslated('please_enter_4_digit_code', context)}\n$mobileNumber',
                          textAlign: TextAlign.center, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeButton),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 35),
                        child: PinCodeTextField(
                          length: 6,
                          appContext: context,
                          obscureText: false,
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          textStyle: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeExtraLarge),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 55,
                            fieldWidth: 50,
                            borderWidth: 1,
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: ColorHelper.darken(Theme.of(context).colorScheme.secondary, 0.2),
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Theme.of(context).cardColor,
                            inactiveColor: ColorHelper.darken(Theme.of(context).colorScheme.secondary, 0.2),
                            activeColor: ColorHelper.darken(Theme.of(context).colorScheme.secondary, 0.1),
                            activeFillColor: Theme.of(context).cardColor,
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          enableActiveFill: true,
                          onChanged: authProvider.updateVerificationCode,
                          beforeTextPaste: (text) {
                            return true;
                          },
                        ),
                      ),

                      Center(child: Text(getTranslated('i_didnt_receive_the_code', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),

                      Consumer<AuthController>(
                        builder: (context, authProvider,_) {
                          return Center(
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                Provider.of<AuthController>(context, listen: false).forgotPassword(mobileNumber, true, configModel, fromPage: FromPage.verification).then((value) {
                                  if (value!.isSuccess) {
                                    showCustomSnackBarWidget('Resent code successful', Get.context!, isError: false,  sanckBarType: SnackBarType.success);
                                  } else {
                                    showCustomSnackBarWidget(value.message, Get.context!);
                                  }
                                });
                             },
                             child: authProvider.resendButtonLoading ? SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 1)) : Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              child: Text(getTranslated('resend_code', context)!, style: TextStyle(color: Theme.of(context).primaryColor))
                             ),
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 48),

                      (authProvider.isEnableVerificationCode) ? !authProvider.isPhoneNumberVerificationButtonLoading ?
                        authProvider.resendButtonLoading ? SizedBox() :
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: CustomButtonWidget(
                          btnTxt: getTranslated('verify', context),

                          onTap: () {
                            bool phoneVerification = Provider.of<SplashController>(context,listen: false).
                            configModel!.forgotPasswordVerification =='phone';

                            bool firebaseVerification = Provider.of<SplashController>(context,listen: false).
                            configModel!.vendorForgotPasswordSmsMethod == 'firebase';

                            if(phoneVerification) {
                              if(firebaseVerification) {
                                authProvider.firebaseOtpVerification(phoneNumber: mobileNumber, session: session ?? '', otp: authProvider.verificationCode);
                              } else {
                                Provider.of<AuthController>(context, listen: false).verifyOtp(mobileNumber).then((value) {
                                  if(value.isSuccess) {
                                    Navigator.pushAndRemoveUntil(
                                      Get.context!, MaterialPageRoute(
                                      builder: (_) => ResetPasswordWidget(
                                        mobileNumber: mobileNumber,
                                        otp: authProvider.verificationCode,
                                      )
                                    ), (route) => false);
                                  } else {
                                    showCustomSnackBarWidget(getTranslated('input_valid_otp', Get.context!), Get.context!,  sanckBarType: SnackBarType.error);
                                  }
                                });
                              }
                            }

                          },
                        ),
                      ) : Center(child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)))
                        : const SizedBox.shrink()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
