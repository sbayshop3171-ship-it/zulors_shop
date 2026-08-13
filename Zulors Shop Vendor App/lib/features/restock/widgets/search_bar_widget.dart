import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/features/restock/widgets/product_filter_dialog_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';

class SearchBarWidget extends StatefulWidget {
  final bool showFilter;
  final bool showBack;
  final TextEditingController controller;
  const SearchBarWidget({super.key, this.showFilter = true, this.showBack = false, required this.controller});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
        child: Consumer<RestockController>(
            builder: (context, restockController, child) {
            return Row(crossAxisAlignment: CrossAxisAlignment.start,  mainAxisAlignment: MainAxisAlignment.center, children: [

              if(widget.showBack) Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Center(child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_sharp),
                )),
                const SizedBox(width: Dimensions.paddingSizeDefault),
              ]),

              Expanded(flex: 7, child: Container(
               // padding: const  EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  border: Border.all(color: Theme.of(context).hintColor),
                ),
                child: Stack(children: [

                  Padding(
                    padding: const  EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                    child: CustomTextFieldWidget(
                      border: false,
                      focusBorder: false,
                      hintText: getTranslated('search_products', context)!,
                      controller: widget.controller,
                      onChanged: (text){
                        restockController.setSearchText(text);
                      },
                    ),
                  ),

                  Positioned.fill(
                    child: Consumer<RestockController>(
                      builder: (context, restockController, child) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              if(widget.controller.text.isEmpty) {
                                showCustomSnackBarWidget(getTranslated('type_something_to_search_for_products', context), context, sanckBarType: SnackBarType.warning);
                              } else if(restockController.isSearching) {
                                restockController.setSearching(false);
                                widget.controller.text = '';
                                restockController.setSearchText('');
                                Provider.of<RestockController>(context, listen: false).getRestockProductList(1);
                              } else {
                                restockController.setSearching(true);
                                Provider.of<RestockController>(context, listen: false).getRestockProductList(1);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.showFilter ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                              ),
                              child: Icon(!restockController.isSearching ? Icons.search : Icons.close, color: Theme.of(context).textTheme.bodySmall?.color, size: 15)
                            ),
                          ),
                        );
                      }
                    ),
                  ),

                ]),
              )),


              if(widget.showFilter) ...[
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(flex: 1, child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).hintColor),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(context: context,
                        isScrollControlled: true, backgroundColor: Colors.transparent,
                        builder: (c) =>  const ProductFilterDialog(fromShop: false)
                      );
                    },
                    child: Image.asset(Images.dropdown, color: Theme.of(context).textTheme.bodyLarge?.color)
                  )
                ))
              ],


            ]);
          }
        ),
      ),
    );
  }
}
