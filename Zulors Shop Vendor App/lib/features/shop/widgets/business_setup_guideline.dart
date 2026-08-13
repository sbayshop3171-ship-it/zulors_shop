
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/guideline_model.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/custom_expansion_tile.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class BusinessSetupGuideline extends StatefulWidget {
  const BusinessSetupGuideline({super.key});

  @override
  State<BusinessSetupGuideline> createState() => _BusinessSetupGuidelineState();
}

class _BusinessSetupGuidelineState extends State<BusinessSetupGuideline> {

  // final CarouselSliderController _controller = CarouselSliderController();
  // int _current = 0;

  List<GuidelineModel> guidelineList = [];

  @override
  void initState() {
    super.initState();

    final ShopController shopController = Provider.of<ShopController>(context, listen: false);


    guidelineList = shopController.myShopPageIndex == 0
        ? AppConstants.inHouseShopGuidelineList
        : shopController.myShopPageIndex == 1
        ? AppConstants.paymentInfoGuidelineList
        : AppConstants.otherSetupGuidelineList;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(Dimensions.radiusExtraLarge),
          topLeft: Radius.circular(Dimensions.radiusExtraLarge),
        ),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(Dimensions.radiusExtraLarge),
              topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          child: Row(
            children: [
              Text(getTranslated('business_setup_guideline', context) ?? '',
                  style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
              ),
              const Spacer(),
      
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const CustomAssetImageWidget(Images.closeIcon, width: 20, height: 20)
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
      
      
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            itemCount: guidelineList.length,
            itemBuilder: (context, index){
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                ),
                child: CustomExpansionTile(
                  expandedAlignment: Alignment.topLeft,
                  title:  Row(children: [
                
                    Text(getTranslated(guidelineList[index].title, context)!,
                        style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: Dimensions.fontSizeLarge)
                    ),
                
                    const Expanded(child: SizedBox()),
                  ]),
                  childrenPadding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    right: Dimensions.paddingSizeDefault,
                    bottom: Dimensions.paddingSizeDefault,
                
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Text(getTranslated(guidelineList[index].description, context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall))),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
          ),
        ),
      
      
      ],
      ),
    );
  }
}



// class SetupGuideLineWidget extends StatefulWidget {
//   final List<GuidelineModel> guidelineList;
//   const SetupGuideLineWidget({super.key, required this.guidelineList,});
//
//   @override
//   State<SetupGuideLineWidget> createState() => _SetupGuideLineWidgetState();
// }
//
// class _SetupGuideLineWidgetState extends State<SetupGuideLineWidget> {
//
//   final CarouselSliderController _controller = CarouselSliderController();
//   int _current = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).hintColor.withValues(alpha: 0.15),
//         borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
//       ),
//       child: Column(children: [
//
//         Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).cardColor,
//             border: Border.all(color: Theme.of(context).hintColor),
//             borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
//           ),
//           padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//           child: CarouselSlider.builder(
//             carouselController: _controller,
//             itemCount: widget.guidelineList.length,
//             itemBuilder: (context, index, realIdx) {
//               return SingleChildScrollView(
//                 child: Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,children: [
//                   Text(getTranslated(widget.guidelineList[index].title, context)!,
//                     style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color,
//                         fontSize: Dimensions.fontSizeLarge),
//                   ),
//
//                   ReadMoreText(
//                     getTranslated(widget.guidelineList[index].description, context)!,
//                     trimMode: TrimMode.Line,
//                     trimLines: 4,
//                     textAlign: TextAlign.justify,
//                     style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
//                     colorClickableText: Theme.of(context).textTheme.bodyLarge?.color,
//                     preDataTextStyle: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
//                     moreStyle: TextStyle(color : Theme.of(context).colorScheme.surfaceTint),
//                     lessStyle: TextStyle(color : Theme.of(context).colorScheme.surfaceTint),
//                     trimCollapsedText: getTranslated('view_more', context)!,
//                     trimExpandedText: getTranslated('view_less', context)!,
//                   ),
//                 ]),
//               );
//             },
//             options: CarouselOptions(
//               aspectRatio: 2/1,
//               viewportFraction: 0.9,
//               autoPlay: false,
//               pauseAutoPlayOnTouch: true,
//               pauseAutoPlayOnManualNavigate: true,
//               pauseAutoPlayInFiniteScroll: true,
//               enlargeFactor: .5,
//               enlargeCenterPage: true,
//               disableCenter: true,
//               enableInfiniteScroll: false,
//               onPageChanged: (index, reason) {
//                 setState(() {
//                   _current = index;
//                 });
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: Dimensions.paddingSizeLarge),
//
//         Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//
//           InkWell(
//             onTap: ()=> _controller.previousPage(),
//             child: Container(
//               padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 border: Border.all(color: Theme.of(context).hintColor, width: 1),
//                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                 shape: BoxShape.rectangle,
//               ),
//               child: Icon(Icons.arrow_back_ios_new, size: Dimensions.paddingSizeMedium, color: Theme.of(context).primaryColor,),
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
//             child: Text.rich(
//               TextSpan(
//                 children: [
//                   TextSpan(text: '${_current+1}/', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.fontSizeDefault)),
//
//                   TextSpan(text: '${widget.guidelineList.length}', style: TextStyle(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
//                 ],
//               ),
//             ),
//           ),
//
//           InkWell(
//             onTap: ()=> _controller.nextPage(),
//             child: Container(
//               padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 border: Border.all(color: Theme.of(context).hintColor, width: 1),
//                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                 shape: BoxShape.rectangle,
//
//               ),
//               child: Icon(Icons.arrow_forward_ios, size: Dimensions.paddingSizeMedium, color: Theme.of(context).primaryColor),
//             ),
//           ),
//         ]),
//       ]),
//     );
//   }
// }





