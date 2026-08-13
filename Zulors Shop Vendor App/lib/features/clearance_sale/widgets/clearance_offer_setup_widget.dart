import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_date_picker_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_sale_section_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/time_picker_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ClearanceOfferSetupWidget extends StatelessWidget {
  const ClearanceOfferSetupWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return Consumer<ClearanceSaleController>(
        builder: (context, clearanceController, child) {
          return AbsorbPointer(
            absorbing: false,
            child: ClearanceSaleSectionWidget(
              title: getTranslated('setup_offer_logic', context)!,
              childrens: [

                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  child: Row(
                    children: [
                      Expanded(child: CustomDatePickerWidget(
                        fromClearance: true,
                        title: getTranslated('start_date', context),
                        image: Images.calenderIcon,
                        text: clearanceController.startDate != null ?
                        clearanceController.dateFormat.format(clearanceController.startDate!).toString() : getTranslated('select_date', context),
                        selectDate: () {

                          clearanceController.selectDate("start", context);
                        },
                      )),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(child: CustomDatePickerWidget(
                        fromClearance: true,
                        title: getTranslated('end_date', context),
                        image: Images.calenderIcon,
                        text: clearanceController.endDate != null ?
                        clearanceController.dateFormat.format(clearanceController.endDate!).toString() : getTranslated('select_date', context),
                        selectDate: () => clearanceController.selectDate("end", context),
                      )),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  child: Text(getTranslated('discount_type', context,)!, style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.50))
                  ),
                  child: RadioGroup<int>(
                    groupValue: clearanceController.selectedDiscountType,
                    onChanged: (value) {
                      if (value != null) clearanceController.setSelectedDiscountType(value);
                    },
                    child: Row(children: [

                      InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        onTap: () => clearanceController.setSelectedDiscountType(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: clearanceController.selectedDiscountType == 1
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                : Colors.transparent,
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            SizedBox(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, child: Radio<int>(value: 1)),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text(getTranslated('flat_discount', context)!, style: robotoTitleRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                          ]),
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          onTap: () => clearanceController.setSelectedDiscountType(2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: clearanceController.selectedDiscountType == 2
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                  : Colors.transparent,
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              SizedBox(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, child: Radio<int>(value: 2)),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(getTranslated('product_wise_discount', context)!, style: robotoTitleRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              )),
                            ]),
                          ),
                        ),
                      ),
                    ],
                    ),
                  ),
                ),


                if(clearanceController.selectedDiscountType == 1)...[
                  Padding(
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                      child: Text(getTranslated('discount_amount', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault,  color: Theme.of(context).textTheme.bodyLarge?.color))
                  ),
                ],

                clearanceController.selectedDiscountType == 1 ?
                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.50))
                  ),
                  child: Row(children: [

                      Expanded(
                        child: CustomTextFieldWidget(
                            border: true,
                            controller: clearanceController.discountController,
                            // focusNode: _taxNode,
                            // nextNode: _discountNode,
                            isAmount: true,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.number,
                            hintText: getTranslated('discount_amount', context)!,
                            maxSize : 2
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(Dimensions.radiusDefault),
                            topRight: Radius.circular(Dimensions.radiusDefault),
                          ),
                          color: Theme.of(context).primaryColor.withValues(alpha:0.25),
                        ),
                        child:  Center(child: Text('%', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                      )

                    ]),
                ) : const SizedBox(),



                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  child: Text(getTranslated('offer_active_time', context)!, style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  )),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.50))
                  ),
                  child: RadioGroup<int>(
                    groupValue: clearanceController.selectedOfferActiveType,
                    onChanged: (value) {
                      if (value != null) clearanceController.setSelectedOfferActiveType(value);
                    },
                    child: Row(children: [

                      InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        onTap: () => clearanceController.setSelectedOfferActiveType(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            color: clearanceController.selectedOfferActiveType == 1
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                : Colors.transparent,
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [

                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            SizedBox(height: 20, width: 20, child: Radio<int>(value: 1)),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text(getTranslated('always_active', context)!, style: robotoTitleRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                          ]),
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          onTap: () => clearanceController.setSelectedOfferActiveType(2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              color: clearanceController.selectedOfferActiveType == 2
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                  : Colors.transparent,
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [

                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              SizedBox(height: 20, width: 20, child: Radio<int>(value: 2)),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Text(getTranslated('specific_time_in_a_day', context)!, style: robotoTitleRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              )),
                            ]),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),


                clearanceController.selectedOfferActiveType == 2 ?
                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.50))
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Text(getTranslated('from', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      TimePickerWidget(
                        title: getTranslated('open_time', context)!,
                        time: clearanceController.offerStartTime,
                        onTimeChanged: (time){
                          clearanceController.setOfferStartTime = time;
                        },
                      ),

                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(getTranslated('till', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      TimePickerWidget(
                        title: getTranslated('close_time', context)!,
                        time: clearanceController.offerEndTime,
                        onTimeChanged: (time) => clearanceController.setServiceEndTime = time,
                      ),
                    ],
                  ),
                ) : const SizedBox(),



                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        width: 250,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        height: 80,child: Row(children: [
                      Expanded(child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          clearanceController.resetConfig();
                        },
                        child: CustomButtonWidget(
                          isColor: true,
                          btnTxt: '${getTranslated('reset', context)}',
                          backgroundColor: Theme.of(context).cardColor,
                          fontColor: Theme.of(context).primaryColor,
                          borderColor: Theme.of(context).primaryColor,
                        ),
                      )),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      Expanded(
                          child: clearanceController.isConfigLoading ?
                          const Center(
                            child: SizedBox(
                              height:  30, width: 30,
                              child: CircularProgressIndicator(),
                            ),
                          ) :
                          CustomButtonWidget(
                            btnTxt:  getTranslated('save', context),
                            onTap: () {
                              if(clearanceController.startDate == null) {
                                showCustomSnackBarWidget(getTranslated('start_date_is_required', context), sanckBarType: SnackBarType.warning, context, isError: false);
                              } else if (clearanceController.endDate == null) {
                                showCustomSnackBarWidget(getTranslated('end_date_is_required', context), sanckBarType: SnackBarType.warning, context, isError: false);
                              } else if (!clearanceController.isEndDateValid(clearanceController.startDate!, clearanceController.endDate!)) {
                                showCustomSnackBarWidget(getTranslated('end_date_should_not_before_start_date', context), sanckBarType: SnackBarType.warning, context, isError: false);
                              } else if (clearanceController.selectedOfferActiveType == 2 && (clearanceController.offerStartTime == null || clearanceController.offerStartTime == null)) {
                                showCustomSnackBarWidget(getTranslated('select_start_and_end_time', context), sanckBarType: SnackBarType.warning, context, isError: false);
                              } else if (clearanceController.selectedOfferActiveType == 2 && !clearanceController.isEndTimeValid(clearanceController.offerStartTime!, clearanceController.offerEndTime!)) {
                                showCustomSnackBarWidget(getTranslated('end_time_cannot_be', context), sanckBarType: SnackBarType.warning, context, isError: false);
                              }  else {
                                clearanceController.saveClearanceConfigData();
                              }
                            },
                          )
                      ),
                    ])
                    )
                  ],
                )



              ],
            ),
          );
        }
    );
  }
}
