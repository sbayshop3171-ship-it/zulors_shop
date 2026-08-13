import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/custom_asset_image_widget.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/features/chat/controllers/chat_controller.dart';
import 'package:zulors_shop/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/helper/shop_helper.dart';
import 'package:zulors_shop/main.dart';
import 'package:zulors_shop/utill/images.dart';
import 'package:zulors_shop/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/utill/custom_themes.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class SellerSectionWidget extends StatelessWidget {
  final OrderDetailsController? order;
  const SellerSectionWidget({super.key, this.order});

  @override
  Widget build(BuildContext context) {

    bool isVacationActive = false;

    if (order?.orderDetails != null && order!.orderDetails![0].seller != null) {
      isVacationActive = ShopHelper.isVacationActive(
        context, startDate: order!.orderDetails![0].seller?.shop?.vacationStartDate,
        endDate: order!.orderDetails![0].seller?.shop?.vacationEndDate,
        vacationDurationType: order!.orderDetails![0].seller?.shop?.vacationDurationType,
        vacationStatus: order!.orderDetails![0].seller?.shop?.vacationStatus,
        isInHouseSeller: order!.orderDetails![0].order?.sellerIs == 'admin'
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withValues(alpha:0.2), spreadRadius:1.5, blurRadius: 3)],
        color: Theme.of(context).cardColor,
      ),

      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: InkWell(onTap: () {
            if(Provider.of<AuthController>(context, listen: false).isLoggedIn()){
              Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
              if((order!.orderDetails![0].seller != null && ((order!.orderDetails![0].seller?.shop?.temporaryClose ?? false)))) {
                showCustomSnackBarWidget(getTranslated("this_shop_is_close_now", context), context, snackBarType: SnackBarType.error);
              } else if(order!.orderDetails![0].seller != null) {
                RouterHelper.getChatScreenRoute(
                  action: RouteAction.push,
                  id: order!.orderDetails![0].order?.sellerIs == 'admin'
                      ? 0
                      : order!.orderDetails![0].seller!.id,
                  name: order!.orderDetails![0].order?.sellerIs == 'admin'
                      ? "${Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name}"
                      : order!.orderDetails![0].seller!.shop!.name,
                  image: order!.orderDetails![0].order?.sellerIs == 'admin'
                      ? "${Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.imageFullUrl?.path}"
                      : order!.orderDetails![0].seller?.shop?.imageFullUrl?.path,
                  isShopOnVacation: isVacationActive,
                  isShopTemporaryClosed: order!.orderDetails![0].seller?.shop?.temporaryClose ?? false,
                );
              } else {
                showCustomSnackBarWidget(getTranslated('seller_not_available', context), Get.context!, snackBarType: SnackBarType.error);
              }
            }else{
              showModalBottomSheet(backgroundColor: Colors.transparent, context: context, builder: (_)=> const NotLoggedInBottomSheetWidget());}
            },
              child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  CustomAssetImageWidget(Images.vendorIcon, color: Theme.of(context).primaryColor, height: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  if( order != null && order!.orderDetails != null && order!.orderDetails != null && order!.orderDetails!.isNotEmpty)
                  SizedBox(width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(maxLines: 1, overflow: TextOverflow.ellipsis,
                      (order?.orderDetails != null && order!.orderDetails!.isNotEmpty && order!.orderDetails![0].order?.sellerIs == 'admin' ) ? '${Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name}' :
                      '${order?.orderDetails?[0].seller?.shop?.name??'${getTranslated('seller_not_available', context)}'} ',
                      style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)
                    )
                  ),
                  const Spacer(),
                  const SizedBox(width: Dimensions.iconSizeDefault, child: CustomAssetImageWidget(Images.storeChatIcon, height: 20, width: 20))
                ]),
              ),
            ),
        ),

        Divider(thickness: .25, color: Theme.of(context).primaryColor.withValues(alpha:0.50)),

      ]),
    );
  }
}
