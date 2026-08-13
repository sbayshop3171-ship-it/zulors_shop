import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class DeleteConfirmationDialogWidget extends StatelessWidget {
  final int? clearanceId;
  final int? index;
  const DeleteConfirmationDialogWidget(this.clearanceId, this.index, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
          child: Container(
            //padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
            ),
            child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [

                      const SizedBox(height: 30),
                      SizedBox(width: 52,height: 52,
                        child: Image.asset(clearanceId != null ? Images.clearanceSingleRemove : Images.clearanceAllRemove),
                      ),

                      Padding(
                        padding: const  EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 13, Dimensions.paddingSizeLarge, 0),
                        child: Text(clearanceId== null ? getTranslated('are_you_sure_remove_all_item', context)! :  getTranslated('are_you_sure_remove_this_item', context)! ,
                            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                            textAlign: TextAlign.center
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, 13, Dimensions.paddingSizeLarge,0),
                        child: Text( clearanceId== null ? getTranslated('once_you_remove_all_item', context)! : getTranslated('once_you_remove_the_item', context)!,
                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                          textAlign: TextAlign.center),
                      ),

                      Consumer<ClearanceSaleController>(
                        builder: (context, clearanceController, child) {
                          return SizedBox(height: 80,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,24,Dimensions.paddingSizeDefault,Dimensions.paddingSizeDefault),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Row(children: [
                                  Expanded(
                                    child: clearanceController.isLoading ?
                                    const Center(
                                      child: SizedBox(
                                        height:  30, width: 30,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ) :
                                    CustomButtonWidget(borderRadius: 15,
                                      btnTxt: getTranslated('yes', context),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                      fontColor: Colors.white,
                                      isColor: true,
                                      onTap: () async {
                                        if(clearanceId != null) {
                                          await Provider.of<ClearanceSaleController>(context,listen: false).deleteClearanceSaleProductList(clearanceId, index);
                                        } else {
                                          await Provider.of<ClearanceSaleController>(context,listen: false).deleteClearanceSaleAllProduct();
                                        }
                                        Navigator.of(Get.context!).pop();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  Expanded(
                                    child: CustomButtonWidget(borderRadius: 15,
                                      btnTxt: getTranslated('no', context),
                                      isColor: true,
                                      fontColor: Theme.of(context).textTheme.bodyLarge?.color,
                                      backgroundColor: Theme.of(context).hintColor.withValues(alpha:.25),
                                      onTap: () => Navigator.pop(context),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        }
                      ),
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
          ),
        ),
      ),
    );
  }
}
