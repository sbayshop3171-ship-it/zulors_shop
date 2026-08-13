import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/filter_icon_widget.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product/widgets/product_filter_bottomsheet_widget.dart';
import 'package:zulors_shop_vendor/helper/debounce_helper.dart';
import 'package:zulors_shop_vendor/localization/controllers/localization_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_search_field_widget.dart';
import 'package:zulors_shop_vendor/features/product/widgets/product_widget.dart';

class ProductListMenuScreen extends StatefulWidget {
  final bool fromNotification;
  const ProductListMenuScreen({super.key,  this.fromNotification = false});
  @override
  State<ProductListMenuScreen> createState() => _ProductListMenuScreenState();
}

class _ProductListMenuScreenState extends State<ProductListMenuScreen> {

  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);
  TextEditingController searchController = TextEditingController();
  int? userId;




  void _getBrandList(){
    ///getting brand list for product filter
    String languageCode = Provider.of<LocalizationController>(context, listen: false).locale.countryCode == 'US' ?
    'en' : Provider.of<LocalizationController>(context, listen: false).locale.countryCode!.toLowerCase();
    Provider.of<ProductController>(Get.context!,listen: false).getBrandList(Get.context!, languageCode);
  }


  @override
  void initState() {
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    _getBrandList();
    super.initState();
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {

        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => const DashboardScreen(),
          ), (route) => false);

        }else {
          if(!didPop) {
            Navigator.of(context).pop();
          }
        }



      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('product_list', context),
          onBackPressed: () {
            if(widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Column(children: [
          SizedBox(height: 80,
            child: Consumer<ProductController>(
              builder: (context, productController, _) {
                return Container(
                  color: Theme.of(context).cardColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeDefault),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomSearchFieldWidget(
                            controller: searchController,
                            hint: getTranslated('search_by_product_name', context),
                            prefix: Images.iconsSearch,
                            iconPressed: () => (){},
                            onSubmit: (text) => (){},
                            onChanged: (value)=> _debounce.run(() async {
                              productController.getSellerProductList(userId.toString(), 1, 'en', value, reload: true);
                            }),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSize),

                        ///filter Icon
                        FilterIconWidget(
                          filterCount: _getFilterCount(productController.sellerProductModel),
                          onTap: productController.sellerProductModel == null ? null : (){
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (builder) => const ProductFilterBottomSheet(),
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                );
              }
            )),
           Expanded(child: ProductViewWidget(
             sellerId: userId,
             fromNotification: widget.fromNotification,
             keyboardHeight: MediaQuery.of(context).viewInsets.bottom,
           ))
          ],
        ),

      ),
    );


  }

  int _getFilterCount(ProductModel? sellerProductModel) {
    if (sellerProductModel == null) return 0;

    final int nonNullFilterCount = [
      sellerProductModel.productType,
      sellerProductModel.maxPrice,
      sellerProductModel.endDate,
    ].whereType<Object>().length;

    final int categoryCount = sellerProductModel.categoryIds?.length ?? 0;
    final int brandCount = sellerProductModel.brandIds?.length ?? 0;
    final int publisherCount = sellerProductModel.publishHouseIds?.length ?? 0;
    final int authorCount = sellerProductModel.authorIds?.length ?? 0;

    return nonNullFilterCount + categoryCount + brandCount + publisherCount + authorCount;
  }

}
