import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/features/wishlist/controllers/wishlist_controller.dart';
import 'package:zulors_shop/theme/controllers/theme_controller.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';

class FavouriteButtonWidget extends StatelessWidget {
  final Color backgroundColor;
  final int? productId;
  final bool? fromProductDetails;
  const FavouriteButtonWidget({super.key, this.backgroundColor = Colors.black, this.productId, this.fromProductDetails = false});
  @override
  Widget build(BuildContext context) {
    bool isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    bool isDarkMode = Provider.of<ThemeController>(context).darkTheme;

    return Consumer<WishListController>(
      builder: (context, wishProvider,_) {
        return GestureDetector(
          onTap: () {
            if (isGuestMode) {
             showModalBottomSheet(backgroundColor: Colors.transparent,
                 context: context, builder: (_)=> const NotLoggedInBottomSheetWidget());
            } else {
              wishProvider.addedIntoWish.contains(productId)?
              wishProvider.removeWishList(productId,) :
              wishProvider.addWishList(productId);
            }
          },
          child: Container(
            height: (fromProductDetails ?? false) ? 40 : null,
            width: (fromProductDetails ?? false) ? 40 : null,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.transparent : Theme.of(context).cardColor,
              border: Border.all(color: isDarkMode ? Theme.of(context).primaryColor : Colors.transparent, width: 1),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.10),
                spreadRadius: 0,
                blurRadius: 15,
                offset: const Offset(0,3),
              )],
            ),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
              transform: Matrix4.translationValues(0, 1, 0),
              child: Icon(wishProvider.addedIntoWish.contains(productId)
                  ? CupertinoIcons.heart_fill
                  : CupertinoIcons.heart,
                color: wishProvider.addedIntoWish.contains(productId)
                  ? Theme.of(context).primaryColor
                  : isDarkMode ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                size: Dimensions.paddingSizeDefaultAddress,
              ),
            ),
          ),
        );
      }
    );
  }
}
