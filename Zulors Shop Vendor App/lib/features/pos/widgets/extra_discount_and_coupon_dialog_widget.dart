import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart' show SnackBarType, showCustomSnackBarWidget;
import 'package:zulors_shop_vendor/features/pos/controllers/coupon_discount_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_field_with_title_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';

class ExtraDiscountAndCouponDialogWidget extends StatelessWidget {
  final double payable;
  const ExtraDiscountAndCouponDialogWidget({super.key, required this.payable});

  @override
  Widget build(BuildContext context) {
    return Dialog( surfaceTintColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      child: Consumer<CouponDiscountController>(
        builder: (context, couponDiscountController, _) {
          return Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:CrossAxisAlignment.start,children: [

              Consumer<CouponDiscountController>(
              builder: (context,couponDiscountController,_) {
                return Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 0, Dimensions.paddingSizeDefault, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(getTranslated('discount_type', context)!,
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(width: .7,color: Theme.of(context).hintColor.withValues(alpha:.3)),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),

                      ),
                      child: DropdownButton<String>(
                        value: couponDiscountController.discountTypeIndex == 0 ? 'amount'  :  'percent',
                        items: <String>['amount','percent'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(getTranslated(value, context)!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          couponDiscountController.setSelectedDiscountType(value);
                          couponDiscountController.setDiscountTypeIndex(value == 'amount' ? 0 : 1, true);
                          Provider.of<CartController>(context, listen: false).getTaxAmount();
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),

                  ]),
                );
              }
            ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              CustomFieldWithTitleWidget(
                customTextField: CustomTextFieldWidget(
                  hintText: getTranslated('discount_hint', context),
                  controller: couponDiscountController.extraDiscountController,
                  textInputType: TextInputType.number,
                  border: true,
                  maxSize: couponDiscountController.discountTypeIndex == 1? 2 : null,
                  isAmount: true,
                ),
                title: couponDiscountController.discountTypeIndex == 1?
                getTranslated('discount_percentage', context):
                  getTranslated('discount_amount', context),
                requiredField: true,
            ),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(children: [
                  Expanded(child: CustomButtonWidget(btnTxt: getTranslated('cancel', context),
                      backgroundColor: Theme.of(context).hintColor,
                      onTap: ()=>Navigator.pop(context))),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(child: CustomButtonWidget(btnTxt: getTranslated('apply', context),
                  onTap: () async{
                    if((double.tryParse(couponDiscountController.extraDiscountController.text) ?? 0) <= 0) {
                      Navigator.pop(Get.context!);
                      showCustomSnackBarWidget(getTranslated('discount_amount_must_be_grater_then', Get.context!), Get.context!, sanckBarType: SnackBarType.warning, isToaster: true);
                    } else {

                      couponDiscountController.applyCouponCodeAndExtraDiscount(context, payable);
                      await Future.delayed(const Duration(milliseconds: 500));
                      Provider.of<CartController>(Get.context!, listen: false).setUpdatePaidAmount(true, isUpdate: true);
                      Navigator.pop(Get.context!);
                    }

                  },)),
                ],),
              )
          ],),);
        }
      ),
    );
  }
}
