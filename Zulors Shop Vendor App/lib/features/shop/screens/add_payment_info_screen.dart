import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/payment_information_model.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/withdrawal_method_model.dart';
import 'package:zulors_shop_vendor/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_details_widget.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/country_code_helper.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import '../../../main.dart';

class AddPaymentInfoScreen extends StatefulWidget {
  final bool formUpdate;
  final PaymentInfoData? paymentInfoData;
  const AddPaymentInfoScreen({super.key, this.formUpdate = false, this.paymentInfoData});

  @override
  State<AddPaymentInfoScreen> createState() => _AddPaymentInfoScreenState();
}

class _AddPaymentInfoScreenState extends State<AddPaymentInfoScreen> {
  String countryDialCode = '+880';

  final TextEditingController _methodNameController = TextEditingController();

  final FocusNode _methodNameFocus = FocusNode();
  final FocusNode _cNumberFocus = FocusNode();
  ShopController shopController = Provider.of<ShopController>(Get.context!, listen: false);


  @override
  void initState() {
    shopController.resetPaymentInfoData();
    // shopController.setMethodCountryCode(index, countryCode.code ?? '');
    if(widget.formUpdate && widget.paymentInfoData != null) {
      _methodNameController.text = widget.paymentInfoData?.methodName ?? '';
      shopController.setPaymentStatus(widget.paymentInfoData?.isActive ?? false, isUpdate: false);
      shopController.setSelectedPaymentMethod(widget.paymentInfoData?.withdrawMethod?.methodName ?? '');
      setDynamicFieldValues();
    }
    super.initState();
  }

