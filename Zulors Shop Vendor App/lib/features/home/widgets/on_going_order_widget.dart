import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/features/bank_info/controllers/bank_info_controller.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/home/widgets/order_type_button_head_widget.dart';

class OngoingOrderWidget extends StatelessWidget {
  final Function? callback;
  const OngoingOrderWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer<BankInfoController>(
      builder: (context,bankInfoController,child){
        return bankInfoController.businessAnalyticsFilterData  == null ? BusinessAnalyticsShimmer(isDarkMode: Provider.of<ThemeController>(context).darkTheme) : Container(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05),
                  spreadRadius: -3, blurRadius: 12, offset: Offset.fromDirection(0,6))
            ],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: Dimensions.iconSizeLarge,height: Dimensions.iconSizeLarge,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                      child: Image.asset(Images.monthlyEarning)),
                  const SizedBox(width: Dimensions.paddingSizeSmall,),

                  Text(getTranslated('business_analytics', context)!, style: robotoBold.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: Dimensions.fontSizeDefault),),

                  const Expanded(child: SizedBox(width: Dimensions.paddingSizeExtraLarge,)),
                  Container(
                    height: 50,width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(width: .7,color: Theme.of(context).hintColor.withValues(alpha:.3)),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),

                    ),
                    child: DropdownButton<String>(
                      value: bankInfoController.analyticsIndex == 0 ? 'overall' :
                      bankInfoController.analyticsIndex == 1 ?  'today' :
                      bankInfoController.analyticsIndex == 2 ?  'this_week' :
                      bankInfoController.analyticsIndex == 3 ?  'this_month' :
                      'this_year',
                      items: <String>['overall', 'today', 'this_week', 'this_month', 'this_year'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(getTranslated(value, context)!,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        bankInfoController.setAnalyticsFilterName(context,value, true);
                        bankInfoController.setAnalyticsFilterType(
                         value == 'overall' ? 0 :
                         value == 'today'? 1 :
                         value == 'this_week'? 2 :
                         value == 'this_month'? 3 : 4,
                         true
                        );
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),
                ],),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall,),
            Padding(
              padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeDefault,Dimensions.paddingSeven),
              child: Text(getTranslated('on_going_orders', context)!,
                style: robotoBold.copyWith(color: Theme.of(context).primaryColor),),
            ),

            Consumer<BankInfoController>(
              builder: (context, bankInfoController, child) => Padding(
                padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,0, Dimensions.paddingSizeSmall,Dimensions.fontSizeSmall),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: (1 / .65),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    OrderTypeButtonHeadWidget(
                      color: ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.9),
                      text: getTranslated('pending', context), index: 1,
                      subText: getTranslated('orders', context),
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.pending ?? 0, callback: callback,
                    ),

                    OrderTypeButtonHeadWidget(
                      color: ColorHelper.blendColors(Colors.white, Theme.of(context).primaryColor, 0.8),
                      text: getTranslated('processing', context), index: 2,
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.processing ?? 0, callback: callback,
                      subText: getTranslated('orders', context),
                    ),

                    OrderTypeButtonHeadWidget(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      text: getTranslated('confirmed', context), index: 7,
                      subText: getTranslated('orders', context),
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.confirmed ?? 0, callback: callback,
                    ),

                    OrderTypeButtonHeadWidget(
                      color: Theme.of(context).colorScheme.error,
                      text: getTranslated('out_for_delivery', context), index: 8,
                      subText: '',
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.outForDelivery ?? 0, callback: callback,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],),);
      },
    );
  }
}



class BusinessAnalyticsShimmer extends StatelessWidget {
  final bool isDarkMode;
  const BusinessAnalyticsShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;

    return Container(
      padding: const EdgeInsets.only(top: 12), // Dimensions.paddingSizeSmall
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            spreadRadius: -3,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Icon + Title + Dropdown)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 36, height: 36, color: shimmerColor),
                  const SizedBox(width: 12),
                  Container(height: 14, width: 140, color: shimmerColor),
                  const Spacer(),
                  Container(height: 50, width: 120, color: shimmerColor),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Section Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 7),
              child: Container(height: 14, width: 120, color: shimmerColor),
            ),

            // Grid Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1 / 0.65,
                children: List.generate(4, (_) {
                  return Container(
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}


