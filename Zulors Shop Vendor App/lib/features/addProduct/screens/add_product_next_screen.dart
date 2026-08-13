
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/common/basewidgets/attribute_view_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/discount_text_field_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/add_product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/attribute_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/add_product_title_bar.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/digital_product_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/upload_preview_file_widget.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/ai/widgets/genertate_count_widget.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/variant_type_model.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/screens/add_product_seo_screen.dart';

import '../../auth/controllers/auth_controller.dart';

class AddProductNextScreen extends StatefulWidget {
  final ValueChanged<bool>? isSelected;
  final Product? product;
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandId;
  final AddProductModel? addProduct;
  final String? unit;
  final String? title;
  final String? description;

  const AddProductNextScreen({super.key, this.isSelected, required this.product,required this.addProduct, this.categoryId, this.subCategoryId, this.subSubCategoryId, this.brandId, this.unit, this.title, this.description});

  @override
  AddProductNextScreenState createState() => AddProductNextScreenState();
}

class AddProductNextScreenState extends State<AddProductNextScreen> {
  bool isSelected = false;
  final FocusNode _discountNode = FocusNode();
  final FocusNode _shippingCostNode = FocusNode();
  final FocusNode _unitPriceNode = FocusNode();
  final FocusNode _totalQuantityNode = FocusNode();
  final FocusNode _minimumOrderQuantityNode = FocusNode();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _minimumOrderQuantityController = TextEditingController();
  final TextEditingController _colorVariationController = TextEditingController();

  final digitalProductController = Provider.of<DigitalProductController>(Get.context!, listen: false);

  AutoCompleteTextField? searchTextField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  SimpleAutoCompleteTextField? textField;
  bool showWhichErrorText = false;
  late bool _update;
  Product? _product;
  String? thumbnailImage ='', metaImage ='';
  List<String?>? productImage =[];
  int counter = 0, total = 0;
  int addColor = 0;
  int cat=0, subCat=0, subSubCat=0, unit=0, brand=0;

  List<String> taxModelList = ['include', 'exclude'];


  Future<void> _load() async {
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US'?
    'en':Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    Provider.of<SplashController>(context,listen: false).getColorList();
    await Provider.of<VariationController>(context,listen: false).getAttributeList(context, widget.product, languageCode);

    Provider.of<VariationController>(Get.context!, listen: false).generateVariantTypes(Get.context!, widget.product);
  }


  @override
  void dispose() {
    _colorVariationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Provider.of<AddProductImageController>(context,listen: false).colorImageObject = [];
    Provider.of<AddProductImageController>(context,listen: false).productReturnImageList = [];
    _product = widget.product;
    _update = widget.product != null;
    _taxController.text = '0';
    _discountController.text = '0';
    _shippingCostController.text = '0';
    _minimumOrderQuantityController.text = '1';
    _loadData();
    if(_update) {
      _asyncMethod();
      _unitPriceController.text = PriceConverter.convertPriceWithoutSymbol(context, _product!.unitPrice);
      _taxController.text = _product!.tax.toString();
      Provider.of<VariationController>(context, listen: false).setCurrentStock(_product!.currentStock.toString());
      _shippingCostController.text = PriceConverter.convertPriceWithoutSymbol(context, _product!.shippingCost);
      _minimumOrderQuantityController.text = _product!.minimumOrderQty.toString();
      Provider.of<AddProductController>(context, listen: false).setDiscountTypeIndex(_product!.discountType == 'percent' ? 0 : 1, false);
      _discountController.text = _product!.discountType == 'percent' ?
      _product!.discount.toString() : PriceConverter.convertPriceWithoutSymbol(context, _product!.discount);
      thumbnailImage = _product!.thumbnail;
      metaImage = _product!.metaImage;
      productImage = _product!.images;
      Provider.of<AddProductController>(context, listen: false).setTaxTypeIndex(_product!.taxModel == 'include' ? 0 : 1, false);
      Provider.of<AddProductTaxController>(Get.context!,listen: false).setProductVatTax(_product?.taxVats);
    }else {
      _product = Product();
    }
    super.initState();
  }

  Future<void> _loadData() async {
    await _load();
    if(Provider.of<AiController>(Get.context!,listen: false).requestTypeImage) {
      Provider.of<AiController>(Get.context!,listen: false).setNextProductNextScreen(true);
      await Provider.of<AiController>(Get.context!,listen: false).generatePricing(
        title: widget.title ?? '',
        langCode: widget.description ?? '',
        uniPriceController: _unitPriceController,
        discountController: _discountController,
        stockQuantityController: Provider.of<VariationController>(Get.context!,listen: false).totalQuantityController,
        minQuantityController: _minimumOrderQuantityController,
        shippingCostController: _shippingCostController
      );

      await Provider.of<AiController>(Get.context!,listen: false).generateVariationSetup(
        title: widget.title ?? '',
        description: widget.description ?? '',
        product: widget.product
      );
      Provider.of<AiController>(Get.context!,listen: false).setNextProductNextScreen(false);
      showCustomSnackBarWidget(getTranslated('tap_next_to_automatically_generate', Get.context!), Get.context!, sanckBarType: SnackBarType.warning);
    }
  }





