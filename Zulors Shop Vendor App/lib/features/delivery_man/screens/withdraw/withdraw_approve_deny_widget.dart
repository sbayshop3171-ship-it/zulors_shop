

import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';

class ApproveAndDenyWidget extends StatelessWidget {
  final String? icon;
  final String? title;
  final Function? onYesPressed;
  final TextEditingController? note;
  final bool isApprove;
  const ApproveAndDenyWidget({super.key, this.icon, this.title, this.onYesPressed, this.note, this.isApprove = false});

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
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall,
                bottom: Dimensions.paddingSizeLarge),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Image.asset(icon!,width: Dimensions.logoHeight,),
                ),
              ),

              title != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  title!, textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
                child: CustomTextFieldWidget(
                  border: true,
                  hintText: getTranslated('note', context),
                  controller: note,
                  maxLine: 3,
                ),
              ),

              CustomButtonWidget(
                btnTxt: getTranslated('submit',context),
                onTap: () =>  onYesPressed!(),
              )
            ])),
        ));
  }
}
