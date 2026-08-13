import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/guideline_warning_widget.dart';
import 'package:zulors_shop_vendor/features/shop/domain/models/shop_model.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/image_size_checker.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/utill/app_constants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';

import '../../../main.dart';

class ShopUpdateScreen extends StatefulWidget {
  const ShopUpdateScreen({super.key});

  @override
  ShopUpdateScreenState createState() => ShopUpdateScreenState();
}

class ShopUpdateScreenState extends State<ShopUpdateScreen> {

  final FocusNode _sNameFocus = FocusNode();
  final FocusNode _cNumberFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  String countryDialCode = '+880';

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();



  File? file;
  final picker = ImagePicker();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  void _choose() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      double fileSizeInMB = await ImageSize.getImageSizeFromXFile(pickedFile);

      ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

      if(fileSizeInMB > (configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
        showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemImageFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
      } else {
        setState(() {
          file = File(pickedFile.path);
        });
      }
    }
  }


  Future<void> _updateShop() async {
    String shopName = _shopNameController.text.trim();
    String contactNumber = _contactNumberController.text.trim();
    String address = _addressController.text.trim();

    if(Provider.of<ShopController>(context, listen: false).shopModel?.name == _shopNameController.text
        && Provider.of<ShopController>(context, listen: false).shopModel?.contact == _contactNumberController.text
        && Provider.of<ShopController>(context, listen: false).shopModel?.address == _addressController.text && file == null &&
    Provider.of<AuthController>(context, listen: false).shopBanner == null &&
        Provider.of<AuthController>(context, listen: false).secondaryBanner == null &&
        Provider.of<AuthController>(context, listen: false).offerBanner == null) {
      showCustomSnackBarWidget(getTranslated('change_something_to_update', context), context, sanckBarType: SnackBarType.warning);
    }else if (shopName.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_first_name', context), context, sanckBarType: SnackBarType.warning );
    }else if (contactNumber.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_contact_number', context), context, sanckBarType: SnackBarType.warning);
    }else if (address.isEmpty) {
      showCustomSnackBarWidget(getTranslated('enter_address', context), context, sanckBarType: SnackBarType.warning);
    }else {
      if(Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp != null && Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp?['shop_setup'] != 1) {
        Provider.of<ShopController>(context, listen: false).updateTutorialFlow('shop_setup');
        Provider.of<ShopController>(context, listen: false).updateSetupGuideApp('shop_setup', 1);
      }
      ShopModel updateShopModel = Provider.of<ShopController>(context, listen: false).shopModel!;
      updateShopModel.name = _shopNameController.text;
      updateShopModel.contact = _contactNumberController.text;
      updateShopModel.address = _addressController.text;
      await Provider.of<ShopController>(context, listen: false).updateShopInfo(updateShopModel : updateShopModel, file : file);
    }
  }

  Future<void> _resetShop() async {
    _shopNameController.text = '';
    _contactNumberController.text = '';
    _addressController.text = '';
    Provider.of<AuthController>(context, listen: false).pickImage(false,false, true);
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('edit_shop',context),

      ),
      key: _scaffoldKey,
      body: Consumer<ShopController>(
        builder: (context, shop, child) {
          _shopNameController.text = shop.shopModel?.name ?? '';
          _contactNumberController.text = shop.shopModel?.contact ?? '';
          _addressController.text = shop.shopModel?.address ?? '';

          return Consumer<AuthController>(
            builder: (context, authProvider, _) {
              return Column(children: [

                  Expanded(child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                        topRight: Radius.circular(Dimensions.paddingSizeDefault))
                    ),

                    child: ListView(
                      physics: const BouncingScrollPhysics(), children: [

                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Consumer<ShopController>(
                        builder: (context, shopInfo, _) {
                          return                 Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: GuidelineWarningWidget(
                              guidelineStatus: ((shopInfo.shopModel?.temporaryClose ?? false) && !(shopInfo.shopModel?.vacationStatus ?? false))
                                  ? GuidelineStatus.success :
                              (shopInfo.shopModel?.vacationStatus ?? false) ?
                              GuidelineStatus.error :
                              GuidelineStatus.warning,

                              content: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                                  children: <InlineSpan>[
                                    if(!(shopInfo.shopModel!.temporaryClose ?? false))...[
                                      TextSpan(text: getTranslated('your_shop_is_currently', context) ?? ''),
                                      TextSpan(
                                        text: getTranslated('shop_availability_status', context) ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: getTranslated('is_turned_off', context) ?? ''),
                                    ],

                                    if((shopInfo.shopModel?.temporaryClose ?? false) && !(shopInfo.shopModel?.vacationStatus ?? false))...[
                                      TextSpan(
                                        text: getTranslated('your_shop_is_running_up_do_date', context) ?? '',
                                        style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer),
                                      ),
                                    ],

                                    if((shopInfo.shopModel?.vacationStatus ?? false) && (shopInfo.shopModel?.temporaryClose ?? false))...[
                                      TextSpan(
                                        text: getTranslated('you_have_scheduled_shop', context) ?? '',
                                        style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                                      ),

                                      TextSpan(
                                        text: DateConverter.localToIsoString(DateTime.tryParse(shopInfo.shopModel?.vacationStartDate ?? '') ?? DateTime.now()),
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                                      ),

                                      TextSpan(
                                        text: getTranslated('to', context) ?? '',
                                        style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                                      ),

                                      TextSpan(
                                        text: DateConverter.localToIsoString(DateTime.tryParse(shopInfo.shopModel?.vacationStartDate ?? '') ?? DateTime.now()),
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error),
                                      ),

                                      TextSpan(
                                        text: getTranslated('if_you_wish_to_reopen_your_shop', context) ?? '',
                                        style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),
                                      ),
                                    ]
                                  ],
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              showCrossButton: false,
                            ),
                          );
                        }
                      ),


                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                      //   child: GuidelineWarningWidget(
                      //     guidelineStatus: GuidelineStatus.warning,
                      //     content: RichText(
                      //       text: TextSpan(
                      //         style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                      //         children: <InlineSpan>[
                      //           TextSpan(text: getTranslated('your_shop_is_currently', context) ?? ''),
                      //           TextSpan(
                      //             text: getTranslated('shop_availability_status', context) ?? '',
                      //             style: const TextStyle(fontWeight: FontWeight.bold),
                      //           ),
                      //           TextSpan(text: getTranslated('is_turned_off', context) ?? ''),
                      //         ],
                      //       ),
                      //       textAlign: TextAlign.justify,
                      //     ),
                      //     showCrossButton: false,
                      //   ),
                      // ),

                      Container(
                        margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeMedium, right: Dimensions.paddingSizeMedium),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                        ),


                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(getTranslated('basic_info', context) ?? '',
                            style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Text(getTranslated('shop_name', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextFieldWidget(
                            prefixIconImage: Images.shopNameIcon,
                            formProduct: true,
                            border: true,
                            isDescription: true,
                            textInputType: TextInputType.name,
                            focusNode: _sNameFocus,
                            nextNode: _cNumberFocus,
                            hintText: getTranslated('shop_name', context),
                            controller: _shopNameController,
                            required: true,
                            showIconDecorationColor: false,
                          ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(getTranslated('contact_number', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextFieldWidget(
                            required: true,
                            formProduct: true,
                            prefixIconImage: null,
                            border: true,
                            focusNode: _cNumberFocus,
                            nextNode: _addressFocus,
                            controller: _contactNumberController,
                            isPhoneNumber: true,
                            countryDialCode: shop.countryDialCode,
                            hintText: getTranslated('contact_number', context),
                            showCodePicker: true,
                            onCountryChanged: (CountryCode countryCode) {
                              shop.countryDialCode = countryCode.dialCode!;
                              shop.setCountryCode(countryCode.dialCode!);
                            },
                            isAmount: true,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          CustomTextFieldWidget(
                            required: true,
                            prefixIconImage: Images.storeAddressIcon,
                            formProduct: true,
                            border: true,
                            maxLine: 1,
                            textInputType: TextInputType.text,
                            focusNode: _addressFocus,
                            controller: _addressController,
                            hintText: getTranslated('address', context),
                            showIconDecorationColor: false,
                          ),

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
                            Text(getTranslated('logo_cover', context) ?? '',
                              style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeLarge)
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            Text(getTranslated('customize_your_business_logo', context) ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall)
                            ),
                            const SizedBox(height: Dimensions.paddingSizeLarge),

                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style.copyWith(
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(text: getTranslated('shop_logo', context) ?? ''),
                                  TextSpan(
                                    text: getTranslated('*', context) ?? '',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),


                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(text: getTranslated('jpg_png_less_then_1_mb', context) ?? ''),
                                  TextSpan(
                                    text: getTranslated('ratio_1_1', context) ?? '',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold,),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),


                            // Shop logo
                            Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeSmall),
                              child: DottedBorder(
                                options: RoundedRectDottedBorderOptions(
                                  dashPattern: const [10,5],
                                  color: Theme.of(context).hintColor,
                                  radius: const Radius.circular(Dimensions.paddingSizeSmall),
                                ),
                                child: Stack(
                                  children: [

                                    Container(width : double.infinity, height: 150, alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.15),
                                        borderRadius: const BorderRadius.all(Radius.circular(10))
                                      ),

                                      child: Stack(clipBehavior: Clip.none, children: [
                                        file == null ? CustomImageWidget(height: 150,width: 150,
                                            image: '${shop.shopModel?.imageFullUrl?.path}')
                                            : Image.file(file!, width: 150, height: 150, fit: BoxFit.cover),

                                        if (file == null && (shop.shopModel?.imageFullUrl?.path?.isEmpty ?? true))
                                          Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                              child: SizedBox(width: 50, height: 50,
                                                child: InkWell(
                                                  onTap: _choose,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30),
                                                      const SizedBox(height: Dimensions.paddingSizeSmall),

                                                      Text(getTranslated('click_to_add', context) ?? '',
                                                          style: robotoRegular.copyWith(
                                                              color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                          ),
                                      ],
                                      ),
                                    ),

                                    if (file != null || (shop.shopModel?.imageFullUrl?.path?.isNotEmpty ?? false))
                                      Positioned( right: 10, top: 10,
                                      child: SizedBox(width: 25, height: 25,
                                        child: InkWell(
                                          onTap: _choose,
                                          child: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CustomAssetImageWidget(Images.editImageIcon, height: 25, width: 25),
                                            ],
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeDefault),


                            //Shop Cover
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style.copyWith(
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                  fontSize: Dimensions.fontSizeDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(text: getTranslated('shop_cover', context) ?? ''),
                                  TextSpan(
                                    text: getTranslated('*', context) ?? '',
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(text: getTranslated('jpg_png_less_then_1_mb', context) ?? ''),
                                  TextSpan(
                                    text: getTranslated('ratio_4_1', context) ?? '',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold,),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),



                            Stack(
                              children: [
                                Align(alignment: Alignment.center, child: DottedBorder(
                                  options: RoundedRectDottedBorderOptions(
                                    dashPattern: const [10,5],
                                    color: Theme.of(context).hintColor,
                                    radius: const Radius.circular(Dimensions.paddingSizeSmall),
                                  ),
                                  child: Container(
                                    width : double.infinity, height: 150, alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.15),
                                        borderRadius: const BorderRadius.all(Radius.circular(10))
                                    ),
                                    child: Stack(children: [
                                      authProvider.shopBanner != null ?
                                      Image.file(
                                        File(authProvider.shopBanner!.path),
                                        width: double.infinity, height: 80, fit: BoxFit.cover
                                      ) :
                                      SizedBox(
                                        height: 80, width: double.infinity,
                                        child: CustomImageWidget(image: '${shop.shopModel?.bannerFullUrl?.path}')
                                      ),

                                      if (authProvider.shopBanner == null && (shop.shopModel?.bannerFullUrl?.path?.isEmpty ?? true))
                                        Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                          child: InkWell(onTap: () => authProvider.pickImage(false,false, false),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30),
                                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                                Text(getTranslated('click_to_add', context) ?? '',
                                                    style: robotoRegular.copyWith(
                                                        color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall
                                                    )
                                                ),
                                              ],
                                            ),

                                          ),
                                        ),
                                    ]),
                                  ),
                                )),


                                if (file != null || (shop.shopModel?.imageFullUrl?.path?.isNotEmpty ?? false))
                                  Positioned( right: 10, top: 10,
                                    child: SizedBox(width: 25, height: 25,
                                      child: InkWell(
                                        onTap: () => authProvider.pickImage(false,false, false),
                                        child: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomAssetImageWidget(Images.editImageIcon, height: 25, width: 25),
                                          ],
                                        ),
                                      ),
                                    )
                                ),

                              ],
                            )
                          ]
                        ),
                      ),







                      if(Provider.of<SplashController>(context, listen: false).configModel?.activeTheme == "theme_aster")
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge,top: Dimensions.paddingSizeDefault,
                                right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeDefault),
                              child: Row(children: [

                                RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style.copyWith(
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                      fontSize: Dimensions.fontSizeDefault,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: <InlineSpan>[
                                      TextSpan(text: getTranslated('store_secondary_banner', context) ?? ''),
                                      TextSpan(
                                        text: getTranslated('*', context) ?? '',
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.justify,
                                ),

                                // Text('${getTranslated('store_secondary_banner', context)}',
                                //     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                              ],
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Align(alignment: Alignment.center, child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                dashPattern: const [10,5],
                                color: Theme.of(context).hintColor,
                                radius: const Radius.circular(Dimensions.paddingSizeSmall),
                              ),
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                  child: authProvider.secondaryBanner != null ?  Image.file(File(authProvider.secondaryBanner!.path),
                                    width: MediaQuery.of(context).size.width - 40, height: 120, fit: BoxFit.cover,
                                  ) :SizedBox(height: 120,
                                    width: MediaQuery.of(context).size.width - 40,
                                    child: CustomImageWidget(image: '${shop.shopModel?.bottomBannerFullUrl?.path}' ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0, right: 0, top: 0, left: 0,
                                  child: InkWell(
                                    onTap: () => authProvider.pickImage(false,false, false, secondary: true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha:0.15),
                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),

                                      ),
                                      child: Icon(Icons.camera_alt_outlined, size: 70,color: Theme.of(context).hintColor,),

                                    ),
                                  ),
                                ),
                              ]),
                            )),
                            Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeDefault),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(getTranslated('image_size', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text('(3:1)', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),),
                                ],
                              ),
                            ),
                          ],),


                      if(Provider.of<SplashController>(context, listen: false).configModel?.activeTheme == "theme_fashion")
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge,top: Dimensions.paddingSizeDefault,
                              right: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeDefault),
                              child: Row(children: [
                                Text('${getTranslated('offer_banner', context)}',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))])),


                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Align(alignment: Alignment.center, child: DottedBorder(
                            options: RoundedRectDottedBorderOptions(
                              dashPattern: const [10,5],
                              color: Theme.of(context).hintColor,
                              radius: const Radius.circular(Dimensions.paddingSizeSmall),
                            ),
                            child: Stack(children: [
                              ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                  child: authProvider.offerBanner != null ?  Image.file(File(authProvider.offerBanner!.path),
                                      width: MediaQuery.of(context).size.width - 40, height: 120, fit: BoxFit.cover) :SizedBox(height: 120,
                                      width: MediaQuery.of(context).size.width - 40,
                                      child: CustomImageWidget(image: '${shop.shopModel?.offerBannerFullUrl?.path}'))),

                              Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                child: InkWell(onTap: () => authProvider.pickImage(false,false, false, offer: true),
                                  child: Container(decoration: BoxDecoration(color: Colors.black.withValues(alpha:0.15),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                                    child: Icon(Icons.camera_alt_outlined, size: 70,color: Theme.of(context).hintColor,),),),),
                            ]),
                          )),


                          Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeDefault),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(getTranslated('image_size', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text('(7:1)', style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error),),])),

                        ]),
                        ],
                      ),
                    ),
                  ),


                  SizedBox(height: 60,
                    child: Consumer<ShopController>(
                      builder: (context, shopProvider, _) {
                        return Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButtonWidget(
                                  backgroundColor: Theme.of(context).hintColor,
                                  btnTxt: getTranslated('reset', context),
                                  onTap: () => _resetShop()
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: shopProvider.isLoading?
                                const Center(child: CircularProgressIndicator())
                                : CustomButtonWidget(
                                  btnTxt: getTranslated('update_shop', context),
                                  onTap: () => _updateShop()
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
