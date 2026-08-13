import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class NoDataScreen extends StatelessWidget {
  final String? title;
  final Color? color;
  final String? image;
  final EdgeInsets? padding;
  const NoDataScreen({super.key, this.title, this.color, this.image, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: _CenterWidget(
        isCenter: padding == null,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            CustomAssetImageWidget(image ??  Images.noOrderFound, width: 100, height: 100),
            Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Text(title != null ? getTranslated(title, context)!:
                getTranslated('nothing_found', context)!,
                style: robotoRegular.copyWith(color: color ?? Theme.of(context).hintColor),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _CenterWidget extends StatelessWidget {
  final bool isCenter;
  final Widget child;
  const _CenterWidget({required this.isCenter, required this.child});

  @override
  Widget build(BuildContext context) {
    return isCenter ? Center(child: child) : child;
  }
}

