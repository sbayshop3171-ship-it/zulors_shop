import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/addProduct/screens/add_product_screen.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/screens/shop_screen.dart';
import 'package:zulors_shop_vendor/features/wallet/screens/wallet_screen.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class CustomTutorialDialog extends StatelessWidget {
  const CustomTutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    return Stack(
      children: [
        Positioned(
          bottom: 165,
          left: Dimensions.paddingSizeDefault,
          right: Dimensions.paddingSizeDefault,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width - 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(Dimensions.radiusDefault),
                  topLeft: const Radius.circular(Dimensions.radiusDefault),
                  bottomLeft: Radius.circular(isLtr ? 0 : Dimensions.radiusDefault),
                  bottomRight: Radius.circular(isLtr ? Dimensions.radiusDefault : 0),
                ),
                color: Theme.of(context).cardColor,
              ),
              child: Consumer<ShopController>(
                  builder: (context, shopController, _) {
                    double completionPercentage = ((shopController.shopModel?.setupGuideApp!.values.where((v) => v == 1).length ?? 0) / (shopController.shopModel?.setupGuideApp?.length ?? 0)) * 100;
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(Dimensions.radiusDefault),
                              topLeft: Radius.circular(Dimensions.radiusDefault),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTranslated('setup_start_your_selling', context) ?? '',
                                        style: robotoBold.copyWith(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: Dimensions.fontSizeLarge,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Text(
                                        getTranslated('setup_and_start_managing', context) ?? '',
                                        style: robotoRegular.copyWith(
                                          color: Theme.of(context).textTheme.headlineLarge?.color,
                                          fontSize: Dimensions.fontSizeDefault,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                CircularProgressWithPercentage(progress: completionPercentage / 100),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: (shopController.shopModel?.setupGuideApp?.length ?? 0) +1,
                              itemBuilder: (context, index) {
                                int length =  (shopController.shopModel?.setupGuideApp?.length ?? 0) +1;
                                String? key;
                                bool? isCompleted;

                                if(index < length-1) {
                                  key = shopController.shopModel?.setupGuideApp?.keys.elementAt(index);
                                  isCompleted = shopController.shopModel?.setupGuideApp?[key] == 1;
                                }
                                return
                                (index+1 == length) ?
                                const SizedBox(height: Dimensions.paddingSizeButton) :
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Dimensions.paddingSizeSmall,
                                    horizontal: Dimensions.paddingSizeMedium,
                                  ),
                                  child: TutorialItemWidget(
                                    keyName: key,
                                    isActive: isCompleted,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall)
                      ],
                    );
                  }
              ),
            ),
          ),
        ),


        Positioned(
          bottom: 180,
          right: isLtr ? Dimensions.paddingSizeDefault + Dimensions.paddingSizeMedium : null ,
          left: isLtr ? null : Dimensions.paddingSizeDefault ,
          child: Material(
            child: Consumer<ShopController>(
                builder: (context, shopController, _) {
                  return InkWell(
                    onTap: () {
                      final setupGuide = (shopController.shopModel?.setupGuideApp ?? {});

                      for (var entry in setupGuide.entries) {
                        String keyName = entry.key;
                        int value = entry.value;
                        if(value == 0) {
                          Navigator.of(context).pop();
                          Provider.of<ShopController>(context, listen: false).updateTutorialFlow(keyName);
                          Provider.of<ShopController>(context, listen: false).updateSetupGuideApp(keyName, 1);
                        }
                        if(keyName == 'shop_setup' && value == 0) {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 0)));
                          break;
                        } else if (keyName == 'order_setup' && value == 0) {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 2)));
                          break;
                        } else if (keyName == 'withdraw_setup' && value == 0) {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> const WalletScreen()));
                          break;
                        } else if (keyName == 'add_new_product' && value == 0) {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> const AddProductScreen()));
                          break;
                        } else if (keyName == 'payment_information' && value == 0) {
                          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 1)));
                          break;
                        }else{
                          continue;
                        }
                      }
                    },

                    child: Container(
                      height: 35,
                      width: 125,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getTranslated('lets_start', context) ?? '',
                              style: robotoBold.copyWith(
                                color: Theme.of(context).highlightColor,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Icon(Icons.arrow_forward, color: Theme.of(context).highlightColor)
                          ],
                        ),
                      )
                    ),
                  );
                }
            ),
          ),
        )
      ],
    );
  }
}

class CircularProgressWithPercentage extends StatelessWidget {
  final double progress;

  const CircularProgressWithPercentage({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onTertiaryContainer),
          ),
        ),
        Text(
          "${(progress * 100).toInt()}%",
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ],
    );
  }
}

class TutorialItemWidget extends StatelessWidget {
  final String? keyName;
  final bool? isActive;
  const TutorialItemWidget({super.key, this.keyName, this.isActive});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        if(keyName == 'shop_setup') {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 0)));
        } else if (keyName == 'order_setup') {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 2)));
        } else if (keyName == 'withdraw_setup') {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const WalletScreen()));
        } else if (keyName == 'add_new_product') {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const AddProductScreen()));
        } else if (keyName == 'payment_information') {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 1)));
        }
        if(!(isActive ?? false)) {
          Provider.of<ShopController>(context, listen: false).updateTutorialFlow(keyName ?? '');
          Provider.of<ShopController>(context, listen: false).updateSetupGuideApp(keyName ?? '', 1);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: 0.15),
          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 20, width: 20,
                  child: Checkbox(
                    value: isActive,
                    onChanged: (_) {}
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Text(
                  getTranslated(keyName, context) ?? '',
                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialCountWidget extends StatelessWidget {
  const TutorialCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopController>(
        builder: (context, shopInfo, child) {
          return Container(
            height: 20, width: 20,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.error
            ),
            child: Center(
              child: Text(
                (shopInfo.shopModel?.setupGuideApp?.values.where((value) => value == 0).length).toString(),
                style: robotoBold.copyWith(color: Theme.of(context).highlightColor, fontSize: Dimensions.fontSizeSmall),
              ),
            ),
          );
        }
    );
  }
}