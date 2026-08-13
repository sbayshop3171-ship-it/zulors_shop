import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/slider_product_shimmer_widget.dart';
import 'package:zulors_shop/features/product/controllers/product_controller.dart';
import 'package:zulors_shop/features/product/domain/models/product_model.dart';
import 'package:zulors_shop/features/product/enums/product_type.dart';
import 'package:zulors_shop/features/product/widgets/latest_product/latest_product_widget.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/common/basewidget/title_row_widget.dart';
import 'package:provider/provider.dart';


class LatestProductListWidget extends StatelessWidget {
  const LatestProductListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProductController, ProductModel?>(
      selector: (ctx, productController)=> productController.latestProductModel,
      builder: (context, latestProductModel, child) {

        final size = MediaQuery.of(context).size;

        return (latestProductModel?.products?.isNotEmpty ?? false)  ? Container(
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          color: Theme.of(context).cardColor,
          child: Column( children: [
            TitleRowWidget(
              title: getTranslated('latest_products', context),
              onTap: () => RouterHelper.getViewAllProductScreenRoute(productType: ProductType.latestProduct, action: RouteAction.push),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),



            SizedBox(
              height: (latestProductModel?.products?.length ?? 0) > 5 ? size.height * 0.35 : size.height * 0.16,
              child: GridView.builder(
                clipBehavior: Clip.none,
                itemCount: latestProductModel?.products?.length,
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (latestProductModel?.products?.length ?? 0) > 5 ? 2 : 1,
                  crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                  mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
                  childAspectRatio: 0.40,
                ),
                itemBuilder: (context, index) {

                  final int crossAxisCount = (latestProductModel?.products?.length ?? 0) > 5 ? 2 : 1;

                  final columnIndex = index ~/ crossAxisCount;

                  final lastColumnIndex = ((latestProductModel?.products?.length ?? 0) - 1) ~/ crossAxisCount;

                  final isLastColumn = columnIndex == lastColumnIndex;

                  return SizedBox(
                    height: 100,
                    child: Padding(
                      padding: EdgeInsets.only(right: isLastColumn ? Dimensions.paddingSizeDefault : 0),
                      child: LatestProductWidget(productModel: latestProductModel!.products![index],)
                    ),
                  );
                },
              ),
            ),
          ]),
        ) : latestProductModel == null ? const SliderProductShimmerWidget() : const SizedBox();
      },
    );
  }
}
