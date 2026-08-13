import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/product_details/screens/product_details_screen.dart';

class TopMostProductWidget extends StatelessWidget {
  final Product? productModel;
  final bool isPopular;
  final String? totalSold;
  const TopMostProductWidget({super.key, this.productModel, this.isPopular = false, this.totalSold});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraSmall,0,Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeExtraSmall),
      child: GestureDetector(
        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductDetailsScreen(productModel: productModel))),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme?Theme.of(context).primaryColor.withValues(alpha:0):
            Theme.of(context).primaryColor.withValues(alpha:.125), blurRadius: 1,spreadRadius: 1,offset: const Offset(1,2))]


          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Container(decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha:.10),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),),
                width: MediaQuery.of(context).size.width/2,
                height: MediaQuery.of(context).size.width/2-50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  child: CachedNetworkImage(
                    placeholder: (ctx, url) => Image.asset(Images.placeholderImage,
                      height: Dimensions.imageSize,width: Dimensions.imageSize,fit: BoxFit.cover,),
                    fit: BoxFit.cover,
                    height: Dimensions.imageSize,width: Dimensions.imageSize,
                    errorWidget: (ctx,url,err) => Image.asset(Images.placeholderImage,fit: BoxFit.cover,
                     height: Dimensions.imageSize,width: Dimensions.imageSize,),
                     imageUrl: productModel?.thumbnailFullUrl?.path ?? ''),
                ),
              ),
            ),


            Padding(padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeExtraSmall, 0,Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeExtraSmall,),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: Center(
                    child: Text(productModel!.name!.trim(),textAlign: TextAlign.center, style: robotoMedium.copyWith(
                        color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),fontSize: Dimensions.fontSizeDefault),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                isPopular ?
                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Icon(Icons.star, color: Theme.of(context).colorScheme.onSecondary, size: Dimensions.paddingSizeLarge),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text(double.tryParse(productModel?.rating?[0].average ?? '0')?.toStringAsFixed(2) ?? '0.0',
                    style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge),),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Text('(${productModel?.reviewsCount} ${getTranslated('reviews', context)})', style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                    fontSize: Dimensions.fontSizeDefault,
                  )),
                ]) :
                Center(child: Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                  ),
                  child: Text('${NumberFormat.compact().format(double.parse(totalSold!))} ${getTranslated('sold', context)}',
                    style: robotoMedium.copyWith(color: Colors.white),),
                )),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