  Future<void> _asyncMethod() async {
    Future.delayed(const Duration(milliseconds: 800), () async {
      Provider.of<AddProductImageController>(Get.context!,listen: false).getProductImage(widget.product!.id.toString(), isStorePreviousImage: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeController themeProvider = Provider.of<ThemeController>(context, listen: false);

    final ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(0, isUpdate: true);
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(title:  widget.product != null ?
        getTranslated('update_product', context) :
        getTranslated('add_product', context),
        onBackPressed: () {
          Navigator.pop(context);
          Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(0, isUpdate: true);
        },
        ),
        body: Container(decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
          child:  Consumer<VariationController>(
              builder: (context, variationController, child){
              return Consumer<AddProductController>(
                builder: (context, resProvider, child){
                  List<int> brandIds = [];
                  List<String> digitalVariation = ['Audio', 'Video', 'Document', 'Software'];
                  List<int> colors = [];
                  brandIds.add(0);
                  colors.add(0);
                    if (_update && variationController.attributeList != null &&
                        variationController.attributeList!.isNotEmpty) {
                      if(addColor==0) {
                        addColor++;
                        if ( widget.product!.colors != null && widget.product!.colors!.isNotEmpty) {
                          Future.delayed(Duration.zero, () async {
                            Provider.of<VariationController>(Get.context!, listen: false).setAttribute();
                          });
                        }
                        for (int index = 0; index < widget.product!.colors!.length; index++) {
                          colors.add(index);
                          Future.delayed(Duration.zero, () async {
                            variationController.addVariant(Get.context!, 0, widget.product!.colors![index].name, widget.product, false);
                            variationController.addColorCode(widget.product!.colors![index].code, index: index);
                          });
                        }
                      }
                    }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: AddProductTitleBar()),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: GeneratesLeftCount()),

                      Expanded(
                        child:  Consumer<CategoryController>(
                          builder: (context, categoryController, child){
                            return SingleChildScrollView(
                              child: (variationController.attributeList != null &&
                                variationController.attributeList!.isNotEmpty &&
                                categoryController.categoryList != null &&
                                Provider.of<SplashController>(context,listen: false).colorList!= null) ?

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Consumer<AiController>(
                                    builder: (context, aiController, child){
                                      return AddProductSectionWidget(
                                        isAiGenerating: aiController.pricingLoading,
                                        title: getTranslated('pricing_and_others', context)!,
                                        aiWidget: Consumer<AiController>(
                                          builder: (context, aiController, child){
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if(widget.title == null) {
                                                      showCustomSnackBarWidget('${getTranslated('product_name_required', context)}', context);
                                                    } else if (widget.description == null) {
                                                      showCustomSnackBarWidget('${getTranslated('product_description_required', context)}', context);
                                                    } else{
                                                      aiController.generatePricing(
                                                        title: widget.title ?? '',
                                                        langCode: widget.description ?? '',
                                                        uniPriceController: _unitPriceController,
                                                        discountController: _discountController,
                                                        stockQuantityController: variationController.totalQuantityController,
                                                        minQuantityController: _minimumOrderQuantityController,
                                                        shippingCostController: _shippingCostController
                                                      );
                                                    }
                                                  },
                                                  child: !aiController.pricingLoading ? Icon(Icons.auto_awesome, color: Colors.blue) : Shimmer.fromColors(
                                                    baseColor: Theme.of(context).primaryColor,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Row(children: [
                                                      Icon(Icons.auto_awesome, color: Colors.blue),
                                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                                      Text(getTranslated('generating', context) ?? '', style: robotoBold.copyWith(color: Colors.blue)),
                                                    ]),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        ),
                                        childrens: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: Dimensions.paddingSizeLarge),
                                                CustomTextFieldWidget(
                                                  border: true,
                                                  controller: _unitPriceController,
                                                  focusNode: _unitPriceNode,
                                                  textInputAction: TextInputAction.done,
                                                  textInputType: TextInputType.number,
                                                  isAmount: true,
                                                  hintText: getTranslated('unit_price', context)!,
                                                  formProduct: true,
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeLarge),


                                               if(configModel?.systemTaxType == 'product_wise' && configModel?.systemTaxIncludeStatus == 0)
                                                Consumer<AddProductTaxController>(
                                                  builder: (context, addProductTaxController, child) {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(getTranslated('tax_rate', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                                                        DropdownDecoratorWidget(
                                                          child: DropdownButton<TaxVatModel>(
                                                            icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                                                            hint: Text(getTranslated('select_tax_rate', context)!,
                                                              style: robotoRegular.copyWith(
                                                                color: themeProvider.darkTheme ?
                                                                Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                                                                fontSize: Dimensions.fontSizeExtraLarge
                                                              )
                                                            ),
                                                            items: addProductTaxController.taxVatList.map((TaxVatModel? value) {
                                                              bool isSelected = addProductTaxController.isSelected(value!);
                                                              return DropdownMenuItem<TaxVatModel>(
                                                                enabled: !isSelected,
                                                                value: value,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text('${value.name} (${value.taxRate}%)'),
                                                                    if (isSelected)
                                                                      Icon(Icons.check, color: Theme.of(context).primaryColor, size: 18),
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                            onChanged: (TaxVatModel? value) {
                                                              addProductTaxController.addToSelectedTaxList(value!);
                                                            },
                                                            isExpanded: true,
                                                            underline: const SizedBox(),
                                                          ),
                                                        ),

                                                        !addProductTaxController.selectedTaxList.isNotEmpty ?
                                                        const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox.shrink(),

                                                        addProductTaxController.selectedTaxList.isNotEmpty ?
                                                        SizedBox(
                                                          height: addProductTaxController.selectedTaxList.isNotEmpty ? 40 : 0,
                                                          child: ListView.builder(
                                                            itemCount: addProductTaxController.selectedTaxList.length,
                                                            scrollDirection: Axis.horizontal,
                                                            itemBuilder: (context, index) {
                                                              return Padding(
                                                                padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                                                child: Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                                                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.20),
                                                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                  ),
                                                                  child: Row(children: [
                                                                    Consumer<SplashController>(builder: (ctx, colorP,child){
                                                                      return Text(
                                                                        '${addProductTaxController.selectedTaxList[index].name} (${addProductTaxController.selectedTaxList[index].taxRate}%)',
                                                                        style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                      );
                                                                    }),
                                                                    const SizedBox(width: Dimensions.paddingSizeSmall),

                                                                    InkWell(
                                                                      splashColor: Colors.transparent,
                                                                      onTap: (){
                                                                        addProductTaxController.removeToSelectedTaxList (addProductTaxController.selectedTaxList[index], index);
                                                                      },
                                                                      child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                    ),
                                                                  ]),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ) : const SizedBox(),

                                                        addProductTaxController.selectedTaxList.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                                                      ],
                                                    );
                                                  }
                                                ),


                                                ///Discount
                                                ProductDiscountTextFieldWidget(
                                                  formProduct: true,
                                                  focusNode: _discountNode,
                                                  nextNode: _shippingCostNode,
                                                  border: true,
                                                  borderColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                                                  focusBorder: true,
                                                  controller: _discountController,
                                                  textInputAction: TextInputAction.next,
                                                  textInputType: TextInputType.number,
                                                  isAmount: true,
                                                  hintText: getTranslated('discount_amount', context)!,
                                                  isPassword : false,
                                                  isDiscountAmount : resProvider.discountTypeIndex != 0,
                                                  onDiscountTypeChanged : (String? value) {
                                                    resProvider.setDiscountTypeIndex(value == 'percent' ? 0 : 1, true);
                                                  },
                                                ),
                                                const SizedBox(height: Dimensions.iconSizeExtraLarge),


                                                ///Stock Quantity
                                                Consumer<VariationController>(
                                                  builder: (context, variationController, child){
                                                    return Column(
                                                      children: [
                                                        resProvider.productTypeIndex == 0 ?
                                                        CustomTextFieldWidget(
                                                          idDate: variationController.variantTypeList.isNotEmpty,
                                                          border: true,
                                                          textInputType: TextInputType.number,
                                                          focusNode: _totalQuantityNode,
                                                          controller: variationController.totalQuantityController,
                                                          textInputAction: TextInputAction.next,
                                                          isAmount: true,
                                                          hintText: getTranslated('total_quantity', context)!,
                                                          formProduct: true,
                                                        ) : const SizedBox.shrink(),

                                                        resProvider.productTypeIndex == 0 ?
                                                        const SizedBox(height: Dimensions.iconSizeExtraLarge) : const SizedBox.shrink(),
                                                      ],
                                                    );
                                                  }
                                                ),

                                                ///Min order quantity
                                                CustomTextFieldWidget(
                                                  border: true,
                                                  textInputType: TextInputType.number,
                                                  focusNode: _minimumOrderQuantityNode,
                                                  controller: _minimumOrderQuantityController,
                                                  textInputAction: TextInputAction.next,
                                                  isAmount: true,
                                                  hintText: getTranslated('minimum_order_quantity', context)!,
                                                  formProduct: true,
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeLarge),

                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  ),

                                  ///__________Shipping__________
                                  resProvider.productTypeIndex == 0 ?
                                  Consumer<AiController>(
                                    builder: (context, aiController, child){
                                      return AddProductSectionWidget(
                                        isAiGenerating: aiController.pricingLoading,
                                        title: getTranslated('shipping', context)!,
                                        childrens: [
                                          resProvider.productTypeIndex == 0 ?
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                                            child: Column(children: [
                                              const SizedBox(height: Dimensions.paddingSizeSmall),

                                              Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                                  CustomTextFieldWidget(
                                                    border: true,
                                                    controller: _shippingCostController,
                                                    focusNode: _shippingCostNode,
                                                    nextNode: _totalQuantityNode,
                                                    textInputAction: TextInputAction.next,
                                                    textInputType: TextInputType.number,
                                                    isAmount: true,
                                                    hintText: getTranslated('shipping_cost', context)!,
                                                    formProduct: true,
                                                    // isAmount: true,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeDefault,),

                                              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                Expanded(
                                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(getTranslated('shipping_cost_multiply', context)!,
                                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)
                                                        ),
                                                      ),
                                                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                                      Text(getTranslated('shipping_cost_multiply_by_item', context)!,
                                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                                                            color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                                FlutterSwitch(width: 60.0, height: 30.0, toggleSize: 30.0,
                                                  value: resProvider.isMultiply,
                                                  borderRadius: 20.0,
                                                  activeColor: Theme.of(context).primaryColor,
                                                  padding: 1.0,
                                                  onToggle:(bool isActive) => resProvider.toggleMultiply(context),
                                                ),

                                              ]),
                                              const SizedBox(height: Dimensions.iconSizeLarge),
                                            ],),
                                          ) : const SizedBox(),
                                        ],
                                      );
                                    }
                                  ) : const SizedBox(),


                                  resProvider.productTypeIndex == 0 ?
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault
                                      ),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(getTranslated('variations', context)!,
                                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)
                                          ),

                                          if(Provider.of<SplashController>(context,listen: false).configModel?.isAiFeatureActive == 1)
                                          Consumer<AiController>(
                                            builder: (context, aiController, child) {
                                              return InkWell(
                                                  onTap: () {
                                                    if(widget.title == null) {
                                                      showCustomSnackBarWidget('${getTranslated('product_name_required', context)}', context);
                                                    } else if (widget.description == null) {
                                                      showCustomSnackBarWidget('${getTranslated('product_description_required', context)}', context);
                                                    } else{
                                                      aiController.generateVariationSetup(
                                                        title: widget.title ?? '',
                                                        description: widget.description ?? '',
                                                        product: widget.product
                                                      );
                                                    }
                                                  },
                                                  child: !aiController.variationLoading ? Icon(Icons.auto_awesome, color: Colors.blue) : Shimmer.fromColors(
                                                    baseColor: Theme.of(context).primaryColor,
                                                    highlightColor: Colors.grey[100]!,
                                                    child: Row(children: [
                                                      Icon(Icons.auto_awesome, color: Colors.blue),
                                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                                      Text(getTranslated('generating', context) ?? '', style: robotoBold.copyWith(color: Colors.blue)),
                                                    ]),
                                                  ),
                                                );
                                            }
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                    Consumer<AiController>(
                                      builder: (context, aiController, child) {
                                        return AddProductSectionWidget(
                                          isAiGenerating: aiController.variationLoading,
                                          childrens: [
                                            const SizedBox(height: Dimensions.paddingSizeSmall),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                              child: Row(children: [
                                                Text(getTranslated('add_color_variation', context)!,
                                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                                const Spacer(),

                                                FlutterSwitch(width: 60.0, height: 30.0, toggleSize: 28.0,
                                                  value: variationController.attributeList![0].active,
                                                  borderRadius: 20.0,
                                                  activeColor: Theme.of(context).primaryColor,
                                                  padding: 1.0,
                                                  onToggle:(bool isActive) => variationController.toggleAttribute(context, 0, widget.product),
                                                ),
                                              ],),
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),

                                            variationController.attributeList![0].active ?
                                            Consumer<SplashController>(builder: (ctx, colorProvider, child) {
                                              if (colorProvider.colorList != null) {
                                                for (int index = 0; index < colorProvider.colorList!.length; index++) {
                                                  colors.add(index);
                                                }
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                                child: Autocomplete<int>(
                                                  optionsBuilder: (TextEditingValue value) {
                                                    if (value.text.isEmpty) {
                                                      return const Iterable<int>.empty();
                                                    } else {
                                                      return _getColorSuggestionsIndexList(
                                                        colors: colors,
                                                        colorList: colorProvider.colorList,
                                                        savedColorVariationList: variationController.attributeList?.first.variants ?? [],
                                                        pattern: value.text,
                                                      );
                                                    }
                                                  },
                                                  fieldViewBuilder: (context, controller, node, onComplete) {
                                                    return Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(color: Theme.of(context).cardColor,
                                                        border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha:.50)),
                                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                      ),
                                                      child: TextField(
                                                        controller: controller,
                                                        focusNode: node, onEditingComplete: onComplete,
                                                        decoration: InputDecoration(
                                                          hintText: getTranslated('type_color_name', context),
                                                          border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(
                                                                  Dimensions.paddingSizeSmall),
                                                              borderSide: BorderSide.none),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  displayStringForOption: (value) => colorProvider.colorList![value].name!,
                                                  onSelected: (int value) {
                                                    variationController.addVariant(context, 0,colorProvider.colorList![value].name, widget.product, true);
                                                    variationController.addColorCode(colorProvider.colorList![value].code);
                                                  },
                                                ),
                                              );
                                            }) : const SizedBox(),
                                            SizedBox(height: (variationController.attributeList![0].variants.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

                                            if(variationController.attributeList?[0].active ?? false) Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                              child: SizedBox(height: (variationController.attributeList![0].variants.isNotEmpty) ? 40 : 0,
                                                child: (variationController.attributeList![0].variants.isNotEmpty) ?
                                                ListView.builder(
                                                  itemCount: variationController.attributeList![0].variants.length,
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (context, index) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.20),
                                                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                        ),
                                                        child: Row(children: [
                                                          Consumer<SplashController>(builder: (ctx, colorP,child){
                                                            return Text(variationController.attributeList![0].variants[index]!,
                                                              style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),);
                                                          }),
                                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                                                          InkWell(
                                                            splashColor: Colors.transparent,
                                                            onTap: (){
                                                              variationController.removeVariant(context, 0, index, widget.product);
                                                              variationController.removeColorCode(index);
                                                            },
                                                            child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                          ),
                                                        ]),
                                                      ),
                                                    );
                                                  },
                                                ):const SizedBox(),
                                              ),
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),

                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                              child: AttributeViewWidget(product: widget.product, colorOn: variationController.attributeList![0].active),
                                            ),
                                          ],
                                        );
                                      }
                                    ),




                                  ]) : const SizedBox(),
                                  SizedBox(height: resProvider.productTypeIndex == 0 ? 0 : Dimensions.paddingSizeDefault),

                                  resProvider.productTypeIndex == 1 ?
                                  Consumer<DigitalProductController>(
                                    builder: (context, digitalProductController, _) {
                                      return Column(
                                        children: [
                                          AddProductSectionWidget(
                                            title: getTranslated('variation_setup', context)!,
                                            childrens: [

                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                                  Text(getTranslated('file_type', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                                                  DropdownDecoratorWidget(
                                                    child: DropdownButton<String>(
                                                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                                                      hint: Text(getTranslated('select_file_type', context)!,
                                                        style: robotoRegular.copyWith(
                                                          color: themeProvider.darkTheme ?
                                                          Theme.of(context).textTheme.bodyLarge?.color
                                                          : Theme.of(context).hintColor,
                                                          fontSize: Dimensions.fontSizeExtraLarge)),
                                                      items: digitalVariation.map((String? value) {
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value!),
                                                        );
                                                      }).toList(),
                                                      onChanged: (String? value) {
                                                        if(digitalProductController.selectedDigitalVariation.contains(value)){
                                                          showCustomSnackBarWidget(getTranslated('filetype_already_exists', context), context, sanckBarType: SnackBarType.warning);
                                                        } else{
                                                          digitalProductController.addDigitalProductVariation(value!);
                                                        }
                                                      },
                                                      isExpanded: true,
                                                      underline: const SizedBox(),
                                                    ),
                                                  ),

                                                  !digitalProductController.selectedDigitalVariation.isNotEmpty ?
                                                  const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox.shrink(),

                                                  digitalProductController.selectedDigitalVariation.isNotEmpty ?
                                                  SizedBox(
                                                    height: digitalProductController.selectedDigitalVariation.isNotEmpty ? 40 : 0,
                                                    child: ListView.builder(
                                                      itemCount: digitalProductController.selectedDigitalVariation.length,
                                                      scrollDirection: Axis.horizontal,
                                                      itemBuilder: (context, index) {
                                                        return Padding(
                                                          padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.20),
                                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                            ),
                                                            child: Row(children: [
                                                              Consumer<SplashController>(builder: (ctx, colorP,child){
                                                                return Text(
                                                                  digitalProductController.selectedDigitalVariation[index],
                                                                  style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                );
                                                              }),
                                                              const SizedBox(width: Dimensions.paddingSizeSmall),

                                                              InkWell(
                                                                splashColor: Colors.transparent,
                                                                onTap: (){
                                                                  digitalProductController.removeDigitalVariant(context, index);
                                                                },
                                                                child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                              ),
                                                            ]),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ) : const SizedBox(),

                                                  digitalProductController.selectedDigitalVariation.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                                                ],),
                                              ),
                                            ],
                                          ),

                                          ListView.builder(
                                            itemCount: digitalProductController.selectedDigitalVariation.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return AddProductSectionWidget(
                                                  title: '${digitalProductController.selectedDigitalVariation[index]} ${getTranslated('extension', context)!}',
                                                  titleStyle: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                                  childrens: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                                                      child: Column(
                                                        children: [
                                                          const SizedBox(height: Dimensions.paddingSizeSmall),

                                                          CustomTextFieldWidget(
                                                            formProduct: true,
                                                            required: true,
                                                            border: true,
                                                            controller: digitalProductController.extentionControllerList[index],
                                                            textInputAction: TextInputAction.done,
                                                            textInputType: TextInputType.text,
                                                            isAmount: false,
                                                            hintText: '${digitalProductController.selectedDigitalVariation[index]} ${getTranslated('extension', context)!}',
                                                            onFieldSubmit: (String value) {
                                                              if(digitalProductController.digitalVariationExtantion[index].contains(value)){
                                                                showCustomSnackBarWidget(getTranslated('extension_already_exists', context), context, sanckBarType: SnackBarType.warning);
                                                              } else if(value.trim() != ''){
                                                                digitalProductController.addExtension(index, value);
                                                              }
                                                            },
                                                          ),


                                                          digitalProductController.digitalVariationExtantion[index].isNotEmpty ?
                                                          const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                                                          digitalProductController.digitalVariationExtantion[index].isNotEmpty ?
                                                          SizedBox(
                                                            height: digitalProductController.digitalVariationExtantion[index].isNotEmpty ? 40 : 0,
                                                            child: ListView.builder(
                                                              itemCount: digitalProductController.digitalVariationExtantion[index].length,
                                                              scrollDirection: Axis.horizontal,
                                                              itemBuilder: (context, i) {
                                                                return Padding(
                                                                  padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                                                    decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.20),
                                                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                                                    ),
                                                                    child: Row(children: [
                                                                      Consumer<SplashController>(builder: (ctx, colorP,child){
                                                                        return Text(digitalProductController.digitalVariationExtantion[index][i],
                                                                          style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),);
                                                                      }),
                                                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                      InkWell(
                                                                        splashColor: Colors.transparent,
                                                                        onTap: (){
                                                                          digitalProductController.removeExtension(index, i);
                                                                        },
                                                                        child: Icon(Icons.close, size: 15, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                                                      ),
                                                                    ]),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ) : const SizedBox(),

                                                          const SizedBox(height: Dimensions.paddingSizeSmall)
                                                        ],
                                                      ),
                                                    ),
                                                  ]
                                              );
                                            },
                                          ),

                                          Provider.of<SplashController>(context, listen: false).configModel!.digitalProductSetting == "1" && digitalProductController.selectedDigitalVariation.isEmpty?
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                            child: DigitalProductWidget(resProvider: resProvider, product: widget.product, fromAddProductNextScreen: true)) : const SizedBox(),

                                          digitalProductController.shouldShowUploadFile() ?
                                          AddProductSectionWidget(
                                            title: getTranslated('variation_wise_file_upload', context)!,
                                            childrens: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                                                child: ListView.builder(
                                                  itemCount: digitalProductController.selectedDigitalVariation.length,
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    return ListView.builder(
                                                      itemCount: digitalProductController.variationFileList[index].length,
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context, i) {
                                                        return Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                              color: Theme.of(context).primaryColor.withValues(alpha:0.10),
                                                            ),
                                                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('${digitalProductController.selectedDigitalVariation[index]}-${digitalProductController.digitalVariationExtantion[index][i]} ${getTranslated('file', context)!}',
                                                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                                                ),
                                                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                                                Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(children: [
                                                                      CustomTextFieldWidget(
                                                                        border: true,
                                                                        controller: digitalProductController.variationFileList[index][i].priceController,
                                                                        textInputAction: TextInputAction.done,
                                                                        textInputType: TextInputType.number,
                                                                        isAmount: false,
                                                                        hintText: getTranslated('price_s', context)!,
                                                                        onFieldSubmit: (String value) {
                                                                          if(value.trim() != ''){
                                                                            // resProvider.addExtension(index, value);
                                                                          }
                                                                        },
                                                                      ),
                                                                      const SizedBox(height: Dimensions.paddingSizeMedium),

                                                                      CustomTextFieldWidget(
                                                                        border: true,
                                                                        controller: digitalProductController.variationFileList[index][i].skuController,
                                                                        textInputAction: TextInputAction.done,
                                                                        textInputType: TextInputType.text,
                                                                        isAmount: false,
                                                                        hintText: getTranslated('sku', context)!,
                                                                        onFieldSubmit: (String value) {
                                                                          if(value.trim() != ''){
                                                                            // resProvider.addExtension(index, value);
                                                                          }
                                                                        },
                                                                      )
                                                                    ],),
                                                                  ),
                                                                  const SizedBox(width: Dimensions.paddingSizeMedium,),

                                                                  Provider.of<DigitalProductController>(context,listen: false).digitalProductTypeIndex == 1 ?
                                                                  Expanded(
                                                                      flex: 1,
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                                                                          color: Theme.of(context).highlightColor,
                                                                        ),
                                                                        child: DottedBorder(
                                                                          options: RoundedRectDottedBorderOptions(
                                                                            dashPattern: const [4,5],
                                                                            color: digitalProductController.variationFileList[index][i].fileName == null ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
                                                                            radius: const Radius.circular(Dimensions.paddingEye),
                                                                          ),
                                                                          child: InkWell(
                                                                            onTap: () {
                                                                              digitalProductController.pickFileForDigitalProduct(index, i);
                                                                            },
                                                                            child: Container(
                                                                              height: Dimensions.uploadFile,
                                                                              width: double.infinity,
                                                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                                                              decoration: BoxDecoration(
                                                                                color: Theme.of(context).highlightColor,
                                                                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                                                              ),
                                                                              child: Column(mainAxisAlignment: digitalProductController.variationFileList[index][i].fileName == null ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                                                                                children: digitalProductController.variationFileList[index][i].fileName == null ? [
                                                                                  Image.asset(Images.uploadIcon, height: 32, width: 32),
                                                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                                                  Text(getTranslated('file_upload', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                                                                                ] : [
                                                                                  Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                                                                                    digitalProductController.isDigitalVariationLoading[index][i] ?
                                                                                    const SizedBox(height: 30, width: 30, child: CircularProgressIndicator()) :
                                                                                    InkWell(
                                                                                        onTap: (){
                                                                                          if(_update){
                                                                                            digitalProductController.deleteDigitalVariationFile(_product!.id!, index, i);
                                                                                          } else {
                                                                                            digitalProductController.removeFileForDigitalProduct(index, i);
                                                                                          }
                                                                                        },
                                                                                        child: Image.asset(Images.digitalPreviewDeleteIcon, height: 20, width: 20)
                                                                                    ),
                                                                                  ],),
                                                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                                                                                  SizedBox(width: 20, child: Image.asset(Images.digitalPreviewFileIcon) ),
                                                                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                                                                  Expanded(child: Text(digitalProductController.variationFileList[index][i].fileName ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis)),
                                                                                  //deleteIcon
                                                                                ],
                                                                              ),

                                                                            ),
                                                                          ) ,
                                                                        ),
                                                                      )
                                                                  ) : const SizedBox.shrink(),
                                                                ]),

                                                                Provider.of<DigitalProductController>(context,listen: false).digitalProductTypeIndex == 1 ?
                                                                const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ) : const SizedBox(),

                                          UploadPreviewFileWidget(product: widget.product),
                                        ],
                                      );
                                    }
                                  ) : const SizedBox(),
                                ]): const Padding(
                                padding: EdgeInsets.only(top: 300.0),
                                child: Center(child: CircularProgressIndicator())
                              ),
                            );
                          }
                        ),
                      ),



                      Consumer<AiController>(
                        builder: (context, aiController, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                                  spreadRadius: 0.5, blurRadius: 0.3)],
                            ),
                            height: 80,

                            child: aiController.addProductNextScreenLoading ?
                            Container(width: MediaQuery.of(context).size.width, height: 40,
                                margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                          getTranslated('ai_is_generating_product_details', context) ?? '',
                                          style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                          maxLines: 2,
                                        )
                                    ),

                                    SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Shimmer.fromColors(
                                      baseColor: Theme.of(context).primaryColor,
                                      highlightColor: Colors.grey[100]!,
                                      child: Row(children: [
                                        Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                        Text(getTranslated('generating', context) ?? '', style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                                      ]),
                                    ),
                                  ],
                                )
                            ):

                            Row(children: [
                            Expanded(child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: (){
                                Navigator.pop(context);
                                resProvider.setSelectedPageIndex(0, isUpdate: true);
                              },
                              child: CustomButtonWidget(
                                isColor: true,
                                btnTxt: '${getTranslated('go_back', context)}',
                                backgroundColor: Theme.of(context).hintColor.withValues(alpha: .6),
                                buttonHeight: 55,
                              ),
                            )),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Expanded(child: Consumer<VariationController>(
                                builder: (context, variationController, _) {
                                return Consumer<AiController>(
                                  builder: (context, aiController, _) {
                                    return Consumer<AddProductController>(
                                        builder: (context,resProvider, _) {
                                          return resProvider.isLoading ? const Center(child: SizedBox(height: 35, width: 35, child: CircularProgressIndicator())) : CustomButtonWidget(
                                            btnTxt:  getTranslated('next', context), buttonHeight: 55,
                                            onTap: () {
                                              final digitalProductController = Provider.of<DigitalProductController>(Get.context!,listen: false);

                                              bool digitalProductVariationEmpty = false;
                                              bool isTitleEmpty = false;
                                              bool isFileEmpty = false;
                                              bool isPriceEmpty = false;
                                              bool isSKUEmpty = false;


                                              for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                if(digitalProductController.digitalVariationExtantion[index].isEmpty) {
                                                  digitalProductVariationEmpty = true;
                                                  break;
                                                }
                                              }

                                              for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                  if(digitalProductController.variationFileList[index][i].fileName == null) {
                                                    isFileEmpty = true;
                                                    break;
                                                  }
                                                }
                                              }

                                              for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                  if(digitalProductController.variationFileList[index][i].priceController?.text.trim() == ''){
                                                    isPriceEmpty = true;
                                                    break;
                                                  }
                                                }
                                              }

                                              for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                  if(digitalProductController.variationFileList[index][i].skuController?.text.trim() == ''){
                                                    isSKUEmpty = true;
                                                    break;
                                                  }
                                                }
                                              }

                                              for (int index = 0; index < digitalProductController.selectedDigitalVariation.length; index++) {
                                                for(int i =0; i< digitalProductController.variationFileList[index].length; i++) {
                                                  if(digitalProductController.variationFileList[index][i].fileName == null){
                                                    isTitleEmpty = true;
                                                    break;
                                                  }
                                                }
                                              }


                                              String unitPrice =_unitPriceController.text.trim();
                                              String currentStock = Provider.of<VariationController>(context,listen: false).totalQuantityController.text.trim();
                                              String orderQuantity = _minimumOrderQuantityController.text.trim();
                                              List<int?> taxIds = Provider.of<AddProductTaxController>(Get.context!, listen: false).selectedTaxList.map((tax) => tax.id).toList();
                                              String discount = _discountController.text.trim();
                                              String shipping = _shippingCostController.text.trim();
                                              bool haveBlankVariant = false;
                                              bool blankVariantPrice = false;
                                              bool blankVariantQuantity = false;

                                              for (AttributeModel attr in variationController.attributeList!) {

                                                if (attr.active && attr.variants.isEmpty) {
                                                  haveBlankVariant = true;
                                                  break;
                                                }
                                              }

                                              for (VariantTypeModel variantType in variationController.variantTypeList) {
                                                if (variantType.controller.text.isEmpty) {
                                                  blankVariantPrice = true;
                                                  break;
                                                }
                                              }
                                              for (VariantTypeModel variantType in variationController.variantTypeList) {
                                                if (variantType.qtyController.text.isEmpty) {
                                                  blankVariantQuantity = true;
                                                  break;
                                                }
                                              }
                                              if (unitPrice.isEmpty) {
                                                showCustomSnackBarWidget(getTranslated('enter_unit_price', context),context,  sanckBarType: SnackBarType.warning);
                                              }
                                              // else if (resProvider.taxTypeIndex == -1) {
                                              //   showCustomSnackBarWidget(getTranslated('select_tax_model', context),context,  sanckBarType: SnackBarType.warning);
                                              // }

                                              else if (currentStock.isEmpty &&  resProvider.productTypeIndex == 0) {
                                                showCustomSnackBarWidget(getTranslated('enter_total_quantity', context),context,  sanckBarType: SnackBarType.warning);
                                              }
                                              else if (orderQuantity.isEmpty) {
                                                showCustomSnackBarWidget(getTranslated('enter_minimum_order_quantity', context),context,  sanckBarType: SnackBarType.warning);
                                              }
                                              else if (haveBlankVariant) {
                                                showCustomSnackBarWidget(getTranslated('add_at_least_one_variant_for_every_attribute',context),context,  sanckBarType: SnackBarType.warning);
                                              } else if (blankVariantPrice) {
                                                showCustomSnackBarWidget(getTranslated('enter_price_for_every_variant', context),context,  sanckBarType: SnackBarType.warning);
                                              }else if (blankVariantQuantity) {
                                                showCustomSnackBarWidget(getTranslated('enter_quantity_for_every_variant', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if (resProvider.productTypeIndex == 0 && _shippingCostController.text.isEmpty) {
                                                showCustomSnackBarWidget(getTranslated('enter_shipping_cost', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if(_update && resProvider.productTypeIndex == 1 && digitalProductController.digitalProductTypeIndex == 1 && isFileEmpty) {
                                                showCustomSnackBarWidget(getTranslated('digital_product_file_empty', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if(!_update && resProvider.productTypeIndex == 1 && digitalProductController.digitalProductTypeIndex == 1 && isFileEmpty) {
                                                showCustomSnackBarWidget(getTranslated('digital_product_file_empty', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if(resProvider.productTypeIndex == 1 && isPriceEmpty) {
                                                showCustomSnackBarWidget(getTranslated('digital_product_price_empty', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if(resProvider.productTypeIndex == 1 && isSKUEmpty) {
                                                showCustomSnackBarWidget(getTranslated('digital_product_sku_empty', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if(resProvider.productTypeIndex == 1 && digitalProductVariationEmpty) {
                                                showCustomSnackBarWidget(getTranslated('digital_product_variation_empty', context),context,  sanckBarType: SnackBarType.warning);
                                              } else if (!_update && (resProvider.productTypeIndex == 1 && digitalProductController.digitalProductTypeIndex == 1 &&
                                                  digitalProductController.selectedFileForImport == null) && digitalProductController.selectedDigitalVariation.isEmpty) {
                                                showCustomSnackBarWidget(getTranslated('please_choose_digital_product',context),context,  sanckBarType: SnackBarType.warning);
                                              }  else if(configModel?.systemTaxType == 'product_wise' && configModel?.systemTaxIncludeStatus == 0 && Provider.of<AddProductTaxController>(Get.context!,listen: false).selectedTaxList.isEmpty) {
                                                showCustomSnackBarWidget(getTranslated('please_add_your_product_tax', context),context,  sanckBarType: SnackBarType.warning);
                                              } else {
                                                if(resProvider.productTypeIndex == 1 &&digitalProductController.digitalProductTypeIndex == 1 &&
                                                    digitalProductController.selectedFileForImport != null && digitalProductController.selectedDigitalVariation.isEmpty) {
                                                  digitalProductController.uploadDigitalProduct(Provider.of<AuthController>(context,listen: false).getUserToken());
                                                }
                                                resProvider.setSelectedPageIndex(2, isUpdate: true);
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductSeoScreen(
                                                  unitPrice: unitPrice,
                                                  tax: taxIds,
                                                  unit: widget.unit,
                                                  categoryId: widget.categoryId,
                                                  subCategoryId: widget.subCategoryId,
                                                  subSubCategoryId: widget.subSubCategoryId,
                                                  brandyId: widget.brandId,
                                                  discount: discount,
                                                  currentStock: currentStock,
                                                  minimumOrderQuantity: orderQuantity,
                                                  shippingCost: shipping,
                                                  product: widget.product, addProduct: widget.addProduct,
                                                  title: widget.title,
                                                  description: widget.description,
                                                )));
                                              }
                                            },
                                          );
                                        }
                                    );
                                  }
                                );
                              }
                            )),
                          ],),);
                        }
                      )

                    ],
                  );
                },
              );
            }
          ),
        ),
      ),
    );
  }

  Iterable<int> _getColorSuggestionsIndexList({
    required List<int> colors,
    required List<ColorList>? colorList,
    required List<String?> savedColorVariationList,
    required String pattern,
  }) {
    return colors.where((colorIndex) => colorList![colorIndex].name!.toLowerCase().contains(pattern.toLowerCase())
        && !(savedColorVariationList.contains(colorList[colorIndex].name)));
  }
}
