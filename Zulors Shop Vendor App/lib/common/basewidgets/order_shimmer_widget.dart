import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class OrderShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  const OrderShimmerWidget({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 10, spreadRadius: 1)],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        enabled: isEnabled,
        child: Column( children: [
            Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(' ${getTranslated('order_no', context)} : #', style: titilliumBold.copyWith(color: Theme.of(context).textTheme.headlineMedium?.color , fontSize: 14),),
                  Text('\$0.00', style: titilliumBold.copyWith(color:  ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),fontSize: 14)),
                ]
            ),

            Row(children: [
              Text('00:00', style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),fontSize: 10)),
              const SizedBox(width: 5),

              Text('|', style: TextStyle(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55)),),
              const SizedBox(width: 5),

              Text('1 items : item',
                  style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),fontSize: 10)),
            ],),

            Container(height: 2, margin: const EdgeInsets.all(5), color: Theme.of(context).textTheme.headlineMedium?.color),

            Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton(onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Name', style: titilliumBold.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),fontSize: 15))),
                const Expanded(child: SizedBox()),
                Text('${getTranslated('view_details', context)}', style: titilliumRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),fontSize: 12),),
                Icon(Icons.arrow_forward_outlined, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.titleMedium!.color!, 0.55),)
              ],
            )
          ],
        ),
      ),
    );
  }
}
