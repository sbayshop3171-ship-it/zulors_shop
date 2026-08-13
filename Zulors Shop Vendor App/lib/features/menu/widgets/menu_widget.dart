import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/screens/clearance_sale_screen.dart';
import 'package:zulors_shop_vendor/features/restock/screens/restock_list_screen.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/business_pages_model.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/features/vat_management/screens/vat_management_screen.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_bottom_sheet_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/screens/add_product_screen.dart';
import 'package:zulors_shop_vendor/features/chat/screens/inbox_screen.dart';
import 'package:zulors_shop_vendor/features/coupon/screens/coupon_list_screen.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/nav_bar_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/screens/delivery_man_setup_screen.dart';
import 'package:zulors_shop_vendor/features/menu/widgets/sign_out_confirmation_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/more/screens/html_view_screen.dart';
import 'package:zulors_shop_vendor/features/product/screens/product_list_screen.dart';
import 'package:zulors_shop_vendor/features/profile/screens/profile_view_screen.dart';
import 'package:zulors_shop_vendor/features/review/screens/product_review_screen.dart';
import 'package:zulors_shop_vendor/features/settings/screens/setting_screen.dart';
import 'package:zulors_shop_vendor/features/shop/screens/shop_screen.dart';
import 'package:zulors_shop_vendor/features/wallet/screens/wallet_screen.dart';
import 'package:zulors_shop_vendor/features/bank_info/screens/bank_info_screen.dart';

import '../../../main.dart';

class MenuBottomSheetWidget extends StatelessWidget {
  const MenuBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;



    return Consumer<SplashController>(
      builder: (context, splashController, _) {

        List<CustomBottomSheetWidget> activateMenu = [
          CustomBottomSheetWidget(image: '${Provider.of<ProfileController>(context, listen: false).userInfoModel?.imageFullUrl?.path}',
            isProfile: true, title: getTranslated('profile', context),
            onTap: () => _handleMenuTap(context, const ProfileScreenView())
          ),

          CustomBottomSheetWidget(image: Images.myShop, title: getTranslated('my_shop', context),
            onTap: () => _handleMenuTap(context, const ShopScreen())
          ),

          CustomBottomSheetWidget(image: Images.addProduct, title: getTranslated('add_product', context),
            onTap: () => _handleMenuTap(context, const AddProductScreen()),
          ),

          CustomBottomSheetWidget(image: Images.productIconPp, title: getTranslated('products', context),
            onTap: () => _handleMenuTap(context, const ProductListMenuScreen()),
          ),

          CustomBottomSheetWidget(image: Images.reviewIcon, title: getTranslated('reviews', context),
            onTap: () => _handleMenuTap(context, const ProductReviewScreen()),
          ),

          CustomBottomSheetWidget(image: Images.couponIcon, title: getTranslated('coupons', context),
            onTap: () => _handleMenuTap(context, const CouponListScreen()),
          ),

          if(configModel?.shippingMethod == 'sellerwise_shipping')
            CustomBottomSheetWidget(image: Images.deliveryManIcon, title: getTranslated('deliveryman', context),
              onTap: () => _handleMenuTap(context, const DeliveryManSetupScreen()),
            ),


          if(configModel?.posActive == 1 && Provider.of<ProfileController>(context, listen: false).userInfoModel?.posActive == 1)
            CustomBottomSheetWidget(image: Images.pos, title: getTranslated('pos', context),
              onTap: () => _handleMenuTap(context, const NavBarScreen()),
            ),


          CustomBottomSheetWidget(image: Images.settings, title: getTranslated('settings', context),
            onTap: () => _handleMenuTap(context, const SettingsScreen()),
          ),


          CustomBottomSheetWidget(image: Images.restockIcon, title: getTranslated('restock', context),
            onTap: () => _handleMenuTap(context, const RestockListScreen()),
          ),


          CustomBottomSheetWidget(image: Images.clearanceSaleImage, title: getTranslated('clearance_sale', context),
            onTap: () => _handleMenuTap(context, const ClearanceSaleScreen()),
          ),


          CustomBottomSheetWidget(image: Images.wallet, title: getTranslated('wallet', context),
            onTap: () => _handleMenuTap(context, const WalletScreen()),
          ),


          CustomBottomSheetWidget(image: Images.message, title: getTranslated('message', context),
            onTap: () => _handleMenuTap(context, const InboxScreen()),
          ),


          CustomBottomSheetWidget(image: Images.reportIcon, title: getTranslated('vat_management', context),
            onTap: () => _handleMenuTap(context, const VatManagementScreen()),
          ),


          CustomBottomSheetWidget(image: Images.bankingInfo, title: getTranslated('bank_info', context),
            onTap: () => _handleMenuTap(context, const BankInfoScreen()),
          ),


          if(getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages) != null)
          CustomBottomSheetWidget(image: Images.termsAndCondition, title: getTranslated('terms_and_condition', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page: getPageBySlug('terms-and-conditions', splashController.defaultBusinessPages)
            )),
          ),


          if(getPageBySlug('about-us', splashController.defaultBusinessPages) != null)
          CustomBottomSheetWidget(image: Images.aboutUs, title: getTranslated('about_us', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page: getPageBySlug('about-us', splashController.defaultBusinessPages),
            )),
          ),

