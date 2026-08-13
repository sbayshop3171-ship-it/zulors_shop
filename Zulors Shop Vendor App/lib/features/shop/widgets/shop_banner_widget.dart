import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';


class ShopBannerWidget extends StatelessWidget {
  final ShopController? resProvider;
  final bool fromBottom;
  final bool fromOffer;
  const ShopBannerWidget({super.key, this.resProvider, this.fromBottom = false, this.fromOffer = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width/3,
      child: fromBottom? CustomImageWidget(image: '${resProvider!.shopModel?.bottomBannerFullUrl?.path}'):
      fromOffer?CustomImageWidget(image: '${resProvider!.shopModel?.offerBannerFullUrl?.path}'):
        CustomImageWidget(image: '${resProvider!.shopModel?.bannerFullUrl?.path}'),
    );
  }
}
