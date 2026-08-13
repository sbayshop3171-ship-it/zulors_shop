import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_loader_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/controllers/clearance_sale_controller.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/screens/clearance_search_product_screen.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_offer_setup_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_product_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/clearance_sale_section_widget.dart';
import 'package:zulors_shop_vendor/features/clearance_sale/widgets/delete_confiramation_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/order/screens/order_screen.dart';
import 'package:zulors_shop_vendor/helper/debounce_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class ClearanceSaleScreen extends StatefulWidget {
  const ClearanceSaleScreen({super.key});

  @override
  State<ClearanceSaleScreen> createState() => _ClearanceSaleScreenState();
}

class _ClearanceSaleScreenState extends State<ClearanceSaleScreen> {

  ScrollController scrollController = ScrollController();
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);


  @override
  void initState() {
    Provider.of<ClearanceSaleController>(context, listen: false).getClearanceConfigData();
    Provider.of<ClearanceSaleController>(context, listen: false).getClearanceSaleProductList(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('clearance_sale', context),
        isRemoveShadow: true,
      ),

      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 0),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add,color: Theme.of(context).cardColor),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_)=> const ClearanceSearchProductScreen()));
          },
        ),
      ),

      body: Consumer<ClearanceSaleController>(
        builder: (context, clearanceController, child) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClearanceSaleSectionWidget(
              title: getTranslated('active_clearance_sale_offer', context)!,
              childrens: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeSmall),
                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:0.50))
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(getTranslated('show_your_offer_in_the_store_details', context)!,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)
                        )
                      ),


                      FlutterSwitch(width: 40.0, height: 20.0, toggleSize: 18.0,
                        value: clearanceController.clearanceConfigModel?.isActive == 1,
                        borderRadius: 20.0,
                        activeColor: Theme.of(context).primaryColor,
                        padding: 1.0,
                        onToggle:(bool isActive) async {
                          if(isActive && clearanceController.clearanceConfigModel?.id == null) {
                            showCustomSnackBarWidget(getTranslated('please_setup_the_configuration_first',context),context,  sanckBarType: SnackBarType.warning);
                          } else {
                            _debounce.run(
                                  () async {
                                showDialog(context: context, builder: (ctx)  => const CustomLoaderWidget());
                                await clearanceController.updateConfigStatus(isActive ? 1: 0);

                                if(context.mounted) {
                                  Navigator.of(context).pop();
                                }

                              },
                            );
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),

            Expanded(child: SingleChildScrollView(
              child: IgnorePointer(
                ignoring: false,
                child: Opacity(
                  opacity: 1,
                  child: Column(children: [
                    const ClearanceOfferSetupWidget(),
                
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(getTranslated('product_list', context)!,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault), maxLines: 2,
                              ),

                              if (clearanceController.clearanceSaleProductModel != null &&
                              clearanceController.clearanceSaleProductModel!.products!.isNotEmpty
                              && clearanceController.clearanceSaleProductModel?.totalSize != 0)...[
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  child: Text(clearanceController.clearanceSaleProductModel?.totalSize.toString() ?? '', style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                                )
                              ]
                            ],
                          ),




                
                          (clearanceController.clearanceSaleProductModel != null && clearanceController.clearanceSaleProductModel!.products!.isNotEmpty) ?
                          InkWell(
                            onTap: () {
                              showDialog(context: context, builder: (_)=> const DeleteConfirmationDialogWidget(null, null));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  color: Theme.of(context).colorScheme.error.withValues(alpha:0.05),
                                  border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha:0.15), width: 1)
                              ),
                              child: Text( getTranslated('clear_all', context)!,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ) : const SizedBox(),
                        ],
                      ),
                    ),
                
                    clearanceController.clearanceSaleProductModel != null ?
                    clearanceController.clearanceSaleProductModel!.products!.isNotEmpty ?
                    PaginatedListViewWidget(
                      reverse: false,
                      scrollController: scrollController,
                      totalSize: clearanceController.clearanceSaleProductModel?.totalSize ?? 0,
                      offset: clearanceController.clearanceSaleProductModel?.offset,
                      onPaginate: (int? offset) async {
                        clearanceController.getClearanceSaleProductList(offset!);
                        if (kDebugMode) {
                          print('========offset======>$offset');
                        }
                      },
                      itemView: ListView.builder(
                        itemCount: clearanceController.clearanceSaleProductModel?.products?.length ?? 0,
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return ClearanceProductWidget(products: clearanceController.clearanceSaleProductModel!.products![index], index: index);
                        },
                      ),
                    ) : Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                      height: 200, width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(height: 45, width: 45,Images.noProductImage),
                
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                
                          Text(getTranslated('add_product_show_in_the_clearance', context)!,
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),

                          const SizedBox(height: 75)

                        ],
                      ),
                    ) : const Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        child: SizedBox(height: 500 , child: OrderShimmer())
                    ),

                    (clearanceController.clearanceSaleProductModel != null
                      && clearanceController.clearanceSaleProductModel!.products!.isNotEmpty) ?
                    const SizedBox(height: 50) : const SizedBox(),


                  ]),
                ),
              ),
            )),


          ]);
        }
      ),
    );
  }
}
