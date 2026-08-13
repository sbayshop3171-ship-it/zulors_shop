import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/shop/screens/vacation_mode_setup_screen.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_details_widget.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

import '../../../main.dart';
import '../../product_details/widgets/product_details_widget.dart';

class OtherSetupScreen extends StatefulWidget {
  const OtherSetupScreen({super.key});

  @override
  State<OtherSetupScreen> createState() => _OtherSetupScreenState();
}

class _OtherSetupScreenState extends State<OtherSetupScreen> {
  SplashController splashController = Provider.of<SplashController>(Get.context!, listen: false);
  ProfileController profileController = Provider.of<ProfileController>(Get.context!, listen: false);
  ShopController shopController = Provider.of<ShopController>(Get.context!, listen: false);

  final TextEditingController _minimumOrderAmountController = TextEditingController();
  final TextEditingController _freeDeliveryOverAmountController = TextEditingController();
  final TextEditingController _reOrderLevelController = TextEditingController();

  final TextEditingController _tinNumberController = TextEditingController();


  final FocusNode _minimumOrderAmountFocus = FocusNode();
  final FocusNode _freeDeliveryOverAmountFocus = FocusNode();
  final FocusNode _reOrderLevelFocus = FocusNode();

  bool freeDeliveryOn = false;

  @override
  void initState() {
    setInitialData();
    super.initState();
  }


