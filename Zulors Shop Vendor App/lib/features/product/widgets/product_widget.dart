import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/screens/add_product_screen.dart';
import 'package:zulors_shop_vendor/features/order/screens/order_screen.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/animated_floating_button_widget.dart';
import 'package:zulors_shop_vendor/features/shop/widgets/shop_product_card_widget.dart';
import 'package:zulors_shop_vendor/features/product/screens/stock_out_product_screen.dart';

class ProductViewWidget extends StatefulWidget {
  final int? sellerId;
  final bool fromNotification;
  final double keyboardHeight;
  const ProductViewWidget({super.key, required this.sellerId, this.fromNotification = false, required this.keyboardHeight});

  @override
  State<ProductViewWidget> createState() => _ProductViewWidgetState();
}

class _ProductViewWidgetState extends State<ProductViewWidget> {

  ScrollController scrollController = ScrollController();
  String message = "";
  bool activated = false;
  bool endScroll = false;
  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
      setState(() {
        endScroll = true;
        message = "bottom";
        if (kDebugMode) {
          print('============$message=========');
        }
      });
    }else{
      if(endScroll) {
        setState(() {
          endScroll = false;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  int? userId;

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    if(widget.fromNotification) {
      Provider.of<ProductController>(context, listen: false).emptySellerProduct();
      Provider.of<ProfileController>(context, listen: false).getSellerInfo().then((responce) {
        if(responce.isSuccess) {
          userId = Provider.of<ProfileController>(Get.context!, listen: false).userId;
          Provider.of<ProductController>(Get.context!, listen: false).getSellerProductList(
            Provider.of<ProfileController>(Get.context!, listen: false).userId.toString(), 1,
            Provider.of<LocalizationController>(Get.context!, listen: false).locale.languageCode == 'US'?'en':
            Provider.of<LocalizationController>(Get.context!, listen: false).locale.countryCode!.toLowerCase(),'');
        } else {
          Provider.of<ProductController>(Get.context!, listen: false).getSellerProductList(
            Provider.of<ProfileController>(Get.context!, listen: false).userId.toString(), 1,
            Provider.of<LocalizationController>(Get.context!, listen: false).locale.languageCode == 'US'?'en':
            Provider.of<LocalizationController>(Get.context!, listen: false).locale.countryCode!.toLowerCase(),'');
        }
      });
    }else{
      Provider.of<ProductController>(context, listen: false).getSellerProductList(
        Provider.of<ProfileController>(context, listen: false).userId.toString(), 1,
        Provider.of<LocalizationController>(context, listen: false).locale.languageCode == 'US'?'en':
        Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase(),'');
    }
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<ProfileController>(context, listen: false).userId.toString();



    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<ProductController>(context, listen: false).getSellerProductList(
            Provider.of<ProfileController>(context, listen: false).userId.toString(), 1,
            Provider.of<LocalizationController>(context, listen: false).locale.languageCode == 'US'?'en':
            Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase(),'');
      },
      child: Consumer<ProductController>(
        builder: (context, prodProvider, child) {
          return SizedBox(height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                (prodProvider.sellerProductModel != null) ? (prodProvider.sellerProductModel!.products != null && prodProvider.sellerProductModel!.products!.isNotEmpty)?
                NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: PaginatedListViewWidget(
                      reverse: false,
                      scrollController: scrollController,
                      totalSize: prodProvider.sellerProductModel?.totalSize,
                      offset: prodProvider.sellerProductModel != null ? int.parse(prodProvider.sellerProductModel!.offset.toString()) : null,
                      onPaginate: (int? offset) async {
                        await prodProvider.getSellerProductList(
                          userId, offset!, 'en', '', reload: false,
                          minPrice: prodProvider.sellerProductModel?.minPrice,
                          maxPrice: prodProvider.sellerProductModel?.maxPrice,
                          productType: prodProvider.sellerProductModel?.productType?.name,
                          categoryIds: prodProvider.sellerProductModel?.categoryIds,
                          brandIds: prodProvider.sellerProductModel?.brandIds?.toList(),
                          authorIds: prodProvider.sellerProductModel?.authorIds?.toList(),
                          publishingHouseIds: prodProvider.sellerProductModel?.publishHouseIds?.toList(),
                          startDate: prodProvider.sellerProductModel?.startDate,
                          endDate: prodProvider.sellerProductModel?.endDate,
                        );
                      },

                      itemView: ListView.builder(
                        itemCount: prodProvider.sellerProductModel!.products!.length,
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return ShopProductWidget(productModel: prodProvider.sellerProductModel!.products![index],);
                        },
                      ),
                    ),
                  ),
                ) : const NoDataScreen() : const OrderShimmer(),


               if(widget.keyboardHeight == 0)...[
                 if(!endScroll)
                   Positioned(
                     bottom: 20,
                     right: Provider.of<LocalizationController>(context, listen: false).isLtr ? 20: null,
                     left: Provider.of<LocalizationController>(context, listen: false).isLtr ? null: 20,
                     child: Align(
                       alignment: Alignment.bottomRight,
                       child: ScrollingFabAnimated(
                         width: 150,
                         color: Theme.of(context).cardColor,
                         icon: SizedBox(width: Dimensions.iconSizeExtraLarge,child: Image.asset(Images.addIcon)),
                         text: Text(getTranslated('add_new', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                         onPress: (){
                           Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AddProductScreen()));
                         },
                         animateIcon: true,
                         inverted: false,
                         scrollController: scrollController,
                         radius: 10.0,
                       ),
                     ),
                   ),

                 if(!endScroll)
                   Positioned(bottom: 100,
                     right: Provider.of<LocalizationController>(context, listen: false).isLtr ? 22: null,
                     left: Provider.of<LocalizationController>(context, listen: false).isLtr ? null: 22,
                     child: ScrollingFabAnimated(width: 200, color: Theme.of(context).cardColor,
                       icon: SizedBox(width: Dimensions.iconSizeExtraLarge,child: Image.asset(Images.limitedStockIcon)),
                       text: Text(getTranslated('limited_stocks', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                       onPress: () {
                         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StockOutProductScreen()));
                       },
                       animateIcon: true,
                       inverted: false,
                       scrollController: scrollController,
                       radius: 10.0,
                     ),
                   ),
               ],
              ],
            ),
          );
        },
      ),
    );
  }
}

