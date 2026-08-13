import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class DeleteAccountWarningDialogWidget extends StatelessWidget {
const DeleteAccountWarningDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Provider.of<ThemeController>(context).darkTheme ?
      Theme.of(context).highlightColor.withValues(alpha: 0.9) :
      Theme.of(context).highlightColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 30),
                SizedBox(width: 52,height: 52,
                  child: Image.asset(Images.accountDeleteWarning),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 13, Dimensions.paddingSizeLarge, 0),
                  child: Text(getTranslated('warning', context)!,
                      style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                      textAlign: TextAlign.center),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 13, Dimensions.paddingSizeLarge,0),
                  child: Text(getTranslated('please_check_before_delete_your', context)!,
                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                      textAlign: TextAlign.center),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),
              ]),
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: SizedBox(width: 18,child: Image.asset(Images.cross, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
