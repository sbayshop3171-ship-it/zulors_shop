import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/number_checker_healper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_dialog_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/auth/widgets/my_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/auth/screens/otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? _countryCode;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final FocusNode _numberFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _countryCode = CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel!.countryCode!).dialCode;
    Provider.of<AuthController>(context,listen: false).setCountryDialCode(_countryCode);

  }


  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel =  Provider.of<SplashController>(context, listen: false).configModel!;

    return Scaffold(
      appBar: CustomAppBarWidget(isBackButtonExist: true,title: getTranslated('forget_password', context),),

      body: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: SingleChildScrollView(
          child: Column( crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 95),

              Image.asset(Images.forgotPasswordIcon, height: 100, width: 100),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Text('${getTranslated('forget_password', context)}?', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              ),

              Provider.of<SplashController>(context,listen: false).configModel!.forgotPasswordVerification == "phone"?
              Text(getTranslated('enter_phone_number_for_password_reset', context)!,
                  style: titilliumRegular.copyWith(color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeExtraSmall)):
              Text(getTranslated('enter_email_for_password_reset', context)!,
                  style: titilliumRegular.copyWith(color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Provider.of<SplashController>(context,listen: false).configModel!.forgotPasswordVerification == "phone" ?

              Consumer<AuthController>(
                builder: (context, authProvider,_) {
                  return CustomTextFieldWidget(
                    border: true,
                    hintText: getTranslated('number_hint', context),
                    controller: _numberController,
                    focusNode: _numberFocus,
                    isPhoneNumber: true,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.phone,
                    showCodePicker: true,
                    countryDialCode: _countryCode,
                    onCountryChanged: (CountryCode countryCode) {
                      _countryCode = countryCode.dialCode!;
                      authProvider.setCountryDialCode(countryCode.dialCode!);
                    },
                  );
                }
              ) :
              CustomTextFieldWidget(
                border: true,
                prefixIconImage: Images.emailIcon,
                controller: _controller,
                hintText: getTranslated('ENTER_YOUR_EMAIL', context),
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.emailAddress,),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Consumer<AuthController>(
                builder: (context, authProvider, _) {
                  return !authProvider.isLoading ?
                  CustomButtonWidget( borderRadius: 10,
                    btnTxt: Provider.of<SplashController>(context,listen: false).configModel!.forgotPasswordVerification == "phone"?
                    getTranslated('send_otp', context):getTranslated('send_email', context),
                    onTap: () {
                      if(Provider.of<SplashController>(context,listen: false).configModel!.forgotPasswordVerification == "phone") {

                        bool isNumber = NumberCheckerHelper.isNumber((_countryCode ?? '') + _numberController.text);

                        if(_numberController.text.isEmpty) {
                          showCustomSnackBarWidget(getTranslated('PHONE_MUST_BE_REQUIRED', context), context, sanckBarType: SnackBarType.warning);
                        }
                        else{
                          authProvider.forgotPassword((_countryCode ?? '') + _numberController.text.trim(), isNumber, configModel).then((value) {
                            if(value != null) {
                              if(value.isSuccess) {
                                Navigator.push(Get.context!, MaterialPageRoute(builder: (_) => VerificationScreen((_countryCode ?? '') +_numberController.text.trim())));
                              } else {
                                showCustomSnackBarWidget(getTranslated('input_valid_phone_number', Get.context!), Get.context!,  sanckBarType: SnackBarType.warning);
                              }
                            }

                          });
                        }


                      } else {
                        if(_controller.text.isEmpty) {
                          showCustomSnackBarWidget(getTranslated('EMAIL_MUST_BE_REQUIRED', context), context,  sanckBarType: SnackBarType.warning);
                        }
                        else {
                          Provider.of<AuthController>(context, listen: false).forgotPassword(_controller.text, false, configModel).then((value) {
                            if(value != null && value.isSuccess) {
                              FocusScopeNode currentFocus = FocusScope.of(Get.context!);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              _controller.clear();
                              showAnimatedDialogWidget(Get.context!, MyDialogWidget(
                                icon: Icons.send,
                                title: getTranslated('sent', Get.context!),
                                description: getTranslated('recovery_link_sent', Get.context!),
                                rotateAngle: 5.5,
                              ), dismissible: false);
                            }else if (value != null) {
                              showCustomSnackBarWidget(value.message, Get.context!,  sanckBarType: SnackBarType.success);
                            }
                          });
                        }
                      }
                    },
                  ) :
                  Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)));
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}

