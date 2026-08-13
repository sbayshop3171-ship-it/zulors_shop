import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/variation_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';


class QuantityUpdateDialogWidget extends StatefulWidget {
  final String? title;
  final Function onYesPressed;
  final TextEditingController? note;
  final TextEditingController? stockQuantityController;
  final Product? product;
  const QuantityUpdateDialogWidget({super.key, this.title, required this.onYesPressed, this.note, this.product, this.stockQuantityController});

  @override
  State<QuantityUpdateDialogWidget> createState() => _QuantityUpdateDialogWidgetState();
}

class _QuantityUpdateDialogWidgetState extends State<QuantityUpdateDialogWidget> {


  int addColor = 0;

  void _load(){
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US'?
    'en':Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    // Provider.of<SplashController>(context,listen: false).getColorList();
    Provider.of<VariationController>(context,listen: false).getAttributeList(context, widget.product, languageCode);
  }

  @override
  void initState() {
    _load();
    Provider.of<VariationController>(context,listen: false).setCurrentStock(widget.product!.currentStock.toString());
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Consumer<AddProductController>(
            builder: (context, resProvider, child) {
              widget.stockQuantityController!.text =  widget.product?.currentStock.toString() ?? '0';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeVeryTiny),
                  child: Column(mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.10),width: 0.5)),
                                    child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                        child: CustomImageWidget(image: widget.product?.thumbnailFullUrl?.path ?? '', height: 84, width: 84))
                                ),

                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(children: [
                                      Flexible(
                                        child: Text(widget.product?.name ?? '', maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    // Price
                                    Row(
                                      children: [
                                        Text(PriceConverter.convertPrice(context,
                                          widget.product?.unitPrice, discountType: widget.product?.discountType,
                                          discount: widget.product?.discount),
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
                                        ),
                                      ],
                                    ),
                                  ],
                                  ),
                                ),
                              ]),
                              const SizedBox(height: Dimensions.paddingSizeSmall),


                              Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).hintColor.withValues(alpha:0.25),
                                ),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(getTranslated('main_stock', context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color : Theme.of(context).textTheme.bodyLarge?.color)),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                    CustomTextFieldWidget(
                                      border: true,
                                      textInputType: TextInputType.number,
                                      controller: widget.stockQuantityController,
                                      textInputAction: TextInputAction.next,
                                      isAmount: true,
                                      hintText: 'Ex: 500',
                                    ),
                                  ],)),
                              const SizedBox(height: Dimensions.paddingSizeDefault),


                                Consumer<AddProductController>(builder: (context, shippingProvider, child){
                                  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    SizedBox(height: 30, width: 80,
                                      child: CustomButtonWidget(
                                        backgroundColor: shippingProvider.isLoading ? Theme.of(context).hintColor.withValues(alpha:0.25) :
                                        Theme.of(context).colorScheme.error.withValues(alpha:0.25),
                                        fontColor: Theme.of(context).colorScheme.error,
                                        borderRadius: Dimensions.radiusSmall,
                                        btnTxt: getTranslated('cancel', context),
                                        onTap: () => shippingProvider.isLoading ? null : Navigator.pop(context),
                                      ),
                                    ),

                                     !shippingProvider.isLoading ? Padding(
                                        padding: const EdgeInsets.only(left : Dimensions.paddingSizeSmall),
                                        child: SizedBox(height: 30, width: 80,
                                          child: CustomButtonWidget(
                                            borderRadius: Dimensions.radiusSmall,
                                            btnTxt: getTranslated('update', context),
                                            onTap: ()  {
                                              // if(widget.stockQuantityController!.text.isEmpty) {
                                              //   showCustomSnackBarWidget(getTranslated('enter_stock_quantity', context), context, sanckBarType: SnackBarType.warning);
                                              // } else if (int.parse(widget.stockQuantityController!.text) != 0 ) {
                                              //   showCustomSnackBarWidget(getTranslated('quantity_should_grater_then_zero', context), context, sanckBarType: SnackBarType.warning);
                                              // } else {
                                                widget.onYesPressed();
                                              // }
                                            },
                                          ),
                                        ),
                                      ) : const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                        child: Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()))
                                      ),
                                  ]);
                                }
                              )
                            ]),
                          ),

                          Positioned(
                            top: 10, right: 10,
                            child: SizedBox(
                              height: 15, width: 15,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, size: 15)
                              ),
                            )
                          )
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