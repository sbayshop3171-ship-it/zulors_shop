import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class RefundDetailShimmer extends StatelessWidget {
  const RefundDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {

    // Background color for the pricing container (a bit different from cardColor)
    final pricingContainerBgColor = Theme.of(context).disabledColor.withValues(alpha: 0.05);

    // Shimmer colors inside pricing container (contrast with bg color)
    final baseColor = Theme.of(context).disabledColor.withValues(alpha: 0.2);
    final highlightColor = Theme.of(context).disabledColor.withValues(alpha: 0.1);

    BoxDecoration boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.3),
          spreadRadius: 1,
          blurRadius: 5,
        )
      ],
    );

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // RefundWidget shimmer block
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: boxDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(4, (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: 15,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),

                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: boxDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(5, (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: 15,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        )),
                      ),
                    ),
                  ),

                  // RefundPricingWidget shimmer with distinct background color
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeOrder,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    decoration: BoxDecoration(
                      color: pricingContainerBgColor, // distinct background color here
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          offset: const Offset(0, 1),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ...List.generate(6, (_) => Padding(
                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                              child: Row(
                                children: [
                                  Container(
                                    height: 12,
                                    width: 140,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const Spacer(),

                                  Container(
                                    height: 12,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            )),

                            // Divider line
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: baseColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Row(
                              children: [
                                Container(
                                  height: 14,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  height: 18,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // Customer Info shimmer
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: boxDecoration,
                      child: Row(
                        children: [
                          Container(
                            height: 70,
                            width: 50,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(2, (index) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Container(
                                  height: 10,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Delivery Man Info shimmer
                  Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: boxDecoration,
                      child: Row(
                        children: [
                          Container(
                            height: 70,
                            width: 50,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(2, (index) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Container(
                                  height: 10,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          ),

        ),

        // Approve / Reject button shimmer
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            enabled: true,
            child: Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
