import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class AddProductTitleBar extends StatelessWidget {
  AddProductTitleBar({super.key});
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return  Consumer<AddProductController>(
        builder : (context, resProvider, child){
          // if(resProvider.selectedPageIndex == 2) {
          //   final maxScroll = _scrollController.position.maxScrollExtent;
          //   _scrollController.jumpTo(maxScroll);
          // } else if (resProvider.selectedPageIndex == 0) {
          //   final minScroll = _scrollController.position.minScrollExtent;
          //   _scrollController.jumpTo(minScroll);
          // }
        return SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingEye),
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: resProvider.selectedPageIndex == 0 ? Theme.of(context).primaryColor: Colors.transparent),
                      color: resProvider.selectedPageIndex == 0 ? Theme.of(context).primaryColor.withValues(alpha:0.06) : Colors.transparent
                  ),
                  child: Center(
                    child: Text(getTranslated(resProvider.pages[0], context)!,
                      style: robotoRegular.copyWith(color: resProvider.selectedPageIndex == 0 ? Theme.of(context).primaryColor: Theme.of(context).hintColor),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingEye,),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: resProvider.selectedPageIndex == 1 ? Theme.of(context).primaryColor: Colors.transparent),
                      color: resProvider.selectedPageIndex == 1 ? Theme.of(context).primaryColor.withValues(alpha:0.06) : Colors.transparent
                  ),
                  child: Text(getTranslated(resProvider.pages[1], context)!,
                    style: robotoRegular.copyWith(color: resProvider.selectedPageIndex == 1 ? Theme.of(context).primaryColor: Theme.of(context).hintColor),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingEye,),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: resProvider.selectedPageIndex == 2 ? Theme.of(context).primaryColor : Colors.transparent),
                      color: resProvider.selectedPageIndex == 2 ? Theme.of(context).primaryColor.withValues(alpha:0.06) : Colors.transparent
                  ),
                  child: Text(
                    getTranslated(resProvider.pages[2], context)!,
                    style: robotoRegular.copyWith(color: resProvider.selectedPageIndex == 2 ? Theme.of(context).primaryColor: Theme.of(context).hintColor),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
