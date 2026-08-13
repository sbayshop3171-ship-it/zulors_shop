
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/vacation_calender_widget.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class VacationDialogWidget extends StatelessWidget {
  final String icon;
  final String? title;
  final TextEditingController vacationNote;
  final Function onYesPressed;


  final TextEditingController? note;
  const VacationDialogWidget({super.key, required this.icon, this.title, required this.vacationNote, required this.onYesPressed, this.note,});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
        insetPadding: const EdgeInsets.all(30),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Consumer<ShopController>(
          builder: (context, shop,_) {
            return SizedBox(width: 500, child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(mainAxisSize: MainAxisSize.min, children: [


                  Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
                    child: Row(children: [
                        Flexible(child: Text(getTranslated('please_select_vacation_date_range', context)!, maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),)),
                      ],
                    ),
                  ),

                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: ()=> showDialog(context: context, builder: (_)=> const VacationCalenderWidget()),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                            color:  Theme.of(context).primaryColor.withValues(alpha:.08),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(shop.startDate == 'Start Date' ? getTranslated('start_date', Get.context!)! :  shop.startDate, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                              child: Icon(Icons.arrow_forward_rounded,size: Dimensions.iconSizeDefault,

                                  color:  Theme.of(context).primaryColor),
                            ),
                            Text(shop.endDate == 'End Date' ? getTranslated('end_date', Get.context!)! : shop.endDate, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslated('vacation_note', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: Dimensions.paddingSizeSmall,),
                      CustomTextFieldWidget(border: true,
                        hintText: 'note',
                        maxLine: 2,
                        controller: vacationNote,
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(children: [
                    Expanded(child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: CustomButtonWidget(
                        btnTxt: getTranslated('no',context),
                        backgroundColor: Theme.of(context).hintColor,
                        isColor: true,
                      ),
                    )),
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    Expanded(child: CustomButtonWidget(
                      btnTxt: getTranslated('yes',context),
                      onTap: () =>  onYesPressed(),
                    )),

                  ])
                ])),
            );
          }
        ));
  }
}