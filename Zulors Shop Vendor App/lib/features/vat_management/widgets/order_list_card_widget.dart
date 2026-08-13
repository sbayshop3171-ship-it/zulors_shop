import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/vat_management/domain/models/vat_report_model.dart';
import 'package:zulors_shop_vendor/features/vat_management/widgets/tax_detail_bottom_sheet_widget.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class OrderListCardWidget extends StatelessWidget {
  final OrderTransactions? orderModel;
  const OrderListCardWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 10,
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
        
        Padding(
          padding: const EdgeInsets.all(Dimensions.fontSizeSmall),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [
                TextSpan(text: '${getTranslated('order', context)} # ', style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                )),
                TextSpan(text: orderModel?.orderId.toString(), style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor))
              ])),

              Text(PriceConverter.convertPrice(context, orderModel?.orderAmount), style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
            ]),

            Text(DateConverter.formatDate(DateTime.tryParse(orderModel?.createdAt ?? '') ?? DateTime.now()), style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
            )),
          ]),
        ),

        Container(
          padding: EdgeInsets.all(Dimensions.fontSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeSmall), bottomRight: Radius.circular(Dimensions.paddingSizeSmall)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Text('${getTranslated('vat_all_capital', context)} : ${PriceConverter.convertPrice(context, double.tryParse(orderModel?.tax.toString() ?? '') )}',
                  style: robotoMedium.copyWith (
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColor
                  )
                ),


                Text('${orderModel?.order?.taxModel != 'include' ? getTranslated(orderModel?.order?.taxType ?? 'order_wise', context) : ''}${orderModel?.order?.taxModel == 'include' ? getTranslated('tax_included', context) : ''}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor))
              ]),
            ),
            SizedBox(width: Dimensions.paddingSizeSmall),

            InkWell(
              splashColor: Colors.transparent,
              onTap: (){
                showModalBottomSheet(
                  backgroundColor: Theme.of(context).cardColor,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return TaxDetailBottomSheetWidget(orderModel: orderModel);
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(Dimensions.paddingEye),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )],
                ),
                child: Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: Dimensions.paddingSizeDefault),
              ),
            ),
          ]),
        ),



      ]),
    );
  }
}
