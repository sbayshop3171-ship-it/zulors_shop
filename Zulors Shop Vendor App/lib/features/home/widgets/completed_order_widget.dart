import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/features/bank_info/controllers/bank_info_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/home/widgets/order_type_button_widget.dart';

class CompletedOrderWidget extends StatelessWidget {
  final Function? callback;
  const CompletedOrderWidget({super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Consumer<BankInfoController>(
      builder: (context, bankInfoController, child) {
        return bankInfoController.businessAnalyticsFilterData == null ? CompletedOrdersShimmer(isDarkMode: Provider.of<ThemeController>(context).darkTheme) : Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05),
                  spreadRadius: -3, blurRadius: 12, offset: Offset.fromDirection(0,6))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
            Padding(
              padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraSmall,Dimensions.paddingSizeDefault,0 ),
              child: Text(getTranslated('completed_orders', context)!,
                style: robotoBold.copyWith(color: Theme.of(context).primaryColor),),
            ),

            Consumer<BankInfoController>(
              builder: (context, bankInfoController, child) => SizedBox(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OrderTypeButtonWidget(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      icon: Images.delivered,
                      text: getTranslated('delivered', context), index: 3,
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.delivered, callback: callback,
                    ),

                    OrderTypeButtonWidget(
                      color: Theme.of(context).colorScheme.error,
                      icon: Images.cancelled,
                      text: getTranslated('cancelled', context), index: 6,
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.canceled, callback: callback,
                    ),

                    OrderTypeButtonWidget(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      icon: Images.returned,
                      text: getTranslated('return', context), index: 4,
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.returned, callback: callback,
                    ),

                    OrderTypeButtonWidget(
                      showBorder: false,
                      color: Theme.of(context).colorScheme.error,
                      icon: Images.failed,
                      text: getTranslated('failed', context), index: 5,
                      numberOfOrder: bankInfoController.businessAnalyticsFilterData?.failed, callback: callback,
                    ),
                  ],
                ),
              ),
            ),


            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],),);
      }
    );
  }
}



class CompletedOrdersShimmer extends StatelessWidget {
  final bool isDarkMode;
  const CompletedOrdersShimmer({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;

    return Container(
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
            // Title shimmer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(height: 14, width: 160, color: shimmerColor),
            ),
            const SizedBox(height: 12),

            // Shimmer list
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (_, __) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 70,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

