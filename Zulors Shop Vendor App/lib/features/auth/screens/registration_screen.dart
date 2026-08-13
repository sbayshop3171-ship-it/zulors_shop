import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/features/auth/domain/models/register_model.dart';
import 'package:zulors_shop_vendor/features/auth/screens/auth_screen.dart';
import 'package:zulors_shop_vendor/features/auth/widgets/info_field_widget.dart';
import 'package:zulors_shop_vendor/features/auth/widgets/register_successfull_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/email_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with TickerProviderStateMixin{
  TabController? _tabController;
  int selectedIndex = 0;

  AuthController authController =  Provider.of<AuthController>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Provider.of<AuthController>(context, listen: false).setIndexForTabBar(1, isNotify: false);

    _tabController?.addListener((){
      switch (_tabController!.index){
        case 0:
          Provider.of<AuthController>(context, listen: false).setIndexForTabBar(1, isNotify: true);
          break;
        case 1:
          Provider.of<AuthController>(context, listen: false).setIndexForTabBar(0, isNotify: true);
          break;
      }
    });
    Provider.of<AuthController>(Get.context!, listen: false).setCountryDialCode(CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel!.countryCode ?? '+880').dialCode);
    Provider.of<AuthController>(Get.context!, listen: false).emptyRegistrationData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if(didPop) {
          return;
        } else{
          if(_tabController?.index == 1) {
            _tabController?.index = 0;
            Provider.of<AuthController>(Get.context!, listen: false).setIndexForTabBar(1);
          }else if (Navigator.of(Get.context!).canPop()){
            Navigator.of(context).pop();
          }else {
            Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
          }
        }
      },

      child: Scaffold(
        appBar: CustomAppBarWidget(title: getTranslated('shop_application', context), isBackButtonExist: true,
          onBackPressed: () {
            if(_tabController?.index == 1) {
              _tabController?.index = 0;
              Provider.of<AuthController>(Get.context!, listen: false).setIndexForTabBar(1);
            }else if (Navigator.of(Get.context!).canPop()){
              Navigator.of(context).pop();
            }else {
              Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
            }
          },
        ),

        body: Consumer<AuthController>(
          builder: (authContext,authController, _) {
            return Column( children: [

              const SizedBox(height: Dimensions.paddingSizeSmall,),
              Expanded(child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: const [
                  InfoFieldVIewWidget(),
                  InfoFieldVIewWidget(isShopInfo: true,),
                ],
              )),


            ]);
          }
        ),

        bottomNavigationBar: Consumer<AuthController>(
            builder: (context, authController, _) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                  // LinearPercentIndicator(
                  //   width: MediaQuery.of(context).size.width,
                  //   lineHeight: 4.0,
                  //   percent: authController.selectionTabIndex == 1 ? 0.5 : 0.9,
                  //   backgroundColor: Theme.of(context).hintColor,
                  //   progressColor: Theme.of(context).colorScheme.onPrimary,
                  // ),

                authController.isLoading? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ) :
                  Container(height: 70,
                    padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor
                    ),
                    child:(authController.selectionTabIndex ==1) ?
                    CustomButtonWidget(btnTxt: getTranslated('proceed_to_next', context), onTap: (){
                      if(authController.emailController.text.trim().isEmpty) {
                        showCustomSnackBarWidget(getTranslated('email_is_required', context), context,  sanckBarType: SnackBarType.warning);
                      }
                      else if (EmailChecker.isNotValid(authController.emailController.text.trim())) {
                        showCustomSnackBarWidget(getTranslated('email_is_ot_valid', context), context,  sanckBarType: SnackBarType.warning);
                      }else if(authController.phoneController.text.trim().isEmpty){
                        showCustomSnackBarWidget(getTranslated('phone_is_required', context), context,  sanckBarType: SnackBarType.warning);
                      }
                      else if(authController.phoneController.text.trim().length<8){
                        showCustomSnackBarWidget(getTranslated('phone_number_is_not_valid', context), context,  sanckBarType: SnackBarType.warning);
                      }else if(authController.passwordController.text.trim().isEmpty){
                        showCustomSnackBarWidget(getTranslated('password_is_required', context), context,  sanckBarType: SnackBarType.warning);
                      }
                      else if(authController.passwordController.text.trim().length<8){
                        showCustomSnackBarWidget(getTranslated('password_minimum_length_is_6', context), context,  sanckBarType: SnackBarType.warning);
                      }
                      else if(authController.confirmPasswordController.text.trim().isEmpty){
                        showCustomSnackBarWidget(getTranslated('confirm_password_is_required', context), context,  sanckBarType: SnackBarType.warning);
                      }else if(authController.passwordController.text.trim() != authController.confirmPasswordController.text.trim()){
                        showCustomSnackBarWidget(getTranslated('password_is_mismatch', context), context,  sanckBarType: SnackBarType.warning);
                      } else if (authController.passwordController.text.trim().isNotEmpty && !authController.isPasswordValid()) {
                        showCustomSnackBarWidget(getTranslated('enter_valid_password', context), context, sanckBarType: SnackBarType.warning);
                      } else{
                        _tabController!.animateTo((_tabController!.index + 1) % 2);
                        selectedIndex = _tabController!.index + 1;
                        authController.setIndexForTabBar(selectedIndex);
                      }
                    }):

                    Row(children: [
                        // SizedBox(width: 120,
                        //   child: CustomButtonWidget(btnTxt: getTranslated('back', context),
                        //     backgroundColor: Theme.of(context).hintColor,
                        //     isColor: true,
                        //     onTap: (){
                        //     _tabController!.animateTo((_tabController!.index + 1) % 2);
                        //     selectedIndex = _tabController!.index + 1;
                        //     authController.setIndexForTabBar(selectedIndex);
                        //   },),
                        // ),
                        // const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(
                          child: CustomButtonWidget(
                            backgroundColor: !authController.isTermsAndCondition!? Theme.of(context).hintColor: Theme.of(context).primaryColor,
                            btnTxt: getTranslated('submit', context), onTap: !authController.isTermsAndCondition!? null: () async {
                            if(authController.firstNameController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('first_name_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.lastNameController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('last_name_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.firstNameController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('first_name_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.lastNameController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('last_name_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.sellerProfileImage == null){
                              showCustomSnackBarWidget(getTranslated('profile_image_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.emailController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('email_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            } else if (EmailChecker.isNotValid(authController.emailController.text.trim())) {
                              showCustomSnackBarWidget(getTranslated('email_is_ot_valid', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.phoneController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('phone_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            } else if(authController.phoneController.text.trim().length<8){
                              showCustomSnackBarWidget(getTranslated('phone_number_is_not_valid', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.passwordController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('password_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            } else if(authController.passwordController.text.trim().length<8){
                              showCustomSnackBarWidget(getTranslated('password_minimum_length_is_6', context), context,  sanckBarType: SnackBarType.warning);
                            } else if(authController.confirmPasswordController.text.trim().isEmpty){
                              showCustomSnackBarWidget(getTranslated('confirm_password_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.passwordController.text.trim() != authController.confirmPasswordController.text.trim()){
                              showCustomSnackBarWidget(getTranslated('password_is_mismatch', context), context,  sanckBarType: SnackBarType.warning);
                            }
                            else if(authController.shopNameController.text.trim().isEmpty){
                            showCustomSnackBarWidget(getTranslated('shop_name_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.shopAddressController.text.trim().isEmpty){
                            showCustomSnackBarWidget(getTranslated('shop_address_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.shopLogo == null){
                            showCustomSnackBarWidget(getTranslated('shop_logo_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.shopBanner == null){
                            showCustomSnackBarWidget(getTranslated('shop_banner_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(authController.secondaryBanner == null && Provider.of<SplashController>(context,listen: false).configModel!.activeTheme != "default"){
                              showCustomSnackBarWidget(getTranslated('secondary_banner_is_required', context), context,  sanckBarType: SnackBarType.warning);
                            }else if(Provider.of<ShopController>(context, listen: false).tinCertificateFile != null && (( await Provider.of<ShopController>(context, listen: false).tinCertificateFile?.length() ?? 0) > (2 * 1024 * 1024)) ) {
                              showCustomSnackBarWidget(getTranslated('single_file_size_can_not_be_more_than', Get.context!), Get.context!,  sanckBarType: SnackBarType.warning);
                            } else {
                              RegisterModel registerModel =  RegisterModel(
                                fName: authController.firstNameController.text.trim(),
                                lName: authController.lastNameController.text.trim(),
                                phone: "${authController.countryDialCode}${authController.phoneController.text.trim()}",
                                email: authController.emailController.text.trim(),
                                password: authController.passwordController.text.trim(),
                                confirmPassword: authController.confirmPasswordController.text.trim(),
                                shopName: authController.shopNameController.text.trim(),
                                shopAddress: authController.shopAddressController.text.trim(),
                                businessTin: authController.tinNumberController.text.trim(),
                                tinExpireDate: Provider.of<ShopController>(Get.context!, listen: false).tinExpireDate?.toString(),
                              );
                              authController.registration(Get.context!, registerModel, Provider.of<ShopController>(Get.context!, listen: false).tinCertificateFile).then((value){
                                if(value.response!.statusCode == 200){
                                  showCupertinoModalPopup( context: Get.context!,
                                    barrierDismissible: false,
                                    builder: (_) => const RegisterSuccessfulWidget());
                                }
                              });
                            }
                          }),

                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }
}

