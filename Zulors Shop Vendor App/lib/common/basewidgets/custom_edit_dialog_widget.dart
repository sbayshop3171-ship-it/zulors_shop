import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/guideline_warning_widget.dart';
import 'package:zulors_shop_vendor/features/profile/domain/models/withdraw_model.dart';
import 'package:zulors_shop_vendor/features/shop/screens/shop_screen.dart';
import 'package:zulors_shop_vendor/features/wallet/controllers/wallet_controller.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

import '../../main.dart';

class CustomEditDialogWidget extends StatefulWidget {
  final double totalEarning;
  const CustomEditDialogWidget({super.key, required this.totalEarning});

  @override
  CustomEditDialogWidgetState createState() => CustomEditDialogWidgetState();
}

class CustomEditDialogWidgetState extends State<CustomEditDialogWidget> {

  final TextEditingController _balanceController = TextEditingController();
  final List<String> groupItems = ['my_methods', 'other'];
  final WalletController walletController = Provider.of<WalletController>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();

    final walletController = Provider.of<WalletController>(context, listen: false);
    walletController.setDefaultPaymentMethod();
    _balanceController.text = PriceConverter.convertPriceWithoutSymbol(Get.context!, widget.totalEarning);
    _listenTextController();

    if(walletController.methodSelected != null) {
      walletController.setMethodTypeIndex(walletController.methodSelected, notify: false);
    }


  }


  void _listenTextController() {
    _balanceController.addListener((){
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<MethodModel>> dropdownItems = [];



    for (var values in groupItems) {
      if((values == 'my_methods' &&  walletController.myMethodsIds.isNotEmpty) || values == 'other') {
        dropdownItems.add(
          DropdownMenuItem<MethodModel>(
            enabled: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                getTranslated(values, context) ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
          ),
        );
      }

      if(values == 'my_methods') {
        dropdownItems.addAll(walletController.myMethodsIds.map((item) {
          return DropdownMenuItem<MethodModel>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(item?.inputName ?? ''),
            ),
          );
        }));
      }

      if(values == 'other') {
        dropdownItems.addAll(walletController.methodsIds.map((item) {
          return DropdownMenuItem<MethodModel>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(item?.inputName ?? ''),
            ),
          );
        }));
      }
    }



    return SingleChildScrollView(
      child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
        child: Container(decoration: BoxDecoration(
          color: Provider.of<ThemeController>(context).darkTheme ?
          Theme.of(context).cardColor :
          Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.only(topLeft:  Radius.circular(25), topRight: Radius.circular(25)),),
          child: Container(width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.keyboard_arrow_down)
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

              Consumer<WalletController>(
                  builder: (context, withdraw,_) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeDefault,
                        horizontal: Dimensions.paddingSizeSmall,
                      ),
                      child: Column(children: [

                        if(groupItems.isEmpty)
                          GuidelineWarningWidget(
                            guidelineStatus: GuidelineStatus.warning,
                            content: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                                children: <InlineSpan>[
                                  TextSpan(text: getTranslated('you_have_setup_any_payment_information', context) ?? ''),

                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: IntrinsicWidth(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context);

                                          Future.microtask(
                                                  () =>Navigator.push(Get.context!, MaterialPageRoute(builder: (_)=> const ShopScreen(tabIndex: 1)))
                                          );
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslated('payment_options', context) ?? '',
                                              style: robotoRegular.copyWith(
                                                color: Theme.of(context).colorScheme.surfaceTint,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            Container(
                                              height: 1,
                                              color: Theme.of(context).colorScheme.surfaceTint,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(text: getTranslated('page', context) ?? ''),
                                ],
                              ),
                              textAlign: TextAlign.left,
                            ),
                            showCrossButton: false,
                          ),

                        if(groupItems.isEmpty)
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(color: Theme.of(context).cardColor,
                              border: Border.all(width: .5, color: Theme.of(context).hintColor.withValues(alpha:.7)),
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                          child: DropdownButton<MethodModel>(
                              hint: Text(getTranslated('select_withdraw_method', context) ?? ''),
                              value: (dropdownItems.isEmpty ? null : withdraw.methodSelected),
                              items: dropdownItems,
                              onChanged: (MethodModel? value) {
                                withdraw.setMethodTypeIndex(value);
                              },
                              isExpanded: true, underline: const SizedBox()
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),


                        if(withdraw.methodList.isNotEmpty &&
                            withdraw.methodSelected?.methodInfo != null &&
                            withdraw.methodSelected!.methodInfo!.isNotEmpty && withdraw.methodSelected?.type == 'my_methods')
                          Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).hintColor.withValues(alpha: 0.07) ,
                              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CustomAssetImageWidget(
                                            Images.bankInfoIcon,
                                            width: 15, height: 15
                                        ),

                                        const SizedBox(width: Dimensions.paddingSizeSmall),
                                        Text(withdraw.methodSelected?.inputName ?? '', style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.paddingSizeDefault)),
                                      ],
                                    ),


                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                Container(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    decoration:  BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                                        color: Theme.of(context).cardColor
                                    ),
                                    child: Table(
                                      columnWidths: const {
                                        0 : FixedColumnWidth(100), // Fixed width for the label column
                                      },
                                      children: [

                                        for (var methodInfo in withdraw.methodSelected?.methodInfo?.entries ?? {}.entries) ...[
                                          _buildTableRow(
                                            getTranslated(methodInfo.key, context) ?? '',
                                            methodInfo.value ?? '',
                                          ),

                                          const TableRow(children: [
                                            SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                            SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                          ]),
                                        ]

                                      ],
                                    )
                                ),

                              ],
                            ),
                          ),



                        if(withdraw.methodList.isNotEmpty &&
                            withdraw.methodSelected?.methodFields != null &&
                            withdraw.inputFieldControllerList.isNotEmpty &&
                            withdraw.methodSelected!.methodFields!.isNotEmpty && withdraw.methodSelected?.type == 'other')
                          ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: withdraw.methodSelected?.methodFields?.length,
                              itemBuilder: (context, index){
                                String? type = withdraw.methodSelected?.methodFields![index].inputType;
                                return Padding(
                                  padding:  const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                  child: Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextFieldWidget(
                                        textInputType: (type == 'number' || type == "phone") ? TextInputType.number:
                                        TextInputType.text,
                                        border: true,
                                        controller: withdraw.inputFieldControllerList[index],
                                        hintText: withdraw.methodSelected?.methodFields![index].placeholder,
                                      ),
                                    ],
                                  ),
                                );
                              }
                          )
                      ],),
                    );
                  }
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: CustomTextFieldWidget(
                  controller: _balanceController,
                  textInputType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  border: true,
                  labelText: getTranslated('enter_withdraw_amount', context) ?? '',
                  hintText: getTranslated('enter_withdraw_amount', context) ?? '',
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;

                      // Remove any character not matching digits or decimal point
                      final filtered = text.replaceAll(RegExp(r'[^0-9.]'), '');

                      // Ensure only one decimal point and max 5 digits after decimal
                      final parts = filtered.split('.');
                      if (parts.length > 2) {
                        return oldValue; // Invalid, more than one dot
                      }

                      if (parts.length == 2 && parts[1].length > 5) {
                        return oldValue; // More than 5 decimals
                      }

                      return TextEditingValue(
                        text: filtered,
                        selection: TextSelection.collapsed(offset: filtered.length),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.incrementButton),

              !Provider.of<WalletController>(context).isLoading?
              Consumer<WalletController>(
                  builder: (context, withdraw,_) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        bool haveBlankTitle = false;
                        for(TextEditingController title in withdraw.inputFieldControllerList) {
                          if(title.text.isEmpty){
                            haveBlankTitle = true;
                            break;
                          }
                        }
                        if(withdraw.methodSelected == null) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('select_withdraw_method', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if(withdraw.methodSelected?.type == 'my_methods' && withdraw.methodSelected?.methodFields != null && withdraw.inputFieldControllerList.isEmpty) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('please_fill_all_the_field', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if(haveBlankTitle && withdraw.methodSelected?.type != 'my_methods') {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('please_fill_all_the_field', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if(_balanceController.text.trim() == '') {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('please_enter_amount', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if ((double.tryParse(_balanceController.text) ?? 0) <= 0) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('withdraw_amount_should_be_grater_then', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        } else if(double.parse(_balanceController.text != '' ? _balanceController.text : '0') >  double.tryParse(PriceConverter.convertPriceWithoutSymbol(context, widget.totalEarning))!) {
                          Navigator.of(context).pop();
                          showCustomSnackBarWidget(getTranslated('amount_should_be', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
                        }else{
                          withdrawBalance();
                        }
                      },
                      child: Card(
                        color:  double.parse(_balanceController.text != '' ? _balanceController.text : '0') <= 0 ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                        child: SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(getTranslated('withdraw', context)!,
                                style: const TextStyle(fontSize: Dimensions.fontSizeLarge,fontWeight: FontWeight.w500,color: Colors.white)),
                          ),
                        ),
                      ),
                    );
                  }
              ): Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
            ],
            ),
          ),
        ),
      ),
    );
  }

  void withdrawBalance() async {
    String balance = '0';
    double bal = 0;
    balance = _balanceController.text.trim();
    if(balance.isNotEmpty){
      bal = double.parse(balance);
    }
    if (balance.isEmpty) {
      Navigator.of(context).pop();
      showCustomSnackBarWidget(getTranslated('enter_balance', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
    }else if(bal > double.parse(PriceConverter.convertPriceWithoutSymbol(context, Provider.of<ProfileController>(context, listen: false).userInfoModel!.wallet!.totalEarning))) {
      Navigator.of(context).pop();
      showCustomSnackBarWidget(getTranslated('insufficient_balance', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
    }else if(bal <= 1) {
      Navigator.of(context).pop();
      showCustomSnackBarWidget(getTranslated('minimum_amount', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
    }else if(bal <= 1) {
      Navigator.of(context).pop();
      showCustomSnackBarWidget(getTranslated('minimum_amount', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
    } else {
      await Provider.of<WalletController>(context, listen: false).updateBalance(bal.toString(), context);
    }
  }
}


TableRow _buildTableRow(String label, String value) {
  return TableRow(
    children: [
      Text(
          formatField(label),
          style: robotoMedium.copyWith(color: Theme.of(Get.context!).hintColor, fontSize: Dimensions.fontSizeDefault)
      ),

      Text(
          ': $value',
          style: robotoMedium.copyWith(color: Theme.of(Get.context!).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)
      ),
    ],
  );
}

String formatField(String input) {
  return input.split('_').where((word) => word.isNotEmpty) // Remove empty strings
      .map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
}