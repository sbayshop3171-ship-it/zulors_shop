import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/data/model/image_full_url.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/add_product_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/image_model.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/add_product_title_bar.dart';
import 'package:zulors_shop_vendor/features/addProduct/widgets/meta_seo_widget.dart';
import 'package:zulors_shop_vendor/features/ai/controllers/ai_controller.dart';
import 'package:zulors_shop_vendor/features/ai/widgets/genertate_count_widget.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/shop/controllers/shop_controller.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:textfield_tags/textfield_tags.dart';

class AddProductSeoScreen extends StatefulWidget {
  final ValueChanged<bool>? isSelected;
  final Product? product;
  final String? unitPrice;
  final String? discount;
  final String? currentStock;
  final String? minimumOrderQuantity;
  final List<int?>? tax;
  final String? shippingCost;
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandyId;
  final String? unit;
  final String? title;
  final String? description;
  final AddProductModel? addProduct;

  const AddProductSeoScreen({
    super.key, this.isSelected, required this.product, required this.addProduct,
    this.unitPrice, this.tax, this.discount, this.currentStock, this.shippingCost, this.categoryId, this.subCategoryId,
    this.subSubCategoryId, this.brandyId, this.unit, this.minimumOrderQuantity, this.title, this.description
  });

  @override
  AddProductSeoScreenState createState() => AddProductSeoScreenState();
}

class AddProductSeoScreenState extends State<AddProductSeoScreen> {
  bool isSelected = false;
  final FocusNode _seoTitleNode = FocusNode();
  final FocusNode _seoDescriptionNode = FocusNode();
  final FocusNode _youtubeLinkNode = FocusNode();
  final TextEditingController _seoTitleController = TextEditingController();
  final TextEditingController _seoDescriptionController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  AutoCompleteTextField? searchTextField;
  late double _distanceToField;
  TextfieldTagsController? _controller;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();
  SimpleAutoCompleteTextField? textField;
  bool showWhichErrorText = false;
  late bool _update;
  Product? _product;
  AddProductModel? _addProduct;
  String? thumbnailImage ='', metaImage ='';
  int counter = 0, total = 0;
  int addColor = 0;
  List<String> tagList = [];
  final categoryController = Provider.of<CategoryController>(Get.context!,listen: false);



  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  void initState() {
    super.initState();

    _product = widget.product;
    _update = widget.product != null;
    _addProduct = widget.addProduct;
    if(_update) {
      if(_product!.tags != null) {
        for(int i = 0; i< _product!.tags!.length; i++){
          tagList.add(_product!.tags![i].tag!);
        }
      }
      _seoTitleController.text = _product!.metaSeoInfo != null ? _product!.metaSeoInfo?.metaTitle ?? '' : _product!.metaTitle ?? '' ;
      _seoDescriptionController.text = _product!.metaSeoInfo != null ? _product!.metaSeoInfo?.metaDescription ?? '' : _product!.metaDescription ?? '';
      thumbnailImage = _product!.thumbnail;
      metaImage = _product!.metaImage;
      _youtubeLinkController.text = _product?.videoUrl ?? '';


      if(_product?.imagesFullUrl != null) {
        List<Map<String, dynamic>>? productImages = [];
        for(int i = 0; i< _product!.imagesFullUrl!.length; i++){
          productImages.add({
            "image_name" : _product?.imagesFullUrl?[i].key ?? '',
            "storage" : null,
          });
        }
        // Provider.of<AddProductController>(context,listen: false).productReturnImage = productImages;
      }
    }else {
      _product = Product();
      _addProduct = AddProductModel();
    }
    _controller = TextfieldTagsController();


    if((Provider.of<AiController>(context, listen: false).generalSetupModel?.data?.searchTags ?? []).isNotEmpty) {
      for(int i = 0; i< (Provider.of<AiController>(context, listen: false).generalSetupModel?.data?.searchTags ?? []).length; i++) {
        if(!tagList.contains(Provider.of<AiController>(context, listen: false).generalSetupModel?.data?.searchTags ?? '')) {
          tagList.add(Provider.of<AiController>(context, listen: false).generalSetupModel?.data?.searchTags?[i] ?? '');
        }
      }
    }

    _loadData();
  }


  Future<void> _loadData() async {
    if(Provider.of<AiController>(Get.context!,listen: false).requestTypeImage) {
      await Provider.of<AiController>(Get.context!,listen: false).generateMetaSeoSetup(
        title: widget.title ?? '',
        description: widget.description ?? '',
        seoTitleController: _seoTitleController,
        seoDescriptionController: _seoDescriptionController,
        formInit: true
      );
    }
    Provider.of<AiController>(Get.context!,listen: false).setRequestType(false, willUpdate: false);
  }


  Future<void> route(bool isRoute, String name, String type, String? colorCode) async {

    if (isRoute) {
      if(type == 'meta'){metaImage = name;}
      else if(type == 'thumbnail'){thumbnailImage = name;}
      if(_update){
        int withc = 0, withOurC = 0;

        if(Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.isNotEmpty) {
          for(int index=0; index<Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.length; index++) {
            String retColor = Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor[index].color!;
            String? bb;
            if(retColor.contains('#')){
              bb = retColor.replaceAll('#', '');
            }
            if(bb == colorCode) {
              Provider.of<AddProductImageController>(Get.context!,listen: false).setStringImage(index, name, colorCode!);
              break;
            }
          }
        }


        for(int i = 0; i< Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.length; i++){
          if(Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor[i].image != null){
            withc++;
          }
        }

        for(int i = 0; i< Provider.of<AddProductImageController>(Get.context!,listen: false).withoutColor.length; i++){
          if(Provider.of<AddProductImageController>(Get.context!,listen: false).withoutColor[i].image != null){
            withOurC++;
          }
        }

      }else {

        if(Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.isNotEmpty) {
          for(int index=0; index<Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.length; index++) {
            String retColor = Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor[index].color!;
            String? bb;
            if(retColor.contains('#')){
              bb = retColor.replaceAll('#', '');
            }
            if(bb == colorCode) {
              Provider.of<AddProductImageController>(Get.context!,listen: false).setStringImage(index, name, colorCode!);
              break;
            }
          }
        }
        if(Provider.of<AddProductImageController>(Get.context!,listen: false).withoutColor.isNotEmpty) {
          for(int index=0; index<Provider.of<AddProductImageController>(Get.context!,listen: false).withoutColor.length; index++) {
          }
        }

        counter++;

        if(metaImage == ''){
          total = Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.length+ Provider.of<AddProductImageController>(Get.context!,listen: false).withoutColor.length + 1;
        }else{
          total = Provider.of<AddProductImageController>(Get.context!,listen: false).imagesWithColor.length+ Provider.of<AddProductImageController>(Get.context!,listen: false).withoutColor.length + 2;
        }

        if(counter == total) {
          counter++;
          Provider.of<AddProductController>(Get.context!,listen: false).addProduct(context, _product!, _addProduct!, thumbnailImage, metaImage, !_update, tagList);
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final addProductImageController = Provider.of<AddProductImageController>(context, listen: false);


    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(1, isUpdate: true);
      },

      child: Scaffold(
        appBar: CustomAppBarWidget(title:  widget.product != null ?
        getTranslated('update_product', context):
        getTranslated('add_product', context),
        onBackPressed: () {
          Navigator.pop(context);
          Provider.of<AddProductController>(context,listen: false).setSelectedPageIndex(1, isUpdate: true);
        },
        ),
        body: SafeArea(child: Consumer<VariationController>(
            builder: (context, variationController, child){
            return Consumer<AddProductController>(
              builder: (context, resProvider, child){
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: AddProductTitleBar()),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      child: GeneratesLeftCount()),

                    Expanded(
                      child: SingleChildScrollView(
                        child: (variationController.attributeList != null &&
                          variationController.attributeList!.isNotEmpty &&
                          categoryController.categoryList != null &&
                          Provider.of<SplashController>(context,listen: false).colorList!= null) ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0),
                              child: Column(children: [
                                const SizedBox(height: Dimensions.paddingSizeSmall),



                                AddProductSectionWidget(
                                  childrenPadding:Dimensions.paddingSizeMedium,
                                  title: getTranslated('tags', context)!,
                                  childrens: [
                                    const SizedBox(height: Dimensions.paddingSizeDefault),
                                    TextFieldTags(
                                      textfieldTagsController: _controller,
                                      initialTags:(tagList.isNotEmpty)  ?  tagList : const [],
                                      textSeparators: const [' ', ','],
                                      letterCase: LetterCase.normal,
                                      validator: (String? tag) {
                                        if (tag == 'php') {
                                          return 'No, please just no';
                                        } else if (_controller!.getTags!.contains(tag)) {
                                          return 'you already entered that';
                                        }
                                        return null; // must return String? (null = no error)
                                      },

                                      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
                                        return (context, sc, tags, onTagDelete) {
                                          tagList = tags;
                                          return TextField(
                                            controller: tec,
                                            focusNode: fn,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).primaryColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).hintColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context).primaryColor,
                                                  width: 1.0,
                                                ),
                                              ),
                                              helperText: '',
                                              helperStyle: TextStyle(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                              hintText: _controller!.hasTags ? '' : "Enter tag...",
                                              hintStyle: TextStyle(color: Theme.of(context).hintColor),
                                              errorText: error,
                                              prefixIconConstraints:
                                              BoxConstraints(maxWidth: _distanceToField * 0.74),
                                              prefixIcon: tags.isNotEmpty
                                                  ? SingleChildScrollView(
                                                controller: sc,
                                                scrollDirection: Axis.horizontal,
                                                child: Row(children: tags.map((String? tag) {
                                                  return Container(decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                                                      color: Theme.of(context).primaryColor),
                                                    margin: const EdgeInsets.symmetric( horizontal: 5.0),
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                                    child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                      Text('$tag', style: const TextStyle(color: Colors.white)),
                                                      const SizedBox(width: 4.0),

                                                      InkWell(
                                                        splashColor: Colors.transparent,
                                                        child: const Icon(Icons.cancel, size: 14.0,
                                                            color: Color.fromARGB(255, 233, 233, 233)),
                                                        onTap: () {
                                                          onTagDelete(tag!);},
                                                      )
                                                    ],
                                                    ),
                                                  );
                                                }).toList()),
                                              )
                                                  : null,
                                            ),
                                            onChanged: onChanged,
                                            onSubmitted: onSubmitted,
                                          );
                                        };
                                      },
                                    ),
                                  ],
                                ),



                                Consumer<AiController> (
                                  builder: (context, aiController, child) {
                                    return AddProductSectionWidget(
                                      isAiGenerating: aiController.metaSeoLoading,
                                      childrenPadding: Dimensions.paddingSizeMedium,
                                      title: getTranslated('product_seo_settings', context) ?? ' ',

                                      aiWidget: Consumer<AiController> (
                                          builder: (context, aiController, child) {
                                            return InkWell(
                                              onTap: () {
                                                if(widget.title == null) {
                                                  showCustomSnackBarWidget('${getTranslated('product_name_required', context)}', context);
                                                } else if (widget.description == null) {
                                                  showCustomSnackBarWidget('${getTranslated('product_description_required', context)}', context);
                                                } else{
                                                  aiController.generateMetaSeoSetup(
                                                      title: widget.title ?? '',
                                                      description: widget.description ?? '',
                                                      seoTitleController: _seoTitleController,
                                                      seoDescriptionController: _seoDescriptionController
                                                  );
                                                }
                                              },
                                              child: !aiController.metaSeoLoading ? Icon(Icons.auto_awesome, color: Colors.blue) : Shimmer.fromColors(
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

                                      childrens: [
                                        const SizedBox(height: Dimensions.paddingSizeDefault),

                                        CustomTextFieldWidget(
                                          formProduct: true,
                                          border: true,
                                          textInputType: TextInputType.name,
                                          focusNode: _seoTitleNode,
                                          controller: _seoTitleController,
                                          nextNode: _seoDescriptionNode,
                                          textInputAction: TextInputAction.next,
                                          hintText: getTranslated('meta_title', context),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),


                                        CustomTextFieldWidget(
                                          formProduct: true,
                                          isDescription:true,
                                          border: true,
                                          controller: _seoDescriptionController,
                                          focusNode: _seoDescriptionNode,
                                          textInputAction: TextInputAction.next,
                                          textInputType: TextInputType.multiline,
                                          maxLine: 3,
                                          hintText: getTranslated('meta_description_hint', context),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                        const MetaSeoWidget(),
                                        const SizedBox(height: Dimensions.paddingSizeSmall),
                                      ],
                                    );
                                  }
                                ),


                              ],),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraLarge),


                            AddProductSectionWidget(
                                title: getTranslated('product_video_image', context)!,
                                childrens: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeSmall),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(
                                        children: [
                                          Image.asset(Images.alertCircle, width: Dimensions.paddingSizeDefault),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),

                                          Text(getTranslated('provide_embedded_link', context)!,
                                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeMedium),

                                      CustomTextFieldWidget(
                                        border: true,
                                        maxLine: 1,
                                        textInputType: TextInputType.text,
                                        controller: _youtubeLinkController,
                                        focusNode: _youtubeLinkNode,
                                        textInputAction: TextInputAction.done,
                                        hintText: getTranslated('youtube_video_link', context)!,
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                      Text(getTranslated('upload_thumbnail', context)!,
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),

                                      Consumer<AddProductImageController>(
                                        builder: (context, addProductImageController, child){
                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha:0.10),
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                            ),
                                            child: Align(alignment: Alignment.center, child: Stack(children: [
                                              Padding(
                                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                  child: addProductImageController.selectedLogoFile != null ?  Image.file(File(addProductImageController.selectedLogoFile!.path),
                                                    width: 150, height: 160, fit: BoxFit.cover,
                                                  ) : widget.product != null ? FadeInImage.assetNetwork(
                                                    placeholder: Images.placeholderImage,
                                                    image: _product!.thumbnailFullUrl?.path ?? '',
                                                    height: 160, width: 150, fit: BoxFit.cover,
                                                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderImage,
                                                        height: 160, width: 150, fit: BoxFit.cover, color: Theme.of(context).highlightColor),
                                                  ) : Image.asset(Images.placeholderImage, height: 160,
                                                    width: 150, fit: BoxFit.cover, color: Theme.of(context).highlightColor,),
                                                ),
                                              ),
                                              Positioned( bottom: 0, right: 0, top: 0, left: 0,
                                                child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  onTap: () => addProductImageController.pickImage(true,false, false, null, isAddProduct: widget.product == null),
                                                  child: DottedBorder(
                                                    options: RoundedRectDottedBorderOptions (
                                                      dashPattern: const [4,5],
                                                      color: Theme.of(context).hintColor,
                                                      radius: const Radius.circular(Dimensions.paddingEye),
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                      ),
                                                      child: (addProductImageController.selectedLogoFile == null && (_product!.thumbnailFullUrl?.path == null || _product!.thumbnailFullUrl?.path == '')) ?
                                                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                        Image.asset(Images.uploadImageIcon, width: 40,),

                                                        Text(getTranslated('upload_file', context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha: .7),))
                                                      ],) : const SizedBox.shrink(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ])),
                                          );
                                        }
                                      ),


