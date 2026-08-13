import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class SearchSuggestion extends StatefulWidget{
  final int? id;
  const SearchSuggestion({super.key,  this.id});
  @override
  State<SearchSuggestion> createState() => _SearchSuggestionState();
}

class _SearchSuggestionState extends State<SearchSuggestion> with WidgetsBindingObserver {

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool _isKeyboardVisible = false;


  @override
  void initState() {
    super.initState();
    Future.delayed((const Duration(milliseconds: 500))).then((_) {
      // FocusScope.of(Get.context!).requestFocus(searchFocusNode);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;


    if (_isKeyboardVisible != isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardVisible;
      });

      if (isKeyboardVisible) {
      } else {
        searchFocusNode.unfocus();
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    return Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      child: Consumer<ClearanceSaleController>(
        builder: (context, clearanceController, _) {
          return SizedBox(height: 56,
            child: Padding(padding: const EdgeInsets.only(bottom: 8.0),
              child: Autocomplete<Product>(
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  searchController = controller;
                  searchFocusNode = focusNode;
                  return Material(child: TextFormField (
                    controller: searchController,
                    focusNode: searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) {
                      if(val.isNotEmpty) {
                      } else {
                        clearanceController.emptySearchListAddList();
                      }
                    },
                    onFieldSubmitted: (value) {
                      if(controller.text.trim().isNotEmpty) {

                      }else {
                        showCustomSnackBarWidget(getTranslated('enter_somethings', context), context);
                      }
                    },

                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            borderSide: BorderSide(color: Colors.grey[300]!)),
                       hintText: getTranslated('search_products', context),
                        hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                        suffixIcon: SizedBox(width: controller.text.isNotEmpty? 70 : 50,
                          child: Row(children: [
                            if(controller.text.isNotEmpty)
                              InkWell(onTap: (){
                                setState(() {
                                  controller.clear();
                                });
                              }, child: const Icon(Icons.clear, size: 20,)),


                            InkWell(onTap: (){
                              if(controller.text.trim().isNotEmpty) {
                                focusNode.unfocus();
                              } else{
                                showCustomSnackBarWidget(getTranslated('enter_somethings', context), context);
                              }
                            },
                              child: Padding(padding: const EdgeInsets.all(5),
                                child: Container(width: 40, height: 50,decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                                    borderRadius: const BorderRadius.all( Radius.circular(Dimensions.paddingSizeSmall))),
                                    child: SizedBox(width : 18,height: 18, child: Padding(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                      child: Image.asset(Images.search, color: Colors.white),
                                    ))),
                              ),
                            ),
                          ],
                          ),
                        )
                    ),
                  ),
                  );
                },

                optionsBuilder: (TextEditingValue textEditingValue) async {
                  // _debounce.run(() async {
                  // });

                  await clearanceController.getSearchProductList(
                      Provider.of<ProfileController>(context, listen: false).userId.toString(),
                      1, context, 'en', textEditingValue.text, reload: false
                  );

                  if (textEditingValue.text.isEmpty || clearanceController.sellerProductModel?.products == null) {
                    return const Iterable<Product>.empty();
                  } else {
                    Iterable<Product> matchingProducts = clearanceController.sellerProductModel!.products!.where(
                      (product) => (product.name!.toLowerCase().contains(textEditingValue.text.toLowerCase())  && (!clearanceController.selectedProductIds!.contains(product.id))
                    ));

                    return matchingProducts;
                  }
                },
                optionsViewOpenDirection: OptionsViewOpenDirection.down,

                optionsViewBuilder: (context, Function(Product) onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(elevation: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width, 
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height *0.7,
                          ),
                          child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final product = options.elementAt(index);
                                return InkWell(
                                  onTap: () {
                                    searchFocusNode.unfocus();
                                    searchController.clear();
                                    clearanceController.setSelectedProduct(product, index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                                    child: Container(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(color: Theme.of(context).canvasColor,
                                        borderRadius: BorderRadius.only(
                                          topRight: index == 0 ? const Radius.circular(Dimensions.radiusDefault) : Radius.zero,
                                          topLeft: index == 0 ? const Radius.circular(Dimensions.radiusDefault) : Radius.zero,
                                          bottomLeft: options.length -1 == index ? const Radius.circular(Dimensions.radiusDefault) : Radius.zero,
                                          bottomRight: options.length -1 == index ? const Radius.circular(Dimensions.radiusDefault) : Radius.zero,
                                          // Dimensions.radiusDefault
                                        ),
                                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.15), width: .75)
                                      ),
                    
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50, width: 50,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.05), width: .75)
                                            ),
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                child: CustomImageWidget(
                                                    image: product.thumbnailFullUrl?.path ?? '')),
                                          ),
                                          const SizedBox(width: Dimensions.paddingSizeSmall),
                    
                    
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(product.name ?? '',
                                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    
                                                Row(
                                                  children: [
                                                    Text(PriceConverter.convertPrice(context,
                                                      product.unitPrice,
                                                      discount: product.discount,
                                                      discountType: product.discountType
                                                    ),
                                                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    
                                                    product.discount! > 0 ?
                                                    Text(PriceConverter.convertPrice(context, product.unitPrice),
                                                        maxLines: 1,overflow: TextOverflow.ellipsis,
                                                        style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error,
                                                          decoration: TextDecoration.lineThrough,
                                                          fontSize: Dimensions.fontSizeSmall,
                                                        )): const SizedBox.shrink(),
                                                  ],
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    
                                                Wrap(
                                                  children: [
                                                    Text('${getTranslated('category', context)!} : ',
                                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                                    ),
                    
                                                    Text(product.category?.name ?? '',
                                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                                    ),

                    
                                                    if(product.productType == 'physical')
                                                      ...[
                                                        Text(' | ',
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                                        ),

                                                        Text('${getTranslated('brand', context)!} : ',
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                                        ),
                    
                                                        Text(product.brand?.name ?? '',
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                                        ),
                    
                                                        Text(' | ',
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                                        ),

                                                        Text('${getTranslated('stock', context)!} : ',
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor), maxLines: 2,
                                                        ),

                                                        Text(product.currentStock.toString(),
                                                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                                                        ),
                                                      ],

                                                  ],
                                                ),
                                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                              ],
                                            ),
                                          ),
                    
                                        ],
                                      )
                    
                                    ),
                                  ),
                                );
                              },
                    
                            separatorBuilder: (context, index) => const SizedBox(),
                            itemCount: options.length),
                        )
                    ),
                  );
                },


                onSelected: (selectedString) {
                  if (kDebugMode) {
                    print(selectedString);
                  }
                },

              ),
            ),
          );
        }
      ),
    );
  }
}