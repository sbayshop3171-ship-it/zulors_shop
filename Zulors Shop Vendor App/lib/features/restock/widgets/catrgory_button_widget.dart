import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class CategoryButtonWidget extends StatelessWidget {
  final String? text;
  final int index;
  final int? categoryId;
  const CategoryButtonWidget({super.key, required this.text, required this.index, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
         Provider.of<RestockController>(context, listen: false).setIndex(index, categoryId);
         Provider.of<RestockController>(context, listen: false).getRestockProductList(1);
        },
        child: Consumer<RestockController>(builder: (context, order, child) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: order.categoryIndex == index ? Theme.of(context).primaryColor : Provider.of<ThemeController>(context).darkTheme ?
              ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
              Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
            ),
            child: Text(text!, style: order.categoryIndex == index ? titilliumBold.copyWith(color: order.categoryIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color):
            robotoRegular.copyWith(color: order.categoryIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color)),
          );
        },
        ),
      ),
    );
  }
}