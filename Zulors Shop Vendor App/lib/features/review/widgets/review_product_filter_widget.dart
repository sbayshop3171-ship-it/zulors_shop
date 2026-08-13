import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/review/controllers/product_review_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class ReviewProductFilterWidget extends StatefulWidget {
  const ReviewProductFilterWidget({super.key});

  @override
  State<ReviewProductFilterWidget> createState() => _ReviewProductFilterWidgetState();
}

class _ReviewProductFilterWidgetState extends State<ReviewProductFilterWidget> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        height: MediaQuery.of(context).size.height * .65,
        child: Consumer<ProductController>(
          builder: (context, productProvider,_) {
            return SingleChildScrollView(
              controller: scrollController,
              child: PaginatedListViewWidget(scrollController: scrollController,
                  onPaginate: (int? offset) async{
                    await productProvider.getSellerProductList(Provider.of<ProfileController>(context, listen: false).userInfoModel!.id.toString(), offset!, 'en','', reload: false);
                  },
                  totalSize: productProvider.sellerProductModel?.totalSize,
                  offset: productProvider.sellerProductModel?.offset,
                  itemView: ListView.builder(
                      itemCount: productProvider.sellerProductModel?.products?.length,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            Provider.of<ProductReviewController>(context,listen: false).setReviewProductIndex(
                              index, productProvider.sellerProductModel?.products?[index].id,
                              productProvider.sellerProductModel?.products?[index].name, true,
                            );
                          },
                          child: ListTile(
                            title: Text(
                              productProvider.sellerProductModel?.products?[index].name ?? '',
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      },
                  )
              ),
            );
          }
        ),
      ),
    );
  }
}
