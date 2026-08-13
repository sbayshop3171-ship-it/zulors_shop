import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/features/order/screens/order_screen.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/restock/controllers/restock_controller.dart';
import 'package:zulors_shop_vendor/features/restock/domain/models/restock_product_model.dart';
import 'package:zulors_shop_vendor/features/restock/widgets/catrgory_button_widget.dart';
import 'package:zulors_shop_vendor/features/restock/widgets/restock_list_item_widget.dart';
import 'package:zulors_shop_vendor/features/restock/widgets/search_bar_widget.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class RestockListScreen extends StatefulWidget {
  const RestockListScreen({super.key});
  @override
  State<RestockListScreen> createState() => _RestockListScreenState();
}

class _RestockListScreenState extends State<RestockListScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    Provider.of<RestockController>(context,listen: false).getRestockBrandList();
    Provider.of<RestockController>(context, listen: false).setIndex(0, null, notify: false);
    Provider.of<RestockController>(context, listen: false).setSearching(false, isUpdate: false);
    Provider.of<RestockController>(context, listen: false).getRestockProductList(1);

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),

      onPopInvokedWithResult: (didPop, result) async{
        if( Provider.of<RestockController>(context, listen: false).restockProductModel != null && Provider.of<RestockController>(context, listen: false).restockProductModel?.data == [] ){
          Provider.of<RestockController>(context, listen: false).emptyReStockData();
        }
      },

      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('request_restock_request', context),
          onBackPressed: () {
            if( Provider.of<RestockController>(context, listen: false).restockProductModel != null && Provider.of<RestockController>(context, listen: false).restockProductModel?.data == [] ){
              Provider.of<RestockController>(context, listen: false).emptyReStockData();
            }
            Navigator.pop(context);
          },
          isAction: true,
          isTooltip: true,
          widget: Consumer<RestockController>(
              builder: (context, restockController, child) {
                return (restockController.restockProductModel != null && restockController.restockProductModel!.data!.isNotEmpty) ? Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeRevenueBottom),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeVeryTiny, horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha:0.30),
                        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.10), width: 0.5)
                    ),
                    child: Text(restockController.restockProductModel?.totalSize.toString() ?? '',
                        style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error)
                    ),
                  ),
                ) : const SizedBox();
              }
          ),
        ),

        body: Consumer<RestockController>(
          builder: (context, restockController, child) {
            return RefreshIndicator(
              onRefresh: () async {
                Provider.of<RestockController>(context,listen: false).getRestockBrandList();
                Provider.of<RestockController>(context, listen: false).setIndex(0, null, notify: false);
                Provider.of<RestockController>(context, listen: false).setSearching(false, isUpdate: false);
                Provider.of<RestockController>(context, listen: false).getRestockProductList(1);
              },
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: Column(children: [
                Consumer<CategoryController> (
                    builder: (context, addProductController, child) {
                      return addProductController.categoryList != null?  Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                        child: SizedBox(
                          height: 40,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: addProductController.categoryList!.isEmpty ? 1 : addProductController.categoryList!.length +1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                child: CategoryButtonWidget(
                                  text: index == 0 ? getTranslated('all', context): addProductController.categoryList![index-1].name,
                                  index: index,
                                  categoryId: index == 0 ? null : addProductController.categoryList![index-1].id,
                                ),
                              );
                            },
                          ),
                        ),
                      ) : const SizedBox();
                    }
                ),

                (((restockController.isSearching && restockController.restockProductModel != null)  ||
                    ((restockController.startDate != null && restockController.endDate != null) ||  restockController.selectedBrandIds.isNotEmpty))
                    && (restockController.restockProductModel?.data?.isEmpty ?? false)) ?
                SizedBox(height: 65, child: SearchBarWidget(
                  showFilter: true,
                  controller: _searchController,
                )) : const SizedBox(),

                restockController.restockProductModel != null ? (restockController.restockProductModel?.data?.isNotEmpty ?? false) ?
                Expanded(child: Column(children: [

                  SizedBox(height: 65, child:
                  SearchBarWidget(
                    showFilter: true,
                    controller: _searchController,
                  )
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: PaginatedListViewWidget(
                        scrollController: scrollController,
                        onPaginate: (int? offset) async => await restockController.getRestockProductList(offset!),
                        totalSize: restockController.restockProductModel?.totalSize,
                        offset: restockController.restockProductModel!.offset!,
                        itemView: ListView.builder(padding: const EdgeInsets.all(0),
                          itemCount: restockController.restockProductModel?.data?.length ?? 0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            Product? product = restockController.restockProductModel?.data![index].product;
                            double ratting = (product?.rating?.isNotEmpty ?? false) ?  double.parse('${product?.rating?[0].average}') : 0;
                            Data? data = restockController.restockProductModel?.data![index];
                            return RestockListItemWidget(
                                product: product,
                                ratting: ratting,
                                data: data,
                                index: index
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ])) : const Expanded(child: NoDataScreen(title: 'product_not_found')) : const Expanded(child: OrderShimmer()),
              ]),
            );
          },
        ),
      ),
    );
  }
}
