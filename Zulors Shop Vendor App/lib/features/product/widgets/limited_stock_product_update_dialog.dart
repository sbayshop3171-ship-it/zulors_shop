import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';


class LimitedStockQuantityUpdateDialogWidget extends StatefulWidget {
  final String? title;
  final Function onYesPressed;
  final TextEditingController? note;
  final TextEditingController? stockQuantityController;
  final Product? product;
  const LimitedStockQuantityUpdateDialogWidget({super.key, this.title, required this.onYesPressed, this.note, this.product, this.stockQuantityController});

  @override
  State<LimitedStockQuantityUpdateDialogWidget> createState() => _LimitedStockQuantityUpdateDialogWidgetState();
}

class _LimitedStockQuantityUpdateDialogWidgetState extends State<LimitedStockQuantityUpdateDialogWidget> {
  int addColor = 0;

  void _load(){
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US'?
    'en':Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    Provider.of<SplashController>(context,listen: false).getColorList();
    Provider.of<VariationController>(context,listen: false).getAttributeList(context, widget.product, languageCode);
  }

  @override
  void initState() {
    _load();
    Provider.of<RestockController>(context,listen: false).setCurrentStock(widget.product!.currentStock.toString());
    Provider.of<RestockController>(context,listen: false).initVariationController(widget.product!.variation ?? []);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Consumer<RestockController>(
            builder: (context, resProvider, child) {
              List<int> colors = [];
              colors.add(0);


              // if (Provider.of<AddProductController>(context, listen: false).attributeList != null &&
              //     Provider.of<AddProductController>(context, listen: false).attributeList!.isNotEmpty) {
              //   if(addColor==0) {
              //     addColor++;
              //     if ( widget.product!.colors != null && widget.product!.colors!.isNotEmpty) {
              //       Future.delayed(Duration.zero, () async {
              //         Provider.of<AddProductController>(context, listen: false).setAttribute();
              //       });
              //     }
              //     for (int index = 0; index < widget.product!.colors!.length; index++) {
              //       colors.add(index);
              //       Future.delayed(Duration.zero, () async {
              //         resProvider.addVariant(context,0, widget.product!.colors![index].name, widget.product, false);
              //         resProvider.addColorCode(widget.product!.colors![index].code, index: index);
              //       });
              //     }
              //   }
              // }

              widget.stockQuantityController!.text = resProvider.totalQuantityController.text;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [


                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                child: Text(
                                  widget.title!, textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                                ),
                              ),


                              // resProvider.attributeList != null?
                              // AttributeViewWidget(product: widget.product, colorOn: resProvider.attributeList![0].active, onlyQuantity: true):const CircularProgressIndicator(),

                              widget.product?.variation != null ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),


                              widget.product?.variation != null?
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget.product?.variation?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [

                                          Expanded(flex: 8, child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(text: widget.product?.variation![index].type ?? '', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                                                ],
                                              ),
                                            ),
                                          ])),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),


                                          Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            CustomTextFieldWidget(
                                              variant: true,
                                              border: true,
                                              hintText: 'Ex: 345',

                                              controller: resProvider.variationQuantityController[index],
                                              focusNode: resProvider.variationQuantityFocusnode[index],
                                              nextNode: index != widget.product!.variation!.length - 1 ? resProvider.variationQuantityFocusnode[index+1] : null,
                                              textInputAction: index != widget.product!.variation!.length - 1 ? TextInputAction.next : TextInputAction.done,
                                              isAmount: false,
                                              amountIcon: false,
                                              textInputType: TextInputType.number,
                                              isFullNumber : true,
                                              onChanged: (String cng){
                                                resProvider.calculateVariationQuantity();
                                              },
                                            ),
                                          ],
                                          )),

                                        ]),
                                  );
                                },
                              ):const SizedBox(),


                              Container(margin: const EdgeInsets.only(left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge,
                                  bottom: Dimensions.paddingSizeSmall),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(getTranslated('total_quantity', context)!,
                                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                    CustomTextFieldWidget(
                                      idDate: widget.product!.variation!.isNotEmpty,
                                      border: true,
                                      textInputType: TextInputType.number,
                                      controller: widget.stockQuantityController,
                                      textInputAction: TextInputAction.next,
                                      isAmount: true,
                                      hintText: 'Ex: 500',
                                    ),
                                  ],)),


                              const SizedBox(height: Dimensions.paddingSizeDefault),
                              Consumer<RestockController>(builder: (context, shippingProvider, child) {
                                return !shippingProvider.isLoading ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: SizedBox(height: 40,
                                    child: CustomButtonWidget(
                                      borderRadius: 10,
                                      btnTxt: getTranslated('update_quantity',context),
                                      onTap: () =>  widget.onYesPressed(),
                                    ),
                                  ),
                                ) : const Center(child: CircularProgressIndicator());
                              }),
                            ]),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                child: SizedBox(width: 18,child: Image.asset(Images.cross)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
        ));
  }
}