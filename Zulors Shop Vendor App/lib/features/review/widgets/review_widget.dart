import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/review/domain/models/review_model.dart';
import 'package:zulors_shop_vendor/features/review/screens/review_reply_widget.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/image_diaglog_widget.dart';


class ReviewWidget extends StatelessWidget {
  final int? index;
  final ReviewModel? reviewModel;
  final bool? isDetails;
  const ReviewWidget({super.key, required this.reviewModel, this.isDetails = false, this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
          spreadRadius: 0.5, blurRadius: 0.3)],
        ),

        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                    child: Container(
                      width: Dimensions.stockOutImageSize,
                      height: Dimensions.stockOutImageSize,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                        boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                            spreadRadius: 0.5, blurRadius: 0.3)],

                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                        child: CustomImageWidget(image: '${reviewModel!.product!.thumbnailFullUrl?.path}',)

                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(getTranslated(reviewModel!.product!.productType, context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

            Flexible(flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reviewModel!.customer != null?
                      Text('${reviewModel!.customer!.fName ?? ''}' '${reviewModel!.customer!.lName ?? ''}',
                          style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                          maxLines: 1, overflow: TextOverflow.ellipsis):const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  
                      Text(reviewModel!.product!.name ?? '',
                          style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  
                      Row(children: [
                        Icon(Icons.star, color: Provider.of<ThemeController>(context).darkTheme ?
                            Colors.white : Colors.orange, size: Dimensions.iconSizeDefault),
                  
                        Text('${reviewModel!.rating!.toDouble().toStringAsFixed(1)}/5', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  
                        const Spacer(),
                  
                  
                        Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(reviewModel!.createdAt!)), style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))
                  
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  
                  
                      Text(reviewModel!.comment ?? '',
                        style: robotoHintRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                        maxLines: isDetails! ? 1000 : 2, overflow: TextOverflow.ellipsis,),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  
                  
                      (reviewModel!.attachmentFullUrl != null && reviewModel!.attachmentFullUrl!.isNotEmpty) ? Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        child: SizedBox(
                          height: 40,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: reviewModel!.attachmentFullUrl!.length,
                            itemBuilder: (context, index) {
                             // String imageUrl = '${Provider.of<SplashController>(context, listen: false).baseUrls!.reviewImageUrl}/review/${reviewModel!.attachment![index]}';
                              return InkWell(
                                onTap: () => showDialog(context: context, builder: (ctx) =>
                                    ImageDialogWidget(imageUrl: reviewModel!.attachmentFullUrl![index].path ?? '')),
                                child: Container(
                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: Images.placeholderImage, height: 40, width: 40, fit: BoxFit.cover,
                                      image: reviewModel!.attachmentFullUrl![index].path ?? '',
                                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderImage, height: 40, width: 40, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ) : const SizedBox(),


                      (Provider.of<SplashController>(context, listen: false).configModel!.reviewReplyStatus == true && (isDetails == null || isDetails == false)) ?
                         const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                  
                  
                      (Provider.of<SplashController>(context, listen: false).configModel!.reviewReplyStatus == true && (isDetails == null || isDetails == false)) ?
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> ReviewReplyScreen(reviewModel: reviewModel, index: index, productId: reviewModel?.productId,  formProduct: false)));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                              color: reviewModel?.reply != null ?  Theme.of(context).colorScheme.surfaceTint.withValues(alpha:0.05) : Theme.of(context).colorScheme.surfaceTint
                          ),
                          child: Text( reviewModel?.reply != null ? getTranslated('view_reply', context)!  :getTranslated('review_reply', context)!, style : robotoBold.copyWith(color: reviewModel?.reply != null ?  Theme.of(context).colorScheme.surfaceTint : Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall)),
                        ),
                      ) : const SizedBox()
                  
                  
                  
                    ],),
                ),
              ),
            )

          ],),
      ),
    );

  }
}