  void setInitialData () {
    if(splashController.configModel?.minimumOrderAmountStatus == 1 && splashController.configModel?.minimumOrderAmountStatusBySeller ==1) {
      _minimumOrderAmountController.text = profileController.userInfoModel?.minimumOrderAmount?.toString() ?? '';
    }

    if(splashController.configModel?.freeDeliveryStatus == 1 && splashController.configModel?.freeDeliveryResponsibility == 'seller') {
      freeDeliveryOn =  profileController.userInfoModel?.freeOverDeliveryAmountStatus  == 1 ? true : false;
      _minimumOrderAmountController.text = profileController.userInfoModel?.freeOverDeliveryAmount?.toString() ?? '';
    }

    if(shopController.shopModel?.taxIdentificationNumber != null) {
      _tinNumberController.text = shopController.shopModel?.taxIdentificationNumber ?? '';
    }

    if(shopController.shopModel?.tinExpireDate != null) {
      shopController.setExpireDate(DateTime.tryParse(shopController.shopModel?.tinExpireDate ?? ''));
    }

    if(shopController.shopModel?.reorderLevel != null) {
      _reOrderLevelController.text = shopController.shopModel?.reorderLevel.toString() ?? '';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShopController>(
        builder: (context, shopController, child) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                  child: SingleChildScrollView(
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
                              Text(getTranslated('order_setup', context) ?? '',
                                  style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Text(getTranslated('here_you_can_configure_the_settings', context) ?? '',
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)
                              ),

                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              if(splashController.configModel?.minimumOrderAmountStatus == 1 && splashController.configModel?.minimumOrderAmountStatusBySeller ==1)
                              CustomTextFieldWidget(
                                formProduct: true,
                                border: true,
                                isDescription: true,
                                textInputType: TextInputType.number,
                                focusNode: _minimumOrderAmountFocus,
                                nextNode: _freeDeliveryOverAmountFocus,
                                hintText: '${getTranslated('minimum_order_amount', context)} ${Provider.of<SplashController>(context, listen: false).myCurrency?.symbol}' ,
                                controller: _minimumOrderAmountController,
                                required: true,
                                showIconDecorationColor: false,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              if(splashController.configModel?.freeDeliveryStatus == 1 && splashController.configModel?.freeDeliveryResponsibility == 'seller')
                              TitledBorder(
                                title: '${getTranslated('free_delivery_over_amount', context)}',
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: ShopSettingWidget(
                                    showBorder: false,
                                    title: 'statuss',
                                    mode: freeDeliveryOn,
                                    onTap: (value) {
                                      setState(() {
                                        freeDeliveryOn = value;
                                      });
                                    }
                                  ),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),

                              if(splashController.configModel?.freeDeliveryStatus == 1 && splashController.configModel?.freeDeliveryResponsibility == 'seller')
                              CustomTextFieldWidget(
                                idDate: !freeDeliveryOn,
                                formProduct: true,
                                border: true,
                                isDescription: true,
                                textInputType: TextInputType.number,
                                focusNode: _freeDeliveryOverAmountFocus,
                                nextNode: _reOrderLevelFocus,
                                hintText: '${getTranslated('free_delivery_over_amount', context)}  (${Provider.of<SplashController>(context, listen: false).myCurrency?.symbol})',
                                controller: _freeDeliveryOverAmountController,
                                required: true,
                                showIconDecorationColor: false,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),


                              CustomTextFieldWidget(
                                formProduct: true,
                                border: true,
                                isDescription: true,
                                textInputType: TextInputType.number,
                                focusNode: _reOrderLevelFocus,
                                hintText: getTranslated('re_order_level', context),
                                controller: _reOrderLevelController,
                                required: true,
                                showIconDecorationColor: false,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),


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
                              Text(getTranslated('business_tin', context) ?? '',
                                  style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Text(getTranslated('here_you_can_configure_the_settings', context) ?? '',
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)
                              ),


                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              CustomTextFieldWidget(
                                formProduct: true,
                                border: true,
                                isDescription: true,
                                textInputType: TextInputType.name,
                                // focusNode: _minimumOrderAmountFocus,
                                // nextNode: _freeDeliveryOverAmountFocus,
                                hintText: '${getTranslated('taxpayer_identification_number', context)}' ,
                                controller: _tinNumberController,
                                showIconDecorationColor: false,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),


                              TitledBorder(
                                title: getTranslated('expire_date', context) ?? '',
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          shopController.tinExpireDate != null  ?
                                          DateConverter.stringToLocalDateOnly(shopController.tinExpireDate.toString()) :
                                          getTranslated('select_date', context) ?? '',
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                        ),
                                      ),

                                      InkWell(
                                        onTap: () async {
                                          await shopController.pickTinExpireDate(context);
                                        },
                                        child: const CustomAssetImageWidget(Images.pickTinExpireDate, width: 20, height: 20),
                                      ),
                                    ],
                                  )
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),


                              Text(getTranslated('tin_certificate', context) ?? '',
                                  style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Text(getTranslated('tin_file_size', context) ?? '',
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeDefault)
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),


                              DottedBorder(
                                options: RoundedRectDottedBorderOptions(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  dashPattern: const [4,5],
                                  color:  shopController.tinCertificateFile != null ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                  radius: const Radius.circular(Dimensions.paddingEye),
                                ),
                                  child: Container(
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                      ),
                                      child: Stack(
                                        children: [

                                          if( shopController.tinCertificateFile != null)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: InkWell(
                                                onTap: () {
                                                  if(shopController.tinCertificateFile == null) {

                                                  } else {
                                                    shopController.removeTinCertificateFile();
                                                  }
                                                } ,
                                                child: shopController.isLoading ? const Center(child: SizedBox(height: 25, width: 25, child: SizedBox())) : Image.asset(width:25, Images.digitalPreviewDeleteIcon))
                                            ),


                                          if(shopController.tinCertificateFile == null && shopController.shopModel?.tinCertificateFullUrl != null && shopController.shopModel?.tinCertificateFullUrl?.path != '')
                                          Positioned(
                                            top: 10, right: 10,
                                            child: shopController.isDownloadLoading ?
                                            const SizedBox(height: 25, width: 25, child: CircularProgressIndicator()) :
                                            InkWell(
                                              onTap: () {
                                                shopController.previewDownload(url: shopController.shopModel?.tinCertificateFullUrl?.path ?? '',
                                                fileName: shopController.shopModel?.tinCertificateFullUrl?.key ?? '');
                                              },
                                              child: const CustomAssetImageWidget(Images.tinDownloadIcon, width: 25, height: 25)
                                            ),
                                          ),



                                          if(shopController.tinCertificateFile == null && shopController.shopModel?.tinCertificateFullUrl?.path != null && shopController.shopModel?.tinCertificateFullUrl?.path != '')
                                          Positioned(
                                            top: 0, right: 35,
                                            child: shopController.isDownloadLoading ?
                                            const SizedBox(height: 25, width: 25) :
                                            InkWell(
                                              onTap: () {
                                                showPreview(
                                                  shopController.shopModel?.tinCertificateFullUrl?.path ?? '', '',
                                                  shopController.shopModel?.tinCertificateFullUrl?.key ?? '', context
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                child: Icon(Icons.remove_red_eye)
                                              )
                                            ),
                                          ),



                                          Positioned.fill(
                                            child: Center(
                                              child:Column(
                                                mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [

                                                  if(shopController.tinCertificateFile == null)
                                                    ...[
                                                      Column(
                                                        children: [
                                                          SizedBox(width: 45,
                                                            child: InkWell(
                                                              onTap: () => shopController.pickTinCertificateFile(),
                                                              child: const CustomAssetImageWidget(Images.tinCertificateUploadIcon, width: 45, height: 45))),
                                                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                          Text(
                                                            (shopController.shopModel?.tinCertificateFullUrl != null && shopController.shopModel?.tinCertificateFullUrl?.path != '')   ?
                                                            shopController.shopModel?.tinCertificateFullUrl?.key  ?? ''
                                                            : getTranslated('upload_file', context)!,
                                                              style: robotoRegular.copyWith(fontWeight: FontWeight.w600, fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))
                                                        ],
                                                      )
                                                    ],


                                                  if(shopController.tinCertificateFile != null)
                                                    ...[
                                                      Column(
                                                        children: [
                                                          SizedBox(width: 45,
                                                            child: InkWell(
                                                              onTap: () => shopController.pickTinCertificateFile(),
                                                              child: const CustomAssetImageWidget(Images.tinCertificateUploadIcon, width: 45, height: 45))),
                                                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                          Text(shopController.tinCertificateFile?.name ?? '',
                                                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis)
                                                        ],
                                                      )
                                                    ],


                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                  )
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
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
                              onTap: () {
                                setInitialData();
                                setState(() {});
                              }
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: shopProvider.isLoading?
                            const Center(child: CircularProgressIndicator())
                              : CustomButtonWidget(
                              btnTxt: getTranslated('save', context),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                if(freeDeliveryOn && _freeDeliveryOverAmountController.text.isEmpty) {
                                  showCustomSnackBarWidget(getTranslated('free_delivery_over_amount_is_empty', context), sanckBarType: SnackBarType.warning, context, isError: false);
                                } else if(_reOrderLevelController.text.trim().isEmpty) {
                                  showCustomSnackBarWidget(getTranslated('reorder_level_is_empty', context), sanckBarType: SnackBarType.warning, context, isError: false);
                                } else {
                                  if(Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp != null && Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp?['order_setup'] != 1) {
                                    Provider.of<ShopController>(context, listen: false).updateTutorialFlow('order_setup');
                                    Provider.of<ShopController>(context, listen: false).updateSetupGuideApp('order_setup', 1);
                                  }
                                  shopProvider.updateShopInfo(
                                    freeDeliveryOverAmount: _freeDeliveryOverAmountController.text.trim(),
                                    freeDeliveryStatus: freeDeliveryOn? "1" : "0",
                                    minimumOrderAmount: _minimumOrderAmountController.text.trim(),
                                    taxIdentificationNumber: _tinNumberController.text,
                                    tinExpireDate: shopController.tinExpireDate.toString(),
                                    tinCertificate: shopController.tinCertificateFile,
                                    stockLimit: _reOrderLevelController.text
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
      ),


    );
  }
}
