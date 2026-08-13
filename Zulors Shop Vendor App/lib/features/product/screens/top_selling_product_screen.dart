import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/top_selling_product_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/title_row_widget.dart';
import 'package:zulors_shop_vendor/features/product/screens/product_list_view_screen.dart';
import 'package:zulors_shop_vendor/features/product/widgets/top_most_product_card_widget.dart';

class TopSellingProductScreen extends StatelessWidget {
  final bool isMain;
  final ScrollController? scrollController;
  const TopSellingProductScreen({super.key, this.isMain = false, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{
        Provider.of<ProductController>(context,listen: false).getTopSellingProductList(1, context, 'en');
      },
      child: Consumer<ProductController>(
        builder: (context, prodProvider, child) {
          List<Products>? productList;
          productList = prodProvider.topSellingProductModel?.products;

          return Column(mainAxisSize: MainAxisSize.min, children: [
            isMain?
            productList != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [

                SizedBox(width: Dimensions.iconSizeDefault, child: Image.asset(Images.topSellingIcon)),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Expanded(child: TitleRowWidget(title: '${getTranslated('top_selling_products', context)}',
                  onTap: (productList.length > 4)
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen(title: 'top_selling_products')))
                      : null,
                )),
              ]),
            ) : TopSellingProductSectionShimmer(isMain: isMain, isDarkMode : Provider.of<ThemeController>(context).darkTheme) : const SizedBox(),

            productList != null ? productList.isNotEmpty ?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall,
                  vertical: Dimensions.paddingSizeSmall),
              child: PaginatedListViewWidget(
                reverse: false,
                scrollController: scrollController,
                totalSize: prodProvider.topSellingProductModel!.totalSize,
                offset: prodProvider.topSellingProductModel != null ? int.parse(prodProvider.topSellingProductModel!.offset!) : null,
                onPaginate: (int? offset) async {
                  await prodProvider.getTopSellingProductList(offset!, context,'en', reload: false);
                },

                itemView: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 9,
                    crossAxisSpacing: 5,
                    childAspectRatio: MediaQuery.of(context).size.width < 400? 1/1.23: MediaQuery.of(context).size.width < 415? 1/1.22 : 1/1.28,
                  ),
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: isMain && productList.length >4? 4 : productList.length,
                  itemBuilder: (context, index) {

                    return TopMostProductWidget(productModel: productList![index].product, totalSold: productList[index].count);
                  },
                ),
              ),

            ) : Padding(padding: EdgeInsets.only(top: isMain ? 0.0 :MediaQuery.of(context).size.height/3),
                child: const NoDataScreen()) : const SizedBox.shrink(),

          ]);
        },
      ),
    );
  }
}



class TopSellingProductSectionShimmer extends StatelessWidget {
  final bool isMain;
  final bool isDarkMode;
  const TopSellingProductSectionShimmer({
    super.key,
    required this.isMain,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[500]! : Colors.grey[100]!;
    final shimmerColor = Theme.of(context).colorScheme.secondaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMain)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, // Dimensions.paddingSizeDefault
              vertical: 12, // Dimensions.paddingSizeSmall
            ),
            child: Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  color: shimmerColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 14,
                    width: double.infinity,
                    color: shimmerColor,
                  ),
                ),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Dimensions.paddingSizeSmall
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 9,
                crossAxisSpacing: 5,
                childAspectRatio: MediaQuery.of(context).size.width < 400
                    ? 1 / 1.23
                    : MediaQuery.of(context).size.width < 415
                    ? 1 / 1.22
                    : 1 / 1.28,
              ),
              itemCount: 4, // Only preview top 4 if isMain
              itemBuilder: (context, index) => _ShimmerProductCard(color: shimmerColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  final Color color;
  const _ShimmerProductCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.width / 2 - 50;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.0 : 0.125),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Column(children: [

          Padding(
            padding: const EdgeInsets.all(6),
            child: Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          Padding(padding: const EdgeInsets.fromLTRB(6, 0, 6, 6), child: Column(children: [

            Container(
              height: 14,
              width: double.infinity,
              color: color,
            ),
            const SizedBox(height: 6),

            Center(child: Container(
              height: 20,
              width: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ])),
        ]),
      ),
    );
  }
}
