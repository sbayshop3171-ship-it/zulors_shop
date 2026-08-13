import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product_details/controllers/product_details_controller.dart';
import 'package:zulors_shop_vendor/features/review/controllers/product_review_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/features/product_details/widgets/product_details_review_widget.dart';
import 'package:zulors_shop_vendor/features/product_details/widgets/product_details_widget.dart';


class ProductDetailsScreen extends StatefulWidget {
  final Product? productModel;
  const ProductDetailsScreen({super.key, this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int selectedIndex = 0;

  void load(BuildContext context) {
    Provider.of<ProductReviewController>(context, listen: false).getProductWiseReviewList(context, 1, widget.productModel!.id);
    Provider.of<ProductDetailsController>(context, listen: false).getProductDetails(widget.productModel!.id);
    Provider.of<CategoryController>(context,listen: false).getCategoryList(context,null, 'en');
  }

  @override
  void initState() {
    super.initState();
    load(context);
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController?.addListener((){
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('product_details', context),
        titleTextStyle: titilliumSemiBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: Theme.of(context).textTheme.bodyLarge!.color,
        ),
        isBackButtonExist: true,
        isSwitch: widget.productModel!.requestStatus == 1 ? true: false,
        isAction: true,
      productSwitch: true,
      switchAction: (value) {
       if(value) {
         Provider.of<ProductDetailsController>(context, listen: false).productStatusOnOff(context, widget.productModel!.id, 1);
       } else{
         Provider.of<ProductDetailsController>(context, listen: false).productStatusOnOff(context, widget.productModel!.id, 0);
       }}),
      body: RefreshIndicator(
        onRefresh: () async{
          load(context);
        },
        child: Consumer<AuthController>(
          builder: (authContext,authProvider, _) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: TabBar(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                controller: _tabController,
                dividerColor: Theme.of(context).hintColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.8),
                indicatorSize: TabBarIndicatorSize.tab,
                physics: const BouncingScrollPhysics(),
                isScrollable: false,
                labelPadding: EdgeInsets.zero,
                unselectedLabelStyle: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(text: getTranslated("product_details", context)),
                  Tab(text: getTranslated("reviews", context)),
                ],
              )),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Expanded(child: TabBarView(
                controller: _tabController,
                children: [
                  ProductDetailsWidget(productModel: widget.productModel),
                  ProductReviewWidget(productModel: widget.productModel),
                ],
              )),
            ]);
          }
        ),
      )
    );
  }
}
