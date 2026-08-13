import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/features/vat_management/domain/models/vat_report_model.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class TaxInfoCard extends StatelessWidget {
  final TypeWiseTaxesList taxModel;

  const TaxInfoCard({super.key,  required this.taxModel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(taxModel.name ?? '', style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )),
          SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: 35,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: taxModel.data?.length ?? 0,
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingEye),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('${taxModel.data?[i].name} (${taxModel.data?[i].taxRate}%)', style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                      )),
                      SizedBox(width: Dimensions.paddingSizeButton),

                      Text(PriceConverter.convertPrice(context, taxModel.data?[i].totalAmount), style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      )),
                  ]),
                );
              },
              separatorBuilder: (BuildContext context, int i) {
                return SizedBox(width: Dimensions.paddingSizeSmall);
              },
            ),
          ),



        ],
      ),
    );
  }
}
