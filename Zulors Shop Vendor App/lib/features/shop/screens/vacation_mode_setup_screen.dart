import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_date_picker_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/vacation_model.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_details_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import '../../../main.dart';

class VacationModeScreen extends StatefulWidget {
  const VacationModeScreen({super.key});

  @override
  VacationModeScreenState createState() => VacationModeScreenState();
}

class VacationModeScreenState extends State<VacationModeScreen> {

  final FocusNode _vacationNoteFocus = FocusNode();

  final TextEditingController _vacationNoteController = TextEditingController();

  ShopController shopController =  Provider.of<ShopController>(Get.context!, listen: false);

  void setVacationNote() {
    _vacationNoteController.text =  Provider.of<ShopController>(context, listen: false).vacationModel?.vacationNote ?? '';
  }

  @override
  void initState() {
    super.initState();
    shopController.setVacationDurationType(shopController.vacationModel?.vacationDurationType ??  'one_day', isUpdate: false);
    if(shopController.vacationModel?.vacationDurationType == null) {
      shopController.set24HourVacation(isUpdate: false);
    }
    _vacationNoteController.addListener(_updateLength);
  }

  void _updateLength() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('vacation_mode_setup',context)),

      body: Consumer<ShopController>(
        builder: (context, shop, child) {
          return Consumer<ShopController>(
            builder: (context, shopController, child) {
              return Column(children: [

                Expanded(child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                      topRight: Radius.circular(Dimensions.paddingSizeDefault)
                    )
                  ),

                  child: ListView(
                    physics: const BouncingScrollPhysics(), children: [

                    Container(
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeMedium, right: Dimensions.paddingSizeMedium),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeMedium),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),


                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getTranslated('vacation_mode', context) ?? '',
                            style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(getTranslated('if_you_turn_on_your', context) ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall)
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          ShopSettingWidget(
                            title: 'statuss',
                            borderColor: Theme.of(context).hintColor.withValues(alpha: 0.20),
                            mode: shopController.vacationModel?.vacationStatus ?? false,
                            onTap: (value){
                              shopController.setVacationStatus();
                            }
                          )

                        ],
                      ),
                    ),


                    Container(
                      margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeMedium, right: Dimensions.paddingSizeMedium),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeMedium),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitledBorder(
                            borderColor: Theme.of(context).hintColor.withValues(alpha: 0.20),
                            content: Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                              child: RadioGroup<String>(
                                groupValue: shopController.vacationDurationType,
                                onChanged: (value) {
                                  if (value == null) return;
                                  shopController.setVacationDurationType(value);
                                  if (value == 'one_day') {
                                    shopController.set24HourVacation();
                                  }
                                },
                                child: Row(children: [

                                  SizedBox(height: Dimensions.paddingSizeDefault, width: Dimensions.paddingSizeDefault, child: Radio<String>(
                                    value: 'one_day',
                                    fillColor: WidgetStateProperty.resolveWith<Color>(
                                          (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return Theme.of(context).primaryColor;
                                        }
                                        return Theme.of(context).hintColor.withValues(alpha: 0.50);
                                      },
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    splashRadius: 0,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Text(getTranslated('24_hours', context) ?? '', style: robotoRegular.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  )),
                                  const Spacer(),

                                  SizedBox(height: Dimensions.paddingSizeDefault, width: Dimensions.paddingSizeDefault, child: Radio<String>(
                                    value: 'until_change',
                                    fillColor: WidgetStateProperty.resolveWith<Color>(
                                          (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return Theme.of(context).primaryColor;
                                        }
                                        return Theme.of(context).hintColor.withValues(alpha: 0.50);
                                      },
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    splashRadius: 0,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Text(getTranslated('until_i_change', context) ?? '', style: robotoRegular.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  )),
                                  const Spacer(),

                                  SizedBox(height: Dimensions.paddingSizeDefault, width: Dimensions.paddingSizeDefault, child: Radio<String>(
                                    value: 'custom',
                                    fillColor: WidgetStateProperty.resolveWith<Color>(
                                          (Set<WidgetState> states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return Theme.of(context).primaryColor;
                                        }
                                        return Theme.of(context).hintColor.withValues(alpha: 0.50);
                                      },
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    splashRadius: 0,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Text(getTranslated('custom', context) ?? '', style: robotoRegular.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  )),
                                ]),
                              ),
                            ),
                            title: getTranslated('vacation_duration_type', context) ?? '',
                          ),
                          if(shopController.vacationDurationType != 'until_change')
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          if(shopController.vacationDurationType != 'until_change')
                          Row(
                            children: [
                              Expanded(child: CustomDatePickerWidget(
                                borderColor: Theme.of(context).hintColor.withValues(alpha: 0.20),
                                fromClearance: true,
                                fromVacation: true,
                                title: getTranslated('start_date', context),
                                image: Images.calenderIcon,
                                text: shopController.startDateTime != null ?
                                shopController.dateFormat.format(shopController.startDateTime!).toString() :
                                shopController.vacationModel?.vacationStartDate  != null ?
                                shopController.dateFormat.format(DateTime.tryParse(shopController.vacationModel?.vacationStartDate ?? '')!).toString()
                                : getTranslated('select_date', context),
                                selectDate: () {
                                  shopController.selectDateTime("start", shopController.vacationDurationType == 'one_day', context, dateTime: DateTime.tryParse(shopController.vacationModel?.vacationStartDate ?? ''));
                                },
                              )),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(child: CustomDatePickerWidget(
                                borderColor: Theme.of(context).hintColor.withValues(alpha: 0.20),
                                fromClearance: true,
                                fromVacation: true,
                                title: getTranslated('end_date', context),
                                image: Images.calenderIcon,
                                text: shopController.endDateTime != null ?
                                shopController.dateFormat.format(shopController.endDateTime!).toString() :
                                (shopController.vacationModel?.vacationEndDate != null && DateTime.tryParse(shopController.vacationModel!.vacationEndDate!) != null) ?
                                   shopController.dateFormat.format(DateTime.parse(shopController.vacationModel?.vacationEndDate ?? ''))
                                : getTranslated('select_date', context),
                                selectDate: () => shopController.selectDateTime("end", shopController.vacationDurationType == 'one_day', context, dateTime: DateTime.tryParse(shopController.vacationModel?.vacationEndDate ?? '')),
                              )),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          CustomTextFieldWidget(
                            borderColor: Theme.of(context).hintColor.withValues(alpha: 0.20),
                            variant: true,
                            required: false,
                            prefixIconImage: Images.vacationNote,
                            formProduct: true,
                            border: true,
                            maxLine: 3,
                            textInputType: TextInputType.text,
                            focusNode: _vacationNoteFocus,
                            controller: _vacationNoteController,
                            hintText: getTranslated('type_your_note', context),
                            labelText: getTranslated('vacation_note', context),
                            showIconDecorationColor: false,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(_vacationNoteController.text.length.toString(), style: robotoRegular.copyWith(color: _vacationNoteController.text.length >= 100 ? Theme.of(context).colorScheme.error : Theme.of(context).hintColor)),
                              Text('/', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                              Text('100', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                            ],
                          ),


                        ]
                      ),
                    ),

                  ]),
                )),


                Container(height: 60,
                  color: Theme.of(context).cardColor,
                  child: Consumer<ShopController>(
                    builder: (context, shopProvider, _) {
                      return Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButtonWidget(
                                backgroundColor: Theme.of(context).hintColor,
                                btnTxt: getTranslated('reset', context),
                                onTap: () {
                                  setVacationNote();
                                  shopProvider.setVacationData(shopProvider.shopModel, isUpdate: true);
                                }
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(
                              child: shopProvider.isLoading?
                              const Center(
                                child: CircularProgressIndicator())
                                : CustomButtonWidget(
                                  btnTxt: getTranslated('save', context),
                                  onTap: () {
                                    if(_vacationNoteController.text.length > 100) {
                                      showCustomSnackBarWidget(getTranslated('vacation_note_is_too_large', context), context, sanckBarType: SnackBarType.warning);
                                    } else if ((shopProvider.vacationDurationType == 'one_day' || shopProvider.vacationDurationType == 'custom') && (shopController.vacationModel?.vacationStartDate == null)) {
                                      showCustomSnackBarWidget(getTranslated('start_date_is_required', context), context, sanckBarType: SnackBarType.warning);
                                    }  else if ((shopProvider.vacationDurationType == 'one_day' || shopProvider.vacationDurationType == 'custom') && (shopController.vacationModel?.vacationEndDate == null)) {
                                      showCustomSnackBarWidget(getTranslated('end_date_is_required', context), context, sanckBarType: SnackBarType.warning);
                                    } else if (shopController.startDateTime != null && shopController.endDateTime != null && shopController.endDateTime!.isBefore(shopController.startDateTime!)) {
                                      showCustomSnackBarWidget(getTranslated('end_date_should_not_before_start_date', context), context, sanckBarType: SnackBarType.warning);
                                    } else{
                                      shopController.shopVacation(
                                        context,
                                        VacationModel(
                                          vacationStatus: shopController.vacationModel?.vacationStatus,
                                          vacationNote: _vacationNoteController.text,
                                          vacationDurationType: shopController.vacationDurationType,
                                          vacationEndDate: shopController.vacationModel?.vacationEndDate,
                                          vacationStartDate: shopController.vacationModel?.vacationStartDate
                                        )
                                      );

                                    }
                                  }
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  )
                )

              ],
              );
            }
          );
        },
      ),
    );
  }
}


class TitledBorder extends StatelessWidget {
  final Widget content;
  final String title;
  final bool isRequired;
  final Color? borderColor;
  const TitledBorder({super.key, required this.content, required this.title, this.isRequired = true, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(color: borderColor ?? Theme.of(context).hintColor, width: 1.5),
          ),
          child: content,
        ),


        Positioned(
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: Dimensions.fontSizeDefault,
                ),
                children: <InlineSpan>[
                  TextSpan(text: title),
                  if(isRequired)
                  TextSpan(
                    text: getTranslated(' *', context) ?? '',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ),

      ],
    );
  }
}