          if(getPageBySlug('privacy-policy', splashController.defaultBusinessPages) != null)
          CustomBottomSheetWidget(image: Images.privacyPolicy, title: getTranslated('privacy_policy', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page: getPageBySlug('privacy-policy', splashController.defaultBusinessPages),
            )),
          ),


          if(getPageBySlug('refund-policy', splashController.defaultBusinessPages) != null)
            CustomBottomSheetWidget(image: Images.refundPolicy, title: getTranslated('refund_policy', context),
            onTap : () => _handleMenuTap(context, HtmlViewScreen(
              page:getPageBySlug('refund-policy', splashController.defaultBusinessPages),
            )),
          ),


          if(getPageBySlug('return-policy', splashController.defaultBusinessPages) != null)
            CustomBottomSheetWidget(image: Images.returnPolicy, title: getTranslated('return_policy', context),
              onTap : () => _handleMenuTap(context, HtmlViewScreen(
                page: getPageBySlug('return-policy', splashController.defaultBusinessPages),
              )),
            ),


          if(getPageBySlug('cancellation-policy', splashController.defaultBusinessPages) != null)
            CustomBottomSheetWidget(image: Images.cPolicy, title: getTranslated('cancellation_policy', context),
              onTap : () => _handleMenuTap(context, HtmlViewScreen(
                page: getPageBySlug('cancellation-policy', splashController.defaultBusinessPages),
              )),
            ),


          CustomBottomSheetWidget(image: Images.logOut, title: getTranslated('logout', context),
            onTap: () async {
              Navigator.pop(context); // Close bottom sheet
              Future.microtask(
                await showCupertinoModalPopup(context: context, builder: (_) => const SignOutConfirmationDialogWidget()),
              );
            }
          ),

          CustomBottomSheetWidget(image: Images.appInfo, title: 'v - ${AppConstants.appVersion}',
              onTap: (){}),

          // CustomBottomSheetWidget(
          //   image: Images.appInfo, title: 'vat',
          //   onTap: () { }
          // ),

        ];

        return Container(decoration: BoxDecoration(
            color: Provider.of<ThemeController>(context).darkTheme
                ? Theme.of(context).highlightColor : Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(topLeft:  Radius.circular(25), topRight: Radius.circular(25))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(onTap: ()=> Navigator.pop(context),
                child: Icon(Icons.keyboard_arrow_down_outlined,color: Theme.of(context).hintColor, size: Dimensions.iconSizeLarge,)),

              const SizedBox(height: Dimensions.paddingSizeVeryTiny),
              Consumer<ProfileController>(
                builder: (context, profileProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: activateMenu,
                    ),
                  );
                }
              ),
            ],
          ),
        );
      }
    );
  }

  void _handleMenuTap(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close bottom sheet
    Future.microtask(() => Navigator.push(
      Get.context!,
      MaterialPageRoute(builder: (_) => screen),
    ));
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
