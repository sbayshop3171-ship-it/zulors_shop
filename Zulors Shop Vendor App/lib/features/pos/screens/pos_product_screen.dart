import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_delegate_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_search_field_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/category_filter_botto_sheet_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/pos_product_list_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/pos_product_shimmer_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/product_search_dialog_widget.dart';

class POSProductScreen extends StatefulWidget {
  const POSProductScreen({super.key});

  @override
  State<POSProductScreen> createState() => _POSProductScreenState();
}

class _POSProductScreenState extends State<POSProductScreen> {
  @override
  void initState() {
    Provider.of<CategoryController>(context,listen: false).emptyCategoryList();
    Provider.of<ProductController>(context, listen: false).shoHideDialog(false,notify: false);
    Provider.of<ProductController>(context, listen: false).getPosProductList(1, context,[]);
    Provider.of<CategoryController>(context,listen: false).getCategoryList(context,null, 'en');
    super.initState();
  }
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('product_list', context), isCart: true, isAction: true,),
        body: RefreshIndicator(
          onRefresh: () async{
            Provider.of<ProductController>(context, listen: false).getPosProductList(1, context, []);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                  delegate: SliverDelegateWidget(
                  height: 85,
                  child : Consumer<ProductController>(
                    builder: (context, searchProductController, _) {
                      return Container(
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault),
                          child: CustomSearchFieldWidget(
                            controller: searchController,
                            hint: getTranslated('search', context),
                            prefix: Images.iconsSearch,
                            iconPressed: () => (){},
                            onSubmit: (text) => (){},
                            onChanged: (value){
                              if(value.toString().isNotEmpty){
                                searchProductController.getSearchedPosProductList(context, value, []);
                              }else{
                                searchProductController.shoHideDialog(false);
                              }
                            },
                            isFilter: true,
                            filterAction: () async {
                              await Future.delayed(const Duration(milliseconds: 150));
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                context: Get.context!, builder: (_) => const CategoryFilterBottomSheetWidget());
                            },
                          ),
                        ),
                      );
                    }
                  )
              )),
              SliverToBoxAdapter(
                child: Consumer<ProductController>(
                    builder: (context, prodProvider, child) {
                      List<Product>? productList =[];
                      productList = prodProvider.posProductModel?.products;
                      return Stack(
                        children: [
                          Column(children: [
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                            productList != null ? productList.isNotEmpty ?
                            PosProductListWidget(productList : productList, scrollController: _scrollController,productProvider: prodProvider) : Padding(
                              padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/4),
                              child: const NoDataScreen(),
                            ) : const PosProductShimmerWidget(),

                            prodProvider.isLoading ? Center(child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                            )) : const SizedBox.shrink(),

                            const SizedBox(height: Dimensions.paddingSizeBottomSpace,),

                          ]),
                          prodProvider.showDialog?
                          const ProductSearchDialogWidget():const SizedBox(),
                        ],
                      );
                    }
                ),
              )
            ],
          ),),
    );
  }
}
