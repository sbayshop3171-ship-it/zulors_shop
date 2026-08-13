import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/searched_product_item_widget.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ProductSearchDialogWidget extends StatelessWidget {
  const ProductSearchDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
      builder: (context, searchedProductController,_){
        int length =  searchedProductController.posProductList.length;
      return searchedProductController.posProductList.isNotEmpty?
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
        child: Container(height: length == 1 ? 70 : length == 2 ? 135 : 400,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.125),
            spreadRadius: .5, blurRadius: 12, offset: const Offset(3,5))]
          ),
          child: ListView.builder(
              itemCount: searchedProductController.posProductList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx,index){
                return SearchedProductItemWidget(product: searchedProductController.posProductList[index]);
              }),
        ),
      ): Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
        child: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
            boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.125),
                spreadRadius: .5, blurRadius: 12, offset: const Offset(3,5))]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(getTranslated('no_product_found', context)!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge))
            ],
          ),
        ),
      );
    });
  }
}
