import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/domain/models/chearance_slale_add_model.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_add_list_item.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_search_suggestion_widget.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ClearanceSearchProductScreen extends StatefulWidget {
  const ClearanceSearchProductScreen({super.key});

  @override
  State<ClearanceSearchProductScreen> createState() => _ClearanceSearchProductScreenState();
}

class _ClearanceSearchProductScreenState extends State<ClearanceSearchProductScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController skuController = TextEditingController();
  int? userId;

  @override
  void initState() {
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.maxFinite, 50),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0):
            Theme.of(context).primaryColor.withValues(alpha:.10),
              offset: const Offset(0, 2.0), blurRadius: 4.0,
            )
          ]),
          child: AppBar(
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(getTranslated('clearance_sale', context)!,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),
                Text(getTranslated('product_list', context)!,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2,
                ),
              ],
            ),
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: Dimensions.iconSizeDefault),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () => Navigator.pop(context)
            ),
          ),
        ),
      ),

      body: Consumer<ClearanceSaleController>(
          builder: (context, clearanceSaleController, child) {
          return Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
          
              Expanded(
                child: SingleChildScrollView(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SearchSuggestion(),

                    ListView.builder(
                      itemCount: clearanceSaleController.selectedProductModel?.length,
                      padding: const EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return ClearanceAddListItem(
                          product: clearanceSaleController.selectedProductModel![index],
                          index: index,
                          skuController: TextEditingController(),
                          onDiscountTypeChanged: (String value) {},
                        );
                      },
                    ),
                  ]),
                )
              ),


              Opacity(
                opacity: clearanceSaleController.selectedProductModel!.isEmpty ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: clearanceSaleController.selectedProductModel!.isEmpty,
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(color: Colors.grey[200]!, spreadRadius: 0.5, blurRadius: 0.3)
                      ],
                    ),
                    height: 80,child: Row(children: [
                      Expanded(child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          clearanceSaleController.clearSelectedProducts();
                        },
                        child: CustomButtonWidget(
                          isColor: true,
                          btnTxt: '${getTranslated('cancel', context)}',
                          backgroundColor: Theme.of(context).cardColor,
                          fontColor: Theme.of(context).colorScheme.error,
                          borderColor: Theme.of(context).colorScheme.error,
                        ),
                      )),
                     const SizedBox(width: Dimensions.paddingSizeSmall),

                     Expanded(
                       child: clearanceSaleController.isLoading ?
                       const Center(
                         child: SizedBox(
                           height:  30, width: 30,
                           child: CircularProgressIndicator(),
                         ),
                       ) : CustomButtonWidget(
                        btnTxt:  getTranslated('add_products', context),
                        onTap: () {
                          bool isWrongAmount = false;

                          for(ClearanceSaleAddModel product in clearanceSaleController.clearanceSaleAddModel){
                            if(product.isWrongAmount == true) {
                              isWrongAmount = true;
                              break;
                            }
                          }

                          if(clearanceSaleController.clearanceConfigModel?.discountType ==  'product_wise' && isWrongAmount) {
                            showCustomSnackBarWidget(getTranslated('some_product_contains_wrong_amount', context), context, isError: false, sanckBarType: SnackBarType.warning);
                          } else {
                            clearanceSaleController.clearanceSaleProductAdd();
                          }

                        },
                      )
                     ),
                  ])
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
