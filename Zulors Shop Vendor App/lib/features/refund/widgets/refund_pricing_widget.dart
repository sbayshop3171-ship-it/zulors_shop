import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_details_widget.dart';

class RefundPricingWidget extends StatelessWidget {
  const RefundPricingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOrder, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 7,
          )]
      ),
      child: Consumer<RefundController>(
          builder: (context, refund,_) {
            return Padding(padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall),
              child: refund.refundDetailsModel != null ?
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                ProductCalculationItem(title: 'product_price', qty: refund.refundDetailsModel?.quntity,
                  price: (refund.refundDetailsModel!.productPrice! * (refund.refundDetailsModel?.quntity??1)), isQ: true, isPositive: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),

                ProductCalculationItem(title: 'product_discount',price: refund.refundDetailsModel!.productTotalDiscount, isNegative: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                ProductCalculationItem(title: 'coupon_discount',price: refund.refundDetailsModel!.couponDiscount, isNegative: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                ProductCalculationItem(title: 'product_tax',price: refund.refundDetailsModel!.productTotalTax, isPositive: true),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                ProductCalculationItem(title: 'subtotal',price: refund.refundDetailsModel!.subtotal),

                if(refund.refundDetailsModel?.referralDiscount != null && refund.refundDetailsModel!.referralDiscount! > 0) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  ProductCalculationItem(title: 'referral_discount',price: refund.refundDetailsModel?.referralDiscount, isNegative: true),
                ],
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Divider(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.10), height: 1, thickness: 1),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(children: [
                  Text('${getTranslated('total_refund_amount', context)}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),

                  const Spacer(),

                  Text(PriceConverter.convertPrice(context, refund.refundDetailsModel!.refundAmount),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w700),
                  ),
                ]),
              ]) : const SizedBox(),
            );
          }),
    );
  }
}
