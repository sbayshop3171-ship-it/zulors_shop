import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class CustomerShimmer extends StatelessWidget {
  const CustomerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).disabledColor.withValues(alpha: 0.05);
    final highlightColor = Theme.of(context).disabledColor.withValues(alpha: 0.15);
    final width = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: width * 0.5,
                    color: Colors.white,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeMedium),
                  Container(
                    height: 0.5,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
