import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import '../../../main.dart' show Get;

class GeneratesLeftCount extends StatelessWidget {
  const GeneratesLeftCount({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider.of<SplashController>(Get.context!,listen: false).configModel?.isAiFeatureActive == 1 ?  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            color: Theme.of(context).cardColor
          ),
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
          child: Consumer<AiController>(
            builder: (context, aiController, child){
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Text('${aiController.genLimit}',
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  SizedBox(width: Dimensions.paddingSizeExtraSmall),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: Text(getTranslated('generates_left', context) ?? '',
                      style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),

                  Icon(Icons.auto_awesome, color: Colors.blue),

                ],
              );
            }
          ),
        )
      ],
    ) : SizedBox();
  }
}
