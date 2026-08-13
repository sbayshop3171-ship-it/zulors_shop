
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/shipping/controllers/shipping_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class ConfirmationDialogWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final String? description;
  final Function onYesPressed;
  final bool isLogOut;
  final bool refund;
  final Color? color;
  final TextEditingController? note;
  final bool? isLoading;
  const ConfirmationDialogWidget({super.key, required this.icon, this.title, this.description, required this.onYesPressed, this.isLogOut = false, this.refund = false, this.note, this.color, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SizedBox(width: 500, child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Image.asset(icon, width: 50, height: 50),
          ),

          title != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              title!, textAlign: TextAlign.center,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: color ?? Colors.red),
            ),
          ) : const SizedBox(),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column( children: [
                Text(description??'', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center,),
                refund? TextFormField(
                  controller: note,
                  decoration: InputDecoration(
                    hintText: getTranslated('note', context),
                    hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).hintColor),
                  ),
                  textAlign: TextAlign.center,

                ):const SizedBox()
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Consumer<ShippingController>(builder: (context, shippingProvider, child) {
            return !shippingProvider.isLoading ? Row(children: [
              Expanded(child: InkWell(
                splashColor: Colors.transparent,
                onTap: () => Navigator.pop(context),
               child: CustomButtonWidget(
                 btnTxt: getTranslated('no',context),
                 backgroundColor: Theme.of(context).hintColor,
                 isColor: true,
               ),
              )),
              const SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(child: (isLoading ?? false) ?
              const Center(child: SizedBox(width: 35, child: CircularProgressIndicator())) : CustomButtonWidget(
                btnTxt: getTranslated('yes',context),
                onTap: () =>  onYesPressed(),
              )),
            ]) : const Center(child: CircularProgressIndicator());
        }),
      ])),
    ));
  }
}