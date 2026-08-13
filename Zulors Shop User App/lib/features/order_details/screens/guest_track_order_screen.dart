import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/custom_asset_image_widget.dart';
import 'package:zulors_shop/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/helper/velidate_check.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/utill/custom_themes.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/utill/images.dart';
import 'package:zulors_shop/common/basewidget/custom_app_bar_widget.dart';
import 'package:zulors_shop/common/basewidget/custom_button_widget.dart';
import 'package:zulors_shop/common/basewidget/custom_textfield_widget.dart';
import 'package:provider/provider.dart';

class GuestTrackOrderScreen extends StatefulWidget {
  const GuestTrackOrderScreen({super.key});

  @override
  State<GuestTrackOrderScreen> createState() => _GuestTrackOrderScreenState();
}

class _GuestTrackOrderScreenState extends State<GuestTrackOrderScreen> {
  String? countryCode;

  TextEditingController orderIdController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey();


  @override
  void initState() {
    super.initState();

    final ConfigModel configModel = Provider.of<SplashController>(context, listen: false).configModel!;
    countryCode ??= CountryCode.fromCountryCode(configModel.countryCode!).dialCode;
  }


  @override
  Widget build(BuildContext context) {
    final double widthSize = MediaQuery.sizeOf(context).width;

    return Scaffold(
        appBar: CustomAppBar(title: getTranslated('TRACK_ORDER', context)),
      body: Consumer<OrderDetailsController>(
        builder: (context, orderTrackingProvider, _) {
          return Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
            child: Form(
              key: formKey,
              child: ListView( physics: const ClampingScrollPhysics(), children: [

                const SizedBox(height: Dimensions.paddingSizeOverLarge),

                Column(mainAxisAlignment: MainAxisAlignment.center,children: [
                  CustomAssetImageWidget(Images.truckImage, height: widthSize * 0.17),

                  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault), child: Text(
                    getTranslated('track_your_order_from_here', context)!,
                    style: textRegular.copyWith(color: Theme.of(context).hintColor),
                    textAlign: TextAlign.center,
                  )),
                ]),
                const SizedBox(height: Dimensions.paddingSizeThirtyFive),

                CustomTextFieldWidget(
                  controller: orderIdController,
                  prefixIcon: Images.orderIdIcon,
                  prefixColor: Theme.of(context).primaryColor,
                  isAmount: true,
                  inputType: TextInputType.phone,
                  hintText: getTranslated('enter_order_id', context),
                  labelText: getTranslated('order_id', context),
                  labelTextStyle: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  required: true,
                  showLabelText: false,
                  validator: (value)=> ValidateCheck.validateEmptyText(value, 'order_id_is_required'),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),


                CustomTextFieldWidget(
                  countryDialCode: countryCode,
                  showCodePicker: true,
                  inputType: TextInputType.phone,
                  prefixColor: Theme.of(context).primaryColor,
                  controller: phoneNumberController,
                  inputAction: TextInputAction.done,
                  hintText: '${getTranslated('enter_phone_number', context)}',
                  required: true,
                  labelText: '${getTranslated('phone_number', context)}',
                  labelTextStyle: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  showLabelText: false,
                  validator: (value)=> ValidateCheck.validateEmptyText(value, 'phone_number_is_required'),
                  onCountryChanged: (CountryCode value) {
                    countryCode = value.dialCode;
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),



                CustomButton(
                  isLoading: orderTrackingProvider.searching,
                  buttonText: '${getTranslated('track_order', context)}',
                  onTap: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    String orderId = orderIdController.text.trim();
                    String phone = countryCode! + phoneNumberController.text.trim();

                    if(formKey.currentState?.validate() ?? false) {
                      await orderTrackingProvider.trackOrder(orderId: orderId.toString(), phoneNumber: phone, isUpdate: true).then((value) {
                        if(value.response?.statusCode == 200){
                          if(context.mounted) {
                            RouterHelper.getOrderDetailsScreenRoute(
                              action: RouteAction.push,
                              orderId: int.parse(orderIdController.text.trim()),
                              phone: phone,
                              fromTrack: true
                            );
                            orderIdController.text = '';
                            phoneNumberController.text = '';
                          }
                        }
                      });
                    }
                  },
                ),
              ]),
            ),
          );
        }
      )
    );
  }
}
