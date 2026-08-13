import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/models/language_model.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  const LanguageWidget({super.key, required this.languageModel, required this.localizationController, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
        boxShadow: [BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0):
        Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!, blurRadius: 5, spreadRadius: 1)],
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: (){
          localizationController.setLanguage(Locale(
            AppConstants.languages[index].languageCode!,
            AppConstants.languages[index].countryCode,
          ), index);

        },

        child: Stack(children: [

          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(height: 65, width: 65,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  border: Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!, width: 1)),
                alignment: Alignment.center,
                child: Image.asset(languageModel.imageUrl!, width: 36, height: 36)),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(languageModel.languageName!, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
            ]),
          ),

          localizationController.languageIndex == index ?
          Positioned(top: 10, right: 10,
            child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 25),
          ) : const SizedBox(),

        ]),
      ),
    );
  }
}
