import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/hold_order_item_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class HoldOrderSearchBarWidget extends StatefulWidget {
  const HoldOrderSearchBarWidget({super.key});

  @override
  State<HoldOrderSearchBarWidget> createState() => _HoldOrderSearchBarWidgetState();
}

class _HoldOrderSearchBarWidgetState extends State<HoldOrderSearchBarWidget> {

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed((const Duration(milliseconds: 500))).then((_) {
      FocusScope.of(Get.context!).requestFocus(searchFocusNode);
    });
  }


  @override
  Widget build(BuildContext context) {
    return  Consumer<CartController>(
      builder: (context, clearanceController, _) {
        return SizedBox(height: 56,
          child: Padding(padding: const EdgeInsets.only(bottom: 8.0),
            child: Autocomplete<TemporaryCartListModel>(
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                searchController = controller;
                searchFocusNode = focusNode;


                return Material(child:

                Container(
                  //  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).hintColor),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                  ),
                  child: Row(
                    children: [
                      const Padding(
                          padding: EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                          child: Icon(Icons.search, size: 20)
                      ),

                      Expanded(
                        child: CustomTextFieldWidget(
                          border: false,
                          focusBorder: false,
                          hintText: getTranslated('search_by_customer_name', context)!,
                          controller: searchController,
                          focusNode: searchFocusNode,
                          textInputAction: TextInputAction.search,
                          onChanged: (val) {
                            if(val.isNotEmpty) {
                            } else {
                              // clearanceController.emptySearchListAddList();
                            }
                            },
                          ),
                        )
                      ],
                    ),
                  )
                );
              },

              optionsBuilder: (TextEditingValue textEditingValue) async {

                if (textEditingValue.text.isEmpty) {
                  return const Iterable<TemporaryCartListModel>.empty();
                } else {
                  List<TemporaryCartListModel> cartList = clearanceController.customerCartList;

                  Iterable<TemporaryCartListModel> matchingProducts = cartList.where(
                     (product) => product.customerName!.toLowerCase().contains(textEditingValue.text.toLowerCase())
                  );

                  return matchingProducts;
                }
              },
              optionsViewOpenDirection: OptionsViewOpenDirection.down,

              optionsViewBuilder: (context, Function(TemporaryCartListModel) onSelected, options) {
                return Material(elevation: 0,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final cart = options.elementAt(index);

                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                        child: HoldOrderItemWidget(customerCard: cart, index: clearanceController.getCartIndexByUserId(cart.userId!), formSearch: true)
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(),
                    itemCount: options.length)
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
    );
  }
}





// Container(
//   //  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//   decoration: BoxDecoration(
//       border: Border.all(color: Theme.of(context).hintColor),
//       borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
//   ),
//   child: Row(
//     children: [
//       const Padding(
//           padding: EdgeInsets.only(left: Dimensions.paddingSizeSmall),
//           child: const Icon(Icons.search, size: 20)
//       ),
//
//       Expanded(
//         child: CustomTextFieldWidget(
//           border: false,
//           focusBorder: false,
//           hintText: getTranslated('search_products', context)!,
//           controller: TextEditingController(),
//           onChanged: (text){
//
//           },
//         ),
//       )
//     ],
//   ),
// );