  void setDynamicFieldValues() {
    for(MethodFields methodField in  shopController.paymentMethodFields) {
      if(methodField.inputType == 'date') {
        (widget.paymentInfoData?.methodInfo ?? {}).forEach((key, value) {
          if(key == methodField.inputName) {
            methodField.dateTime = DateTime.tryParse(value);
          }
        });
      } else if (methodField.inputType == 'phone') {
        (widget.paymentInfoData?.methodInfo ?? {}).forEach((key, value) {
          if(key == methodField.inputName) {
            String countryCode = CountryCodeHelper.getCountryCode(value)!;
            methodField.countryCode = countryCode;
            methodField.textEditingController?.text = CountryCodeHelper.extractPhoneNumber(countryCode, value);
          }
        });
      } else {
        (widget.paymentInfoData?.methodInfo ?? {}).forEach((key, value) {
          if(key == methodField.inputName) {
            methodField.textEditingController?.text = value;
          }
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    List<String> paymentMethodList = [];

    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('add_new_payment_info', context)),
      body: Consumer<ShopController>(
        builder: (context, shopInfo, child) {
          paymentMethodList = [];
          paymentMethodList.addAll(shopInfo.withdrawalMethodModel!.data!.map((method) => method.methodName!));

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                  child: SingleChildScrollView (
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              CustomTextFieldWidget(
                                formProduct: true,
                                border: true,
                                isDescription: true,
                                textInputType: TextInputType.name,
                                focusNode: _methodNameFocus,
                                nextNode: _cNumberFocus,
                                hintText: getTranslated('method_name', context),
                                controller: _methodNameController,
                                required: true,
                                showIconDecorationColor: false,
                              ),

                              DropdownDecoratorWidget(
                                child: DropdownButton<String>(
                                  icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                                  hint: Text(
                                    shopInfo.selectedPaymentMethod!.isNotEmpty ? shopInfo.selectedPaymentMethod ?? '' :
                                    getTranslated('select_payment_method', context) ?? '',
                                    style: robotoMedium.copyWith(
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                      fontSize: Dimensions.fontSizeExtraLarge,
                                    ),
                                  ),
                                  items: paymentMethodList.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value, style: robotoMedium),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    shopInfo.setSelectedPaymentMethod(val ?? '');
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                              TitledBorder(
                                title: getTranslated('payment_status', context) ?? '',
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: ShopSettingWidget(
                                    showBorder: false,
                                    title: 'statuss',
                                    mode: shopInfo.selectedPaymentStatus,
                                    onTap: (value) {
                                      shopInfo.setPaymentStatus(value);
                                    }
                                  ),
                                ),
                              ),


                              if(shopInfo.paymentMethodFields.isNotEmpty)
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: shopInfo.paymentMethodFields.length,
                                itemBuilder: (context, index){
                                  if(!widget.formUpdate && shopInfo.paymentMethodFields[index].inputType == 'phone' && shopInfo.paymentMethodFields[index].countryCode == null) {
                                    shopInfo.setMethodCountryCode(index, CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel!.countryCode!).dialCode ?? '+880');
                                  }
                                  return shopInfo.paymentMethodFields[index].inputType != 'date' ?  CustomTextFieldWidget(
                                    formProduct: true,
                                    prefixIconImage: null,
                                    border: true,
                                    controller: shopInfo.paymentMethodFields[index].textEditingController,
                                    isPhoneNumber: shopInfo.paymentMethodFields[index].inputType == 'phone',
                                    countryDialCode: CountryCode.fromCountryCode(Provider.of<SplashController>(context, listen: false).configModel!.countryCode!).dialCode ?? '+880',
                                    hintText: formatField(shopInfo.paymentMethodFields[index].inputName ?? ''),
                                    showCodePicker: shopInfo.paymentMethodFields[index].inputType == 'phone',
                                    onCountryChanged: (CountryCode countryCode) {
                                      shopInfo.setMethodCountryCode(index, countryCode.code ?? '');
                                    },
                                    textInputType : shopInfo.paymentMethodFields[index].inputType == 'email' ? TextInputType.emailAddress : null,
                                    isPassword: shopInfo.paymentMethodFields[index].inputType == 'password',
                                    isAmount: (shopInfo.paymentMethodFields[index].inputType == 'phone' || shopInfo.paymentMethodFields[index].inputType == 'number'  ) ,
                                  ) : TitledBorder(
                                    title: formatField(shopInfo.paymentMethodFields[index].inputName ?? ''),
                                    content: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                              child: Text(
                                                shopInfo.paymentMethodFields[index].dateTime != null ?
                                                DateConverter.stringToLocalDateOnly(shopInfo.paymentMethodFields[index].dateTime!.toString()) :
                                                getTranslated('select_date', context) ?? '',
                                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                              )
                                            ),
                                          ),

                                          InkWell(
                                            onTap: () async {
                                              await shopInfo.pickDate(context, index);
                                            },
                                            child: CustomAssetImageWidget(Images.calender, width: 20, height: 20, color: Theme.of(context).primaryColor),
                                          ),
                                        ],
                                      )
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeDefault),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          
              Container(height: 60,
                color: Theme.of(context).cardColor,
                child: Consumer<ShopController>(
                  builder: (context, shopProvider, _) {
                    return Padding(padding: const  EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButtonWidget(
                              backgroundColor: Theme.of(context).hintColor,
                              btnTxt: getTranslated('reset', context),
                              onTap: () {}
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
          
                          Expanded(
                            child: shopProvider.isLoading ?
                            const Center(child: CircularProgressIndicator()) :
                            CustomButtonWidget(
                              btnTxt: widget.formUpdate ? getTranslated('update', context) : getTranslated('save', context),
                              onTap: () {


                                Map<String, dynamic> methodInfo = <String, dynamic>{};

                                bool isMethodFieldEmpty = false;

                                for(MethodFields methodField in shopProvider.paymentMethodFields) {
                                  if(methodField.inputType == 'date') {
                                    if(methodField.dateTime  == null) {
                                      isMethodFieldEmpty = true;
                                      break;
                                    }
                                    methodInfo.addAll({methodField.inputName ?? '' : methodField.dateTime.toString().split(' ').first});
                                  } else if(methodField.inputType == 'phone') {
                                    if((methodField.textEditingController?.text ?? '').isEmpty || (methodField.countryCode ?? '').isEmpty) {
                                      isMethodFieldEmpty = true;
                                      break;
                                    }
                                    methodInfo.addAll({methodField.inputName ?? '' : (methodField.countryCode ?? '') + (methodField.textEditingController?.text ?? '')});
                                  } else {
                                    if((methodField.textEditingController?.text ?? '').isEmpty) {
                                      isMethodFieldEmpty = true;
                                      break;
                                    }
                                    methodInfo.addAll({methodField.inputName ?? '' : methodField.textEditingController?.text ?? ''});
                                  }
                                }



                                if(_methodNameController.text.trim().isEmpty) {
                                  showCustomSnackBarWidget(getTranslated('method_mame_is_empty', context), context, isError: false, sanckBarType: SnackBarType.warning);
                                } else if (shopInfo.selectedPaymentMethod == '') {
                                  showCustomSnackBarWidget(getTranslated('please_select_payment_method', context), context, isError: false, sanckBarType: SnackBarType.warning);
                                } else if (isMethodFieldEmpty) {
                                  showCustomSnackBarWidget(getTranslated('check_all_method_field_is_empty', context), context, isError: false, sanckBarType: SnackBarType.warning);
                                } else {
                                  WithdrawAddModel  withdrawAddModel = WithdrawAddModel(
                                    withdrawMethodId: shopProvider.getPaymentMethodId(shopProvider.selectedPaymentMethod ?? ''),
                                    methodName: _methodNameController.text,
                                    isActive: (shopProvider.selectedPaymentStatus ?? false) ? 1 : 0,
                                    methodInfo: methodInfo
                                  );

                                  if(!widget.formUpdate) {
                                    shopProvider.addPaymentInfo(context, withdrawAddModel).then((value) {
                                      if(value.response?.statusCode == 200){
                                        if(Provider.of<ShopController>(Get.context!, listen: false).shopModel?.setupGuideApp != null && Provider.of<ShopController>(Get.context!, listen: false).shopModel?.setupGuideApp?['withdraw_setup'] != 1) {
                                          Provider.of<ShopController>(Get.context!, listen: false).updateTutorialFlow('payment_information');
                                          Provider.of<ShopController>(Get.context!, listen: false).updateSetupGuideApp('payment_information', 1);
                                        }
                                        Navigator.of(Get.context!).pop();
                                      }
                                    });
                                  } else {
                                    withdrawAddModel.id = widget.paymentInfoData!.id;
                                    shopProvider.addPaymentInfo(context, withdrawAddModel, isUpdate : true).then((value) {
                                      if(value.response?.statusCode == 200){
                                        if(Provider.of<ShopController>(Get.context!, listen: false).shopModel?.setupGuideApp != null && Provider.of<ShopController>(Get.context!, listen: false).shopModel?.setupGuideApp?['payment_information'] != 1) {
                                          Provider.of<ShopController>(Get.context!, listen: false).updateTutorialFlow('payment_information');
                                          Provider.of<ShopController>(Get.context!, listen: false).updateSetupGuideApp('payment_information', 1);
                                        }
                                        Navigator.of(Get.context!).pop();
                                      }
                                    });
                                  }

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
      ),
    );
  }

  String formatField(String input) {
    return input.split('_').where((word) => word.isNotEmpty) // Remove empty strings
      .map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

}
