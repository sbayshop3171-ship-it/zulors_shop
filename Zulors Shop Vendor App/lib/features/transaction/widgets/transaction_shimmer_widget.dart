import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class TransactionShimmerWidget extends StatelessWidget {
  const TransactionShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).disabledColor.withValues(alpha: 0.2);
    final highlightColor = Theme.of(context).disabledColor.withValues(alpha:0.1);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        itemCount: 10,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.fromLTRB(
            Dimensions.paddingSizeSmall, 0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            color: Theme.of(context).hintColor.withValues(alpha: 0.3),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingEye,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.paddingSizeExtraSmall),
                  topRight: Radius.circular(Dimensions.paddingSizeExtraSmall),
                ),
                color: baseColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 10, width: 150, color: Colors.white),
                  Container(height: 20, width: 80, color: Colors.white),
                ],
              ),
            ),

            // Content section
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 120, color: Colors.white),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      children: [
                        Container(height: 14, width: 14, color: Colors.white),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Container(height: 10, width: 80, color: Colors.white),
                      ],
                    )
                  ],
                ),
                const Spacer(),
                Container(height: 25, width: 90, color: Colors.white),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
