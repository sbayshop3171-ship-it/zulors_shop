import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/shipping/domain/models/category_wise_shipping_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/shipping/controllers/shipping_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';

class CategoryWiseShippingCardWidget extends StatelessWidget {
  final ShippingController? shipProv;
  final Category? category;
  final int? index;

  const CategoryWiseShippingCardWidget({super.key, this.shipProv, this.category, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Provider.of<ThemeController>(context).darkTheme ?
        Theme.of(context).highlightColor.withValues(alpha: 0.9) :
        Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme?Theme.of(context).primaryColor.withValues(alpha:0):
        Theme.of(context).primaryColor.withValues(alpha:.1), spreadRadius: 1, blurRadius: 1, offset: const Offset(0,1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

        Container(padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha:.095),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeSmall), topRight: Radius.circular(Dimensions.paddingSizeSmall))
          ),
          child: Row(
            children: [
              Text('${index! + 1}.  ${category!=null? category!.name:''}', maxLines: 3,overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
            ],
          ),
        ),

        Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withValues(alpha:.05),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeExtraSmall))
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.iconSizeMedium),
                      child: Text('${getTranslated('cost_per_product', context)} (${Provider.of<SplashController>(context, listen: false).myCurrency!.symbol})',
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ),

                    CustomTextFieldWidget(
                      border: true,
                      controller: shipProv!.shippingCostController[index!],
                      focusNode: shipProv!.shippingCostNode[index!],
                      textInputAction: TextInputAction.next,
                      textInputType: TextInputType.number,
                      isAmount: true,
                      // isAmount: true,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeMedium,)
                  ],
                ),
              ),
            ),
          ),


          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(Dimensions.paddingSizeExtraSmall))
              ),
              child: Column(mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
                  child: Text('${getTranslated('multiply_with_qty', context)}',
                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                    FlutterSwitch(width: 40,height: 20,toggleSize: 16,padding: 2,
                      value:shipProv!.isMultiply[index!],
                  onToggle: (value){
                    shipProv!.toggleMultiply(context,value,index!);
                  },
                ),
                    const SizedBox(height: 42)
              ]),
            ),
          ),
        ]),
      ]),
    );
  }
}
