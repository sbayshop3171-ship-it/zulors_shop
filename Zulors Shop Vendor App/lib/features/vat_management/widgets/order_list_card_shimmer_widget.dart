import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class OrderListCardShimmer extends StatelessWidget {
  const OrderListCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).disabledColor.withValues(alpha:0.05);
    final highlightColor = Theme.of(context).disabledColor.withValues(alpha:0.15);

    return ListView.builder(
      shrinkWrap: true,
      itemCount: 6, // Number of shimmer cards to show
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Top Row - Order ID & Amount
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.fontSizeSmall),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 10, width: 80, color: Colors.white),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Container(height: 16, width: 120, color: Colors.white),
                          ],
                        ),
                        Container(height: 10, width: 60, color: Colors.white),
                      ],
                    ),
                  ),

                  // Bottom Row - VAT & Forward Icon
                  Container(
                    padding: EdgeInsets.all(Dimensions.fontSizeLarge),
                    decoration: BoxDecoration(
                      color: baseColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(Dimensions.paddingSizeSmall),
                        bottomRight: Radius.circular(Dimensions.paddingSizeSmall),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 14, width: 80, color: Colors.white),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              Container(height: 10, width: 100, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
