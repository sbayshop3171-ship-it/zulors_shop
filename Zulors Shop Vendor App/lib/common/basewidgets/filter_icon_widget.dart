import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class FilterIconWidget extends StatelessWidget {
  final int? filterCount;
  final double? height;
  final double? width;
  final GestureTapCallback? onTap;

  const FilterIconWidget({super.key, this.filterCount = 0, required this.onTap, this.height = 40, this.width = 40});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Stack(children: [
      CustomAssetImageWidget(Images.productFilter, width: width, height: height),

      if(filterCount! > 0) Positioned(right: 0, top: 0, child: Container(
        width: 17, height: 17,
        transform: Matrix4.translationValues(6, -6, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          border: Border.all(color: Theme.of(context).highlightColor, width: 2,),
          borderRadius: BorderRadius.circular(Dimensions.productImageSize),
        ),
        child: Center(
          child: Text('$filterCount', style: robotoRegular.copyWith(
            fontSize: Dimensions.paddingSizeSmall,
            color: Theme.of(context).highlightColor,
          )),
        ),
      )),
    ]));
  }
}
