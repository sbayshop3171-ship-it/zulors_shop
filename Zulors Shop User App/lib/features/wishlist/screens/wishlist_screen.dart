import 'package:flutter/material.dart';
import 'package:zulors_shop/features/profile/controllers/profile_contrroller.dart';
import 'package:zulors_shop/features/wishlist/controllers/wishlist_controller.dart';
import 'package:zulors_shop/features/wishlist/widgets/wishlist_shimmer.dart';
import 'package:zulors_shop/features/wishlist/widgets/wishlist_widget.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/utill/images.dart';
import 'package:zulors_shop/common/basewidget/custom_app_bar_widget.dart';
import 'package:zulors_shop/common/basewidget/no_internet_screen_widget.dart';
import 'package:zulors_shop/common/basewidget/not_loggedin_widget.dart';
import 'package:provider/provider.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});
  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  @override
  void initState() {
    super.initState();
    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
      Provider.of<WishListController>(context, listen: false).getWishList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        if(Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
          Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page : 'more');
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: getTranslated('wishList', context)),
        resizeToAvoidBottomInset: true,
        body: Column(children: [

          Expanded(child: !Provider.of<AuthController>(context, listen: false).isLoggedIn() ?
          NotLoggedInWidget(
            fromPage: RouterHelper.wishListScreen,
            onLoginSuccess: () {
              RouterHelper.getWishListRoute(action: RouteAction.pushReplacement);
            },
          )
            : Consumer<WishListController>(builder: (context, wishListProvider, child) {
          return wishListProvider.wishList != null
            ? wishListProvider.wishList!.isNotEmpty
            ? RefreshIndicator(
            onRefresh: () async => await  wishListProvider.getWishList(),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: wishListProvider.wishList!.length,
              itemBuilder: (context, index) => WishListWidget(wishlistModel: wishListProvider.wishList?[index], index: index),
            ))
            : const NoInternetOrDataScreenWidget(isNoInternet: false, message: 'no_wishlist_product', icon: Images.noWishlist)
            : const WishListShimmer();
          })),
        ]),
      ),
    );
  }
}


