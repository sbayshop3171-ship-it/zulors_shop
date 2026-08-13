import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/more/screens/html_view_screen.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/business_pages_model.dart';
import 'package:zulors_shop_vendor/helper/email_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/auth/screens/registration_screen.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/auth/screens/forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();

    if(_emailController == null) {
      _emailController = TextEditingController();
      _passwordController = TextEditingController();
    }

    if(!Provider.of<AuthController>(context, listen: false).isUnAuthorize) {
      _emailController!.text = (Provider.of<AuthController>(context, listen: false).getUserEmail());
      _passwordController!.text = (Provider.of<AuthController>(context, listen: false).getUserPassword());
      Provider.of<AuthController>(Get.context!,listen: false).setUnAuthorize(true, update: false);
    }
  }

  @override
  void dispose() {
    _emailController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Provider.of<AuthController>(context, listen: false).isActiveRememberMe;

    return Consumer<AuthController>(
      builder: (context, authProvider, child) => Form(
        key: _formKeyLogin,
        child: Padding( padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: SingleChildScrollView(
            child: Column( children: [

                Container(margin: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeSmall),
                  child: CustomTextFieldWidget(
                    border: true,
                    prefixIconImage: Images.emailIcon,
                    hintText: getTranslated('enter_email_address', context),
                    focusNode: _emailFocus,
                    nextNode: _passwordFocus,
                    textInputType: TextInputType.emailAddress,
                    controller: _emailController)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Container(margin: const EdgeInsets.only(left: Dimensions.paddingSizeLarge,
                  right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeDefault),
                  child: CustomTextFieldWidget(
                    border: true,
                    isPassword: true,
                    prefixIconImage: Images.lock,
                    hintText: getTranslated('password_hint', context),
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.done,
                    controller: _passwordController,
                  )),

                Container( margin: const EdgeInsets.only(left: 24, right: Dimensions.paddingSizeLarge),
                  child: Consumer<AuthController>(
                    builder: (context, authProvider, child) => Row(
                      children: [

                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () => authProvider.toggleRememberMe(),
                          child: Row(mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: Dimensions.iconSizeDefault, height: Dimensions.iconSizeDefault,
                                decoration: BoxDecoration(color: authProvider.isActiveRememberMe ?
                                Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                    border: Border.all(color:  authProvider.isActiveRememberMe ?
                                    Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha:.5)),
                                    borderRadius: BorderRadius.circular(3)),
                                child: authProvider.isActiveRememberMe ?
                                Icon(Icons.done, color: Theme.of(context).colorScheme.secondaryContainer,
                                    size: Dimensions.iconSizeSmall) : const SizedBox.shrink(),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(getTranslated('remember_me', context)!,
                                style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor),
                           )]),
                        ),

                        const Spacer(),

                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                          child: Text(getTranslated('forget_password', context)!,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).primaryColor, decoration: TextDecoration.underline)))
                      ])
                  )),
                const SizedBox(height: Dimensions.paddingSizeButton),

                !authProvider.isLoading ?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: CustomButtonWidget(
                    borderRadius: 100,
                    backgroundColor: Theme.of(context).primaryColor,
                    btnTxt: getTranslated('login', context),
                    onTap: () async {
                      String email = _emailController!.text.trim();
                      String password = _passwordController!.text.trim();
                      if (email.isEmpty) {
                        showCustomSnackBarWidget(getTranslated('enter_email_address', context), context,  sanckBarType: SnackBarType.warning);
                      }else if (EmailChecker.isNotValid(email)) {
                        showCustomSnackBarWidget(getTranslated('enter_valid_email', context), context,  sanckBarType: SnackBarType.warning);
                      }else if (password.isEmpty) {
                        showCustomSnackBarWidget(getTranslated('enter_password', context), context,  sanckBarType: SnackBarType.warning);
                      }else if (password.length < 6) {
                        showCustomSnackBarWidget(getTranslated('password_should_be', context), context,  sanckBarType: SnackBarType.warning);
                      }else {authProvider.login(context, emailAddress: email, password: password).then((status) async {
                          if (status.response?.statusCode == 200) {
                            if (authProvider.isActiveRememberMe) {
                              authProvider.saveUserNumberAndPassword(email, password);
                            } else {
                              authProvider.clearUserEmailAndPassword();
                            }
                           // Navigator.of(Get.context!).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
                            Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
                          }else {
                          }
                        });
                      }
                  },
                  ),
                ) :
                Center( child: CircularProgressIndicator( valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),)),

                Provider.of<SplashController>(context, listen: false).configModel!.sellerRegistration == "1"?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistrationScreen()));
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getTranslated('dont_have_an_account', context)!,style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(getTranslated('registration_here', context)!,
                            style: robotoTitleRegular.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                ): const SizedBox(),

              Consumer<SplashController>(
                builder: (context, splashController, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical:Dimensions.paddingSizeBottomSpace),
                      child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_) => HtmlViewScreen(
                              page : getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages),
                            )));
                          },
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(getTranslated('terms_and_condition', context)!,
                                  style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline)),
                            ],
                          )),
                    );
                  }
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  BusinessPageModel? getPageBySlug(String slug, List<BusinessPageModel>? pagesList) {
    BusinessPageModel? pageModel;
    if(pagesList != null && pagesList.isNotEmpty){
      for (var page in pagesList) {
        if(page.slug == slug) {
          pageModel = page;
        }
      }
    }
    return pageModel;
  }

}
