import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_date_picker_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/vat_management/controllers/vat_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

import '../../../main.dart';

class VatFilterBottomSheet extends StatelessWidget {
  const VatFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Consumer<VatController>(
        builder: (context, vatController, child) {
          return Column(mainAxisSize: MainAxisSize.min,children: [

            Align(
              alignment: Alignment.center,
              child: Container(
                height: 4, width: 40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
              ),
            ),

            Transform.translate(
              offset: Offset(0, -7),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.cancel_outlined,
                    size: Dimensions.iconSizeMedium,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
           // SizedBox(height: Dimensions.paddingSizeSmall),

            Row(
              children: [
                Expanded(flex: 1, child: SizedBox()),

                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault,
                        top: Dimensions.paddingSizeExtraLarge,),
                        child: Text(getTranslated('filter_date', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),),),
                    ],
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      (vatController.startDate != null || vatController.endDate != null )  ?
                      InkWell(
                        onTap: () async {
                          vatController.resetReviewData();
                          await Provider.of<VatController>(context, listen: false).getVatReportList(1);
                          if(context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Row(children: [
                          SizedBox(width: 20, child: Image.asset(Images.reset)),
                          Text('${getTranslated('reset', context)}', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                          const SizedBox(width: Dimensions.paddingSizeDefault,)
                        ]),
                      ) : SizedBox(),
                    ],
                  ))
              ],
            ),

            SizedBox(height: Dimensions.paddingSizeSmall),


            Container(
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  Expanded(child: CustomDatePickerWidget(
                    fromClearance: true,
                    title: getTranslated('start_date', context),
                    image: Images.calenderIcon,
                    text: vatController.startDate != null ?
                    vatController.dateFormat.format(vatController.startDate!).toString() : getTranslated('select_date', context),
                    selectDate: () {
                      vatController.selectDate("start", context);
                    },
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomDatePickerWidget(
                    fromClearance: true,
                    title: getTranslated('end_date', context),
                    image: Images.calenderIcon,
                    text: vatController.endDate != null ?
                    vatController.dateFormat.format(vatController.endDate!).toString() : getTranslated('select_date', context),
                    selectDate: () => vatController.selectDate("end", context),
                  )),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                isLoading: vatController.isLoading!,
                buttonHeight: 50,
                btnTxt: getTranslated('filter', context),
                onTap: () async {
                  if ((vatController.startDate != null &&  vatController.endDate == null) || (vatController.startDate == null &&  vatController.endDate != null)) {
                    showCustomToast(message: getTranslated('select_start_and_end_time', context)!, context:  context, isSuccess: false);
                  } else if(vatController.startDate != null && vatController.endDate != null && !isEndDateValid(vatController.startDate!, vatController.endDate!)) {
                    showCustomToast(message: getTranslated('end_date_should_not_before_start_date', context)!, context:  context, isSuccess: false);
                  } else {
                    await vatController.getVatReportList(1, startDate: vatController.startDate.toString(), endDate: vatController.endDate.toString());
                    vatController.setFilterActive(true);
                    Navigator.of(Get.context!).pop();
                  }
                }
              ),
            ),

          ]);
        }
      ),
    );
  }
  bool isEndDateValid(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }


}