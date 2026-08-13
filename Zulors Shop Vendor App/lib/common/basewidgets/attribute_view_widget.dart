import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';



class AttributeViewWidget extends StatefulWidget {
  final Product? product;
  final bool colorOn;
  final bool onlyQuantity;
  const AttributeViewWidget({super.key, required this.product, required this.colorOn, this.onlyQuantity = false});
  @override
  State<AttributeViewWidget> createState() => _AttributeViewWidgetState();
}

class _AttributeViewWidgetState extends State<AttributeViewWidget> {
  bool? colorONOFF;
  int addVar = 0;

  void _load(){
    Provider.of<VariationController>(context,listen: false).selectedColor;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }


  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Provider.of<ThemeController>(context, listen: false).darkTheme;

    colorONOFF = widget.colorOn;
    return Consumer<VariationController>(
      builder: (context, variationController, child){
        return Consumer<AddProductController>(
          builder: (context, resProvider, child){

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: Dimensions.paddingSizeSmall,),

              widget.onlyQuantity ? const SizedBox() :
              Text(getTranslated('other_attributes', context)!,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              widget.onlyQuantity ? const SizedBox():
              SizedBox(height: 50,
                child: variationController.attributeList!.isNotEmpty ?
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: variationController.attributeList!.length,
                  itemBuilder: (context, index) {
                    if(index == 0 && widget.colorOn){
                      return const SizedBox();
                    }
                    return InkWell(
                      onTap: () => variationController.toggleAttribute(context,index, widget.product),
                      child: Container( width: 100, alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: variationController.attributeList![index].active ?
                          Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha:.10),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Text(
                          variationController.attributeList![index].attribute.name!,
                          maxLines: 2, textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: variationController.attributeList![index].active ?
                            isDarkTheme ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).cardColor
                            : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    );
                  },
                ):const SizedBox(),
              ),
              SizedBox(height: variationController.attributeList!.where((element) => element.active).isNotEmpty ?
              Dimensions.paddingSizeLarge : 0),

              widget.onlyQuantity?const SizedBox():
              variationController.attributeList!.isNotEmpty?
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: variationController.attributeList!.length,
                itemBuilder: (context, index) {

                  return (variationController.attributeList![index].active && index != 0) ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        variationController.attributeList![index].attribute.name!, maxLines: 2, textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(children: [
                        Expanded(child: CustomTextFieldWidget(
                          border: true,
                          controller: variationController.attributeList![index].controller,
                          textInputAction: TextInputAction.done,
                          capitalization: TextCapitalization.words,
                          // title: false,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        SizedBox(height: 50, width : 80,
                          child: CustomButtonWidget(
                            onTap: () {
                              String variant = variationController.attributeList![index].controller.text.trim();
                              if(variant.isEmpty) {
                                showCustomSnackBarWidget(getTranslated('enter_a_variant_name', context),context);
                              }else {
                                variationController.attributeList![index].controller.text = '';
                                variationController.addVariant(context,index, variant, widget.product, true);
                              }
                            },
                            btnTxt: 'Add',
                          ),
                        ),
                      ]),
                    ]),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      height: 40,
                      child: variationController.attributeList![index].variants.isNotEmpty? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        itemCount: variationController.attributeList![index].variants.length,
                        itemBuilder: (context, i) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [
                              Text(variationController.attributeList![index].variants[i]!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              const SizedBox(width: Dimensions.paddingSizeSmall,),

                              InkWell(
                                splashColor: Colors.transparent,
                                onTap: () => variationController.removeVariant(context,index, i, widget.product),
                                child: const Icon(Icons.close, size: 15),
                              ),
                            ]),
                          );
                        },
                      ) : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          getTranslated('no_variant_added_yet', context)!,
                          style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error.withValues(alpha:.8)),
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                  ]) : const SizedBox();
                },
              ) : const SizedBox(),

              widget.onlyQuantity ? const SizedBox():
              const SizedBox(height: Dimensions.paddingSizeLarge),
              variationController.variantTypeList.isNotEmpty ?
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      flex: 4,
                      child: Text(getTranslated('variant',context)!,
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).disabledColor),
                      ),
                    ),
                    widget.onlyQuantity?const SizedBox():

                    Expanded(
                      flex: 4,
                      child: Text(getTranslated('price',context)!,
                          style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).disabledColor)),
                    ),

                    Expanded(
                      flex: widget.onlyQuantity ? 3 : 4,
                      child: Text(getTranslated('quantity',context)!,
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).disabledColor),),
                    ),
                  ],):const SizedBox.shrink(),
              SizedBox(height:    variationController.variantTypeList.isNotEmpty? Dimensions.paddingSizeDefault : 0),

              variationController.variantTypeList.isNotEmpty?
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: variationController.variantTypeList.length,
                itemBuilder: (context, index) {

                  return Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(
                          variationController.variantTypeList[index].variantType,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)), maxLines: 2,
                        ),
                      ])),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                          widget.onlyQuantity?const SizedBox():
                      Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        CustomTextFieldWidget(
                          variant: true,
                          border: true,
                          hintText: 'Ex: \$234',
                          controller: variationController.variantTypeList[index].controller,
                          focusNode: variationController.variantTypeList[index].node,
                          nextNode: index != variationController.variantTypeList.length-1 ? variationController.variantTypeList[index+1].node : null,
                          textInputAction: index != variationController.variantTypeList.length-1 ? TextInputAction.next : TextInputAction.done,
                          isAmount: true,
                          textInputType: TextInputType.number,
                          amountIcon: true,
                          ),
                        ],
                      )),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          CustomTextFieldWidget(
                            variant: true,
                            border: true,
                            hintText: 'Ex: 345',
                            controller: variationController.variantTypeList[index].qtyController,
                            focusNode: variationController.variantTypeList[index].qtyNode,
                            nextNode: index != variationController.variantTypeList.length-1 ? variationController.variantTypeList[index+1].node : null,
                            textInputAction: index != variationController.variantTypeList.length-1 ? TextInputAction.next : TextInputAction.done,
                            isAmount: true,
                            amountIcon: false,
                            textInputType: TextInputType.number,
                            onChanged: (String cng){
                              variationController.calculateVariationQuantity();
                            },
                          ),
                        ],
                      )),

                    ]),
                  );
                },
              ):const SizedBox(),
              SizedBox(height: variationController.hasAttribute() ? Dimensions.paddingSizeExtraSmall : 0),
            ]);
          },
        );
      }
    );
  }
}