                                      const SizedBox(height: Dimensions.paddingSizeDefault),

                                      Text(getTranslated('meta_image', context)!,
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Consumer<AddProductImageController>(
                                        builder: (context, addProductImageController, child){
                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor.withValues(alpha:0.10),
                                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                            ),
                                            child: Align(alignment: Alignment.center, child: Stack(children: [
                                              Padding(
                                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                  child: addProductImageController.selectedMetaImageFile != null ? Image.file(
                                                    File(addProductImageController.selectedMetaImageFile!.path), width: 150, height: 160, fit: BoxFit.cover,
                                                  ) : widget.product != null ? FadeInImage.assetNetwork(
                                                    placeholder: Images.placeholderImage,
                                                    image: _product!.metaSeoInfo != null ? _product!.metaSeoInfo?.imageFullUrl?.path ?? '' : _product!.metaImageFullUrl?.path ?? '',
                                                    height: 160, width: 150, fit: BoxFit.cover,
                                                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderImage, height: 160,
                                                        width: 150, fit: BoxFit.cover, color: Theme.of(context).highlightColor),
                                                  ) : Image.asset(Images.placeholderImage, height: 160,
                                                      width: 150, fit: BoxFit.cover, color: Theme.of(context).highlightColor,),

                                                ),
                                              ),
                                              Positioned( bottom: 0, right: 0, top: 0, left: 0,
                                                child: Consumer<AddProductImageController>(
                                                    builder: (context, addProductImageController, child){
                                                    return InkWell(
                                                      splashColor: Colors.transparent,
                                                      onTap: () => addProductImageController.pickImage(false,true, false, null),
                                                      child: DottedBorder(
                                                        options: RoundedRectDottedBorderOptions (
                                                          dashPattern: const [4,5],
                                                          color: Theme.of(context).hintColor,
                                                          radius: const Radius.circular(Dimensions.paddingEye),
                                                        ),
                                                        child: Container(
                                                          width: double.infinity,
                                                          decoration: BoxDecoration(
                                                            color: addProductImageController.selectedMetaImageFile != null ? Colors.black.withValues(alpha: 0.5) : null,
                                                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                          ),
                                                          child: (addProductImageController.selectedMetaImageFile == null && (_product!.metaSeoInfo?.imageFullUrl?.path == null || _product!.metaSeoInfo?.imageFullUrl?.path == '')) ?
                                                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                            Image.asset(Images.uploadImageIcon, width: 40,),

                                                            Text(getTranslated('upload_file', context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha: .7),),)
                                                          ],) : const SizedBox.shrink(),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                ),
                                              ),
                                            ])),
                                          );
                                        }
                                      ),

                                      const SizedBox(height: Dimensions.paddingSizeDefault),
                                      Text(getTranslated('additional_product_images', context)!,
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                      const SizedBox(height: Dimensions.paddingSizeDefault),

                                      if(variationController.attributeList![0].active && variationController.attributeList![0].variants.isNotEmpty)
                                        Consumer<AddProductImageController>(
                                          builder: (context, addProductImageController, child) {
                                            return GridView.builder(
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  childAspectRatio: 1,
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: addProductImageController.imagesWithColor.length,
                                                itemBuilder: (context, index){
                                                  String colorString = '0xff000000';
                                                  if(addProductImageController.imagesWithColor[index].color != null){
                                                    if(addProductImageController.imagesWithColor[index].color != null){
                                                      colorString = '0xff${addProductImageController.imagesWithColor[index].color!.substring(1, 7)}';
                                                    }
                                                  }

                                                  Brightness brightness = ThemeData.estimateBrightnessForColor(Color(int.parse(colorString)));


// Pick icon color based on brightness
                                                  Color iconColor = (brightness == Brightness.dark) ? Colors.white : Colors.black;

                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                                    child: (addProductImageController.imagesWithColor[index].color != null && addProductImageController.imagesWithColor[index].image == null) ?
                                                    GestureDetector(
                                                      onTap: () async {
                                                        addProductImageController.pickImage(false, false, false, index, update: _update);

                                                      },
                                                      child: Stack(children: [
                                                        DottedBorder(
                                                          options: RoundedRectDottedBorderOptions (
                                                            dashPattern: const [4,5],
                                                            color: Theme.of(context).hintColor,
                                                            radius: const Radius.circular(15),
                                                          ),
                                                          child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                                child: (_update) ? CustomImageWidget(image: addProductImageController.imagesWithColor[index].colorImage?.imageName?.path ?? "",
                                                                    width: MediaQuery.of(context).size.width/2.3,
                                                                    height: MediaQuery.of(context).size.width/2.3,
                                                                    fit: BoxFit.cover):
                                                                Image.asset(Images.placeholderImage, height: MediaQuery.of(context).size.width/2.3,
                                                                    width: MediaQuery.of(context).size.width/2.3, fit: BoxFit.cover),
                                                            ),
                                                        ),
                                                        Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                                          child: Align(alignment: Alignment.center,
                                                          child: Icon(Icons.camera_alt, color: Colors.black.withValues(alpha:.5), size: 40))
                                                        ),

                                                        Positioned(right: 5,top: 5,
                                                          child: Container(width: 30,height: 30,
                                                          decoration: BoxDecoration(color: Color(int.parse(colorString)),
                                                              borderRadius: BorderRadius.circular(20)),
                                                          child: Padding(padding: const EdgeInsets.all(8.0),
                                                              child: Image.asset(Images.edit, color: iconColor,))))
                                                      ],
                                                      ),
                                                    ) :

                                                    Stack(children: [
                                                      DottedBorder(
                                                          options: RoundedRectDottedBorderOptions (
                                                            dashPattern: const [4,5],
                                                            color: Theme.of(context).hintColor,
                                                            radius: const Radius.circular(15),
                                                          ),
                                                          child: Container(decoration: const BoxDecoration(color: Colors.white,
                                                            borderRadius: BorderRadius.all(Radius.circular(20)),),
                                                              child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                                                  child: Image.file(File(addProductImageController.imagesWithColor[index].image!.path),
                                                                      width: MediaQuery.of(context).size.width/2.3,
                                                                      height: MediaQuery.of(context).size.width/2.3,
                                                                      fit: BoxFit.cover)))),

                                                      Positioned(top:5,right:5,
                                                        child: InkWell(
                                                          splashColor: Colors.transparent,
                                                          onTap: (){
                                                            addProductImageController.pickImage(false, false, false, index);
                                                            // log("=update=>$_update");
                                                            // resProvider.removeImage(index, true);
                                                            // if(_update && resProvider.withColor[index].imageString != null &&  resProvider.withColor[index].imageString!.isNotEmpty){
                                                            //   resProvider.deleteProductImage(_product!.id.toString(), resProvider.withColorKeys[index].toString(), resProvider.withColor[index].color.toString().replaceAll("#",''));
                                                            // }
                                                          },
                                                          child: Container(width: 30,height: 30,
                                                            decoration: BoxDecoration(
                                                              color: Color(int.parse(colorString)),
                                                              borderRadius: BorderRadius.circular(20)),
                                                            child: Padding(padding: const EdgeInsets.all(8.0),
                                                              child: Image.asset(Images.edit, color: iconColor))))
                                                      ),

                                                    ],
                                                    ),
                                                  );
                                                });
                                          }
                                        ),


                                      if(_update)
                                        Consumer<AddProductImageController>(
                                          builder: (context, addProductImageController, _) {
                                            return GridView.builder(
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 1,
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10),
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: addProductImageController.imagesWithoutColor.length,
                                                itemBuilder: (BuildContext context, index){
                                                  return Stack(children: [
                                                    DottedBorder(
                                                      options: RoundedRectDottedBorderOptions (
                                                        dashPattern: const [4,5],
                                                        color: Theme.of(context).hintColor,
                                                        radius: const Radius.circular(15),
                                                      ),
                                                      child: Container(
                                                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                        child: ClipRRect(
                                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                                          child: CustomImageWidget(
                                                            image: addProductImageController.imagesWithoutColor[index],
                                                            width: MediaQuery.of(context).size.width/2.3,
                                                            height: MediaQuery.of(context).size.width/2.3,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    Positioned(top: 5, right : 5, child: InkWell(
                                                      splashColor: Colors.transparent,
                                                      onTap : () => addProductImageController.deleteProductImage(
                                                        '${_product?.id}',
                                                        _getFilenameFromFullImagePath(addProductImageController.imagesWithoutColor[index]),
                                                        null,
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [BoxShadow(
                                                            color: Theme.of(context).hintColor.withValues(alpha:.25),
                                                            blurRadius: 1,
                                                            spreadRadius: 1,
                                                            offset: const Offset(0,0),
                                                          )],
                                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault)),
                                                        ),
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(4.0),
                                                          child: Icon(Icons.delete_forever_rounded,color: Colors.red,size: 25,),
                                                        ),
                                                      ),
                                                    )),
                                                  ]);
                                                });
                                          }
                                        ),


                                      (_update && addProductImageController.imagesWithoutColor.isNotEmpty) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

                                      Consumer<AddProductImageController>(
                                        builder: (context, addProductImageController, child) {
                                          return GridView.builder(
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 1,
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                              ),
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: addProductImageController.withoutColor.length + 1,
                                              itemBuilder: (BuildContext context, index){
                                                return index == addProductImageController.withoutColor.length ?
                                                GestureDetector(
                                                  onTap: ()=> addProductImageController.pickImage(false, false, false, null),
                                                  child: Stack(children: [
                                                    DottedBorder(
                                                      options: RoundedRectDottedBorderOptions (
                                                        dashPattern: const [4,5],
                                                        color: Theme.of(context).hintColor,
                                                        radius: const Radius.circular(15),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                                        child:  Image.asset(Images.placeholderImage, height: MediaQuery.of(context).size.width/2.3,
                                                            width: MediaQuery.of(context).size.width/2.3, fit: BoxFit.cover, color: Theme.of(context).highlightColor,),
                                                      ),
                                                    ),
                                                    Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                          Image.asset(Images.uploadImageIcon, width: 40,),

                                                          Text(getTranslated('upload_file', context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha: .7)),)
                                                        ],),
                                                      ),
                                                    ),
                                                  ],
                                                  ),
                                                ) :
                                                Stack(children: [
                                                  DottedBorder(
                                                    options: RoundedRectDottedBorderOptions (
                                                      dashPattern: const [4,5],
                                                      color: Theme.of(context).hintColor,
                                                      radius: const Radius.circular(15),
                                                    ),
                                                    child: Container(
                                                      decoration: const BoxDecoration(color: Colors.white,
                                                        borderRadius: BorderRadius.all(Radius.circular(20)),),
                                                      child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                                        child: Image.file(File(addProductImageController.withoutColor[index].image!.path),
                                                          width: MediaQuery.of(context).size.width/2.3,
                                                          height: MediaQuery.of(context).size.width/2.3,
                                                          fit: BoxFit.cover,),) ,),
                                                  ),

                                                  Positioned(top: 5, right : 5,
                                                    child: InkWell(
                                                      splashColor: Colors.transparent,
                                                      onTap :() => addProductImageController.removeImage(index, false),
                                                      child: Container(decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withValues(alpha:.25), blurRadius: 1,spreadRadius: 1,offset: const Offset(0,0))],
                                                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))),
                                                          child: const Padding(
                                                            padding: EdgeInsets.all(4.0),
                                                            child: Icon(Icons.delete_forever_rounded,color: Colors.red,size: 25,),)),
                                                    ),
                                                  ),
                                                ],
                                                );
                                              });
                                        }
                                      ),


                                      const SizedBox(height: 25),
                                    ],),
                                  )
                                ],
                            )

                          ]) : const Padding(
                          padding: EdgeInsets.only(top: 300.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),

                    Consumer<AddProductController>(
                        builder: (context, resProvider, _) {
                          return Consumer<AiController>(
                            builder: (context, aiController, _) {
                              return Consumer<AddProductImageController>(
                                  builder: (context, addProductImageController, _) {
                                  return Container(height: 80,
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                                          spreadRadius: 0.5, blurRadius: 0.3)],
                                    ),
                                    child: aiController.addProductMetaScreenLoading ?
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
                                    ) :
                                    !resProvider.isLoading && !addProductImageController.isLoading ?
                                    Row(
                                      children: [
                                        Expanded(child: InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: (){
                                            Navigator.pop(context);
                                            resProvider.setSelectedPageIndex(1, isUpdate: true);
                                          },
                                          child: CustomButtonWidget(
                                            isColor: true,
                                            btnTxt: '${getTranslated('go_back', context)}',
                                            backgroundColor: Theme.of(context).hintColor.withValues(alpha: .6),
                                            buttonHeight: 55,
                                          ),
                                        )),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        Expanded(
                                          child: CustomButtonWidget(
                                            btnTxt: _update ? getTranslated('update',context) : getTranslated('submit', context), buttonHeight: 55,
                                            onTap: () async {
                                              final digitalProductController = Provider.of<DigitalProductController>(Get.context!,listen: false);
                                              final categoryController = Provider.of<CategoryController>(Get.context!,listen: false);

                                              resProvider.initUpload();
                                              String seoDescription = _seoDescriptionController.text.trim();
                                              String seoTitle = _seoTitleController.text.trim();
                                              String? unit = widget.unit;
                                              String? brandId = widget.brandyId;
                                              String metaTitle =_seoTitleController.text.trim();
                                              String metaDescription =_seoDescriptionController.text.trim();
                                              String videoUrl = _youtubeLinkController.text.trim();
                                              String multiPlyWithQuantity = resProvider.isMultiply?'1':'0';
                                              int multi = int.parse(multiPlyWithQuantity);
                                              String productCode = resProvider.productCode.text;
                                              bool isColorImageEmpty = false;
                                              bool isProductImageNull = false;


                                              List<String> titleList = [];
                                              List<String> descriptionList = [];
                                              for(TextEditingController textEditingController in resProvider.titleControllerList) {
                                                titleList.add(textEditingController.text.trim());
                                              }
                                              for (var description in resProvider.descriptionControllerList) {
                                                descriptionList.add(description.text.trim());}


                                              if(addProductImageController.imagesWithColor.isNotEmpty) {
                                                for (int i=0; i<addProductImageController.imagesWithColor.length; i++) {
                                                  if (!_update && addProductImageController.imagesWithColor[i].image == null && !isColorImageEmpty) {
                                                    isColorImageEmpty = true;
                                                  } else if (_update && addProductImageController.imagesWithColor[i].colorImage?.imageName == null && !isColorImageEmpty){
                                                    isColorImageEmpty = true;
                                                  }
                                                }
                                              }



                                              if(_update && (widget.product!.imagesFullUrl != null && widget.product!.imagesFullUrl!.isNotEmpty)) {
                                                for(ImageFullUrl image in widget.product!.imagesFullUrl!) {
                                                  if(image.path == null || image.path == '') {
                                                    isProductImageNull = true;
                                                    break;
                                                  }
                                                }
                                              }




                                              if ((!_update && addProductImageController.selectedLogoFile == null) || (_update && (addProductImageController.selectedLogoFile == null  && (widget.product?.thumbnailFullUrl?.path == null || widget.product?.thumbnailFullUrl?.path == ''))) ) {
                                                showCustomSnackBarWidget(getTranslated('upload_thumbnail_image',context),context, sanckBarType: SnackBarType.warning);
                                              } else if(!_update && variationController.attributeList![0].active && variationController.attributeList![0].variants.isNotEmpty && isColorImageEmpty) {
                                                showCustomSnackBarWidget(getTranslated('upload_product_color_image',context),context, sanckBarType: SnackBarType.warning);
                                              } else if (!_update && addProductImageController.imagesWithColor.length + addProductImageController.withoutColor.length == 0  || (_update && addProductImageController.imagesWithColor.length + addProductImageController.withoutColor.length == 0 && ((widget.product!.imagesFullUrl != null && widget.product!.imagesFullUrl!.isEmpty) || isProductImageNull))) {
                                                showCustomSnackBarWidget(getTranslated('upload_product_image',context),context, sanckBarType: SnackBarType.warning);
                                              }
                                              else {
                                                if(Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp != null && Provider.of<ShopController>(context, listen: false).shopModel?.setupGuideApp?['add_new_product'] != 1) {
                                                  Provider.of<ShopController>(context, listen: false).updateTutorialFlow('add_new_product');
                                                  Provider.of<ShopController>(context, listen: false).updateSetupGuideApp('add_new_product', 1);
                                                }
                                                _addProduct = AddProductModel();
                                                _addProduct!.titleList = titleList;
                                                _addProduct!.descriptionList = descriptionList;
                                                _addProduct!.videoUrl = videoUrl;
                                                _product!.taxIds = widget.tax;
                                                _product!.taxModel = resProvider.taxTypeIndex == 0 ? 'include' : 'exclude';
                                                _product!.unitPrice = PriceConverter.systemCurrencyToDefaultCurrency(double.parse(widget.unitPrice!), context);
                                                _product!.discount = resProvider.discountTypeIndex == 0 ?
                                                double.parse(widget.discount!) : PriceConverter.systemCurrencyToDefaultCurrency(double.parse(widget.discount!), context);
                                                _product!.productType = resProvider.productTypeIndex == 0 ? 'physical' : 'digital';
                                                _product!.unit = unit;
                                                _product!.code = productCode;
                                                _product!.shippingCost = PriceConverter.systemCurrencyToDefaultCurrency(double.parse(widget.shippingCost!), context);
                                                _product!.multiplyWithQuantity = multi;
                                                _product!.brandId = Provider.of<SplashController>(Get.context!, listen: false).configModel!.brandSetting == "1" && resProvider.productTypeIndex != 1 ? int.parse(brandId!) : null;
                                                _product!.metaTitle = metaTitle;
                                                _product!.metaDescription = metaDescription;
                                                _product!.currentStock = int.parse(widget.currentStock!);
                                                _product!.minimumOrderQty = int.parse(widget.minimumOrderQuantity!);
                                                _product!.metaTitle = seoTitle;
                                                _product!.metaDescription = seoDescription;
                                                _product!.discountType = resProvider.discountType;
                                                _product!.digitalProductType = Provider.of<DigitalProductController>(Get.context!,listen: false).digitalProductTypeIndex == 0 ? 'ready_after_sell' : 'ready_product';
                                                _product!.digitalFileReady = digitalProductController.digitalProductFileName;
                                                _product!.categoryIds = [];
                                                _product!.categoryIds!.add(CategoryIds(id: widget.categoryId));

                                                if (categoryController.subCategoryIndex != 0) {
                                                  _product!.categoryIds!.add(CategoryIds(
                                                      id: widget.subCategoryId));}

                                                if (categoryController.subSubCategoryIndex != 0) {
                                                  _product!.categoryIds!.add(CategoryIds(
                                                      id: widget.subSubCategoryId));}

                                                _addProduct!.colorCodeList =[];
                                                _addProduct!.colorCodeList!.addAll(variationController.colorCodeList);

                                                _addProduct!.languageList = [];
                                                if(Provider.of<SplashController>(context, listen:false).configModel!.languageList!=null &&
                                                    Provider.of<SplashController>(context, listen:false).configModel!.languageList!.isNotEmpty){
                                                  for(int i=0; i<Provider.of<SplashController>(context, listen:false).
                                                  configModel!.languageList!.length;i++){
                                                    _addProduct!.languageList!.insert(i, Provider.of<SplashController>(context, listen:false).configModel!.languageList![i].code) ;
                                                  }
                                                }


                                                if(_update){

                                                  for (ImageModel value in addProductImageController.imagesWithColor) {
                                                    ///if on online -> value.colorImage?.imageName?.path
                                                    ///if on offline -> value.image?.path
                                                    if(value.image?.path == null && value.colorImage?.imageName?.path == null) {
                                                      showCustomSnackBarWidget('${getTranslated('please_add_color_image', context)}', context);
                                                      return;
                                                    }
                                                  }


                                                  if(addProductImageController.selectedLogoFile != null){
                                                    await addProductImageController.addProductImage(context,addProductImageController.thumbnailImageModel, route, update: _update);

                                                  }

                                                  if(addProductImageController.selectedMetaImageFile != null){
                                                    await addProductImageController.addProductImage(Get.context!, addProductImageController.metaImageModel, route, update: _update);

                                                  }

                                                  if(context.mounted) {
                                                   await addProductImageController.onUploadColorImages(
                                                     context: context,
                                                     isUpdate: _update,
                                                     productId: _product?.id,
                                                     callBack: route,
                                                   );

                                                  }

                                                  if(addProductImageController.withoutColor.isNotEmpty) {
                                                    for(int i =0; i<addProductImageController.withoutColor.length; i++) {
                                                      if(addProductImageController.withoutColor[i].image != null){
                                                        await addProductImageController.addProductImage(Get.context!, addProductImageController.withoutColor[i], route, index: i, update: _update);
                                                      }
                                                    }
                                                  }
                                                }

                                                else{
                                                  if(addProductImageController.selectedLogoFile != null){
                                                    await addProductImageController.addProductImage(context, addProductImageController.thumbnailImageModel, route);
                                                  }

                                                  if(addProductImageController.selectedMetaImageFile != null) {
                                                   await addProductImageController.addProductImage(Get.context!, addProductImageController.metaImageModel,route);
                                                  }


                                                  if(addProductImageController.imagesWithColor.isNotEmpty) {
                                                    for(int i =0; i<addProductImageController.imagesWithColor.length; i++) {
                                                     await addProductImageController.addProductImage(Get.context!, addProductImageController.imagesWithColor[i], route);
                                                    }
                                                  }


                                                  if(addProductImageController.withoutColor.isNotEmpty){
                                                    for(int i =0; i<addProductImageController.withoutColor.length; i++) {
                                                     await addProductImageController.addProductImage(Get.context!, addProductImageController.withoutColor[i], route);
                                                    }
                                                  }

                                                }
                                              }

                                              if(_update) {
                                                Provider.of<AddProductController>(Get.context!,listen: false).addProduct(Get.context!, _product!, _addProduct!, thumbnailImage, metaImage, !_update, tagList);
                                              }





                                            }
                                          ),
                                        )
                                      ],
                                    )  :const Center(child: CircularProgressIndicator()),);
                                }
                              );
                            }
                          );
                        }
                    )
                  ],
                );
              },
            );
          }
        ),),


      ),
    );
  }

  String _getFilenameFromFullImagePath(String url) {
    final regex = RegExp(r'([^/]+)$'); // Matches everything after the last '/'
    final match = regex.firstMatch(url);
    return match?.group(1) ?? ''; // Returns the captured filename or empty string
  }
}

