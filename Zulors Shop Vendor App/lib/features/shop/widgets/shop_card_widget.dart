import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/screens/shop_update_screen.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ShopCardWidget extends StatelessWidget {
  const ShopCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Consumer<ShopController>(
      builder: (context, shopInfo, child) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)
            ),
            child: Stack(children: [

                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        height: MediaQuery.of(context).size.width/3,
                        child:  ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeDefault), topRight: Radius.circular(Dimensions.paddingSizeDefault)),
                          child: CustomImageWidget(image: '${shopInfo.shopModel?.bannerFullUrl?.path}')
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        left:  Dimensions.paddingSizeSmall,
                        right:  Dimensions.paddingSizeSmall,
                        bottom:  Dimensions.paddingSizeDefault,
                        top:  Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 75),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shopInfo.shopModel?.name ?? '',
                                      style: robotoBold.copyWith(
                                        color: Theme.of(context).textTheme.titleMedium?.color,
                                        fontSize: Dimensions.fontSizeLarge, height: 1.0,
                                        overflow: TextOverflow.ellipsis
                                      ),
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeVeryTiny),
                                
                                    Text(
                                      '${getTranslated('created_at', context)} ${DateConverter.localToIsoString(DateTime.parse(shopInfo.shopModel!.createdAt!))}',
                                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall, height: 1.0)
                                    )
                                  ],
                                ),
                              ),

                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              InkWell(
                                onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopUpdateScreen())),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    color: Theme.of(context).primaryColor
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                    children: [
                                      const CustomAssetImageWidget(Images.myShopEditIcon, width: 15, height: 15),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                      Text(
                                        getTranslated('edit', context) ?? '',
                                        style: robotoBold.copyWith(color: Theme.of(context).highlightColor)
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ShopInfoCard(
                                  width: 110,
                                  title: getTranslated('products', context) ?? '',
                                  count: shopInfo.shopModel?.totalProducts.toString() ?? '0',
                                  image: Images.productsIcon,
                                  color: Theme.of(context).colorScheme.surfaceTint,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                ShopInfoCard(
                                  width: 110,
                                  title: getTranslated('orders', context) ?? '',
                                  count: shopInfo.shopModel?.totalOrder.toString() ?? '0',
                                  image: Images.orderIcon,
                                  color: ColorHelper.darken(Theme.of(context).colorScheme.onSecondary, 0.1),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                ShopInfoCard(
                                  width: 110,
                                  title: getTranslated('reviews', context) ?? '',
                                  count: shopInfo.shopModel?.totalReview.toString() ?? '0',
                                  image: Images.reviewsIcon,
                                  color: ColorHelper.darken(Theme.of(context).colorScheme.onTertiaryContainer, 0.1),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                if(shopInfo.shopModel?.taxIdentificationNumber != null && shopInfo.shopModel?.tinExpireDate != null)
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 90,
                                      maxWidth: 200,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                          color: Theme.of(context).hintColor.withValues(alpha: 0.10)
                                      ),

                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${getTranslated('tin', context)} : ${shopInfo.shopModel?.taxIdentificationNumber}",
                                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                ),
                                              ),

                                              const CustomAssetImageWidget(Images.tinIdIcon, width: 20, height: 20),
                                            ],
                                          ),
                                          const SizedBox(height: Dimensions.paddingSizeSmall),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeVeryTiny),
                                            child: Text(
                                                "${getTranslated('exp', context)} : ${ DateConverter.localToIsoString(DateTime.parse(shopInfo.shopModel?.tinExpireDate ?? ''))}",
                                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )

                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),


                Positioned(
                  top: 103,
                  left: 15,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                      child: CustomImageWidget(image: '${shopInfo.shopModel?.imageFullUrl?.path}')
                    ),
                  ),
                ),

              ]),
          ),
        );
      }
    );
  }
}


class ShopInfoCard extends StatelessWidget {
  final String title;
  final String count;
  final String image;
  final Color? color;
  final double? width;
  const ShopInfoCard({super.key, required this.title, required this.count, required this.image, this.color, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).hintColor.withValues(alpha: 0.10)
      ),

      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)
              ),

              CustomAssetImageWidget(image, width: 20, height: 20),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            count,
            style: robotoBold.copyWith(
              color: color,
              fontSize: Dimensions.fontSizeOverlarge,
              height: 1.0,
            ),
          ),

        ],
      ),
    );
  }
}
