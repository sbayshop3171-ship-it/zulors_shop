import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/vat_management/domain/models/vat_report_model.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';



class TaxDetailBottomSheetWidget extends StatelessWidget {
  final OrderTransactions? orderModel;
  const TaxDetailBottomSheetWidget({super.key, required this.orderModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(mainAxisSize: MainAxisSize.min,children: [

        Align(
          alignment: Alignment.center,
          child: Container(
            height: 4, width: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
            ),
          ),
        ),

        Transform.translate(
          offset: Offset(0, -7),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.cancel_outlined,
                size: Dimensions.iconSizeMedium,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
        SizedBox(height: Dimensions.paddingSizeSmall),


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Column(children: [
            Text('${getTranslated('order_id', context)} #${orderModel?.orderId}', style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),

            Text(DateConverter.formatDate(DateTime.parse(orderModel?.createdAt?.toString() ?? '')), style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            )),


            Text('${orderModel?.order?.taxModel != 'include' ? getTranslated(orderModel?.order?.taxType ?? 'order_wise', context):''}${orderModel?.order?.taxModel == 'include' ? getTranslated('tax_included', context) : ''}', style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
            
            SizedBox(height: Dimensions.paddingSizeLarge),

            Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: '${getTranslated('payment', context)}: ', style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                    )),

                    TextSpan(text: PriceConverter.convertPrice(context, orderModel?.order?.orderAmount), style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                  ])),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeOrder),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  child: Text(getTranslated(orderModel?.order?.paymentStatus.toString(), context)!, style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  )),
                ),

              ]),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),

            Container(
              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
              ),
              child: Column(children: [
                ListView.separated(
                  itemCount: orderModel?.vatAmountFormats?.allVatGroups?.length ?? 0,
                  padding: const EdgeInsets.all(0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(orderModel?.vatAmountFormats?.allVatGroups?[index].groupName ?? '', style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )),

                        Padding(
                          padding: EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                          child: ListView.builder(
                            itemCount: orderModel?.vatAmountFormats?.allVatGroups?[index].data?.length ?? 0,
                            padding: const EdgeInsets.all(0),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int i) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(orderModel?.vatAmountFormats?.allVatGroups?[index].data?[i].name ?? '', style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
                                  )),

                                  Text(PriceConverter.convertPrice(context, orderModel?.vatAmountFormats?.allVatGroups?[index].data?[i].taxAmount), style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  )),
                                ]);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => SizedBox(height: Dimensions.paddingSizeSmall),
                ),

                Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.5), thickness: 1),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                  Text(getTranslated('total_vat_amount', context)!, style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),

                  Text(PriceConverter.convertPrice(context, orderModel?.tax), style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                ]),
              ]),
            )
          ]),
        )


      ]),
    );
  }
}
