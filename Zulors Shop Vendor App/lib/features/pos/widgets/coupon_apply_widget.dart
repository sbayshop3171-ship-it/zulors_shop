import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/coupon_discount_controller.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/customer_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_field_with_title_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';

class CouponDialogWidget extends StatelessWidget {
  final double extraDiscountAmount;
  final double productDiscountAmount;
  const CouponDialogWidget({super.key, required this.extraDiscountAmount, required this.productDiscountAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog( surfaceTintColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      child: Consumer<CouponDiscountController>(
          builder: (context, couponDiscountController, _) {
            CartController cartController = Provider.of<CartController>(context, listen: false);
            return Container(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              height: 210, child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [

                CustomFieldWithTitleWidget(
                  customTextField: CustomTextFieldWidget(
                    hintText: getTranslated('coupon_code_hint', context),
                    controller:couponDiscountController.couponController,
                    border: true,
                  ),
                  title: getTranslated('coupon_code', context),
                  requiredField: true,
                ),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    Expanded(child: CustomButtonWidget(
                      btnTxt: getTranslated('cancel', context),
                      backgroundColor: Theme.of(context).hintColor,
                      onTap: ()=> Navigator.pop(context))),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    Expanded(child: CustomButtonWidget(btnTxt: getTranslated('apply', context),
                      onTap: (){
                      CustomerController customerController = Provider.of<CustomerController>(context, listen: false);

                      if(couponDiscountController.couponController.text.trim().isNotEmpty){
                        if (kDebugMode) {
                          print('${couponDiscountController.couponController.text.trim()}/'
                            '${customerController.customerId}/'
                            '${cartController.amount}');
                        }
                        couponDiscountController.getCouponDiscount(
                          context,
                          couponDiscountController.couponController.text.trim(),
                          customerController.customerId,
                          cartController.amount - productDiscountAmount,
                          extraDiscountAmount
                        );
                      }
                      Navigator.pop(context);
                    },)),
                  ],),
                )
              ],),);
          }
      ),
    );
  }
}
