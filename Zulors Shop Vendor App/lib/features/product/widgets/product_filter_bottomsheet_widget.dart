import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_calendar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_date_range_picker_widget.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/digital_product_controller.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/category_model.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/enums/product_type_enum.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/features/product/widgets/product_price_range_widget.dart';
import 'package:zulors_shop_vendor/features/profile/controllers/profile_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/features/splash/domain/models/config_model.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({super.key});

  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();






  @override
  void initState() {

    final ProductController productController = Provider.of<ProductController>(context, listen: false);

    productController.initFilterData(context);

    minPriceController.text = (productController.minPrice ?? 0).toStringAsFixed(0);
    maxPriceController.text = (productController.maxPrice ?? 0).toStringAsFixed(0);

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if(!isKeyboardOpen){
      _onCheckPriceRangeValidity(minPriceController, maxPriceController);
    }

    return GestureDetector(
      onTap: ()=> _onCloseKeyboard(minPriceController, maxPriceController),
      child: Consumer<ProductController>(builder: (context, productProvider, _) {

        return Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.95),
          color: Theme.of(context).highlightColor,
          child: Column(children: [

            const _FilterTitleWidget(),
            Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

            Expanded(child: SizedBox(child: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Product Type
                _TitleWidget(title: getTranslated('product_type', context)!),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: SizedBox(height: 60, width: size.width, child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ProductTypeEnum.values.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {

                        _onCloseKeyboard(minPriceController, maxPriceController);

                        productProvider.setSelectedProductType(type: ProductTypeEnum.values[index]);

                        if(ProductTypeEnum.values[index] != ProductTypeEnum.digital) {
                          productProvider.onClearAuthorIds();
                          productProvider.onClearPublisherIds();
                        }

                        if(ProductTypeEnum.values[index] == ProductTypeEnum.digital) {
                          productProvider.onClearBrandIds();
                        }

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: productProvider.selectedProductType == ProductTypeEnum.values[index]
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).hintColor,
                            ),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                          ),
                          child: Center(child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Text(getTranslated(ProductTypeEnum.values[index].name, context)!, style: robotoRegular.copyWith(
                              color: productProvider.selectedProductType == ProductTypeEnum.values[index]
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).hintColor,
                            )),
                          )),
                        ),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: Dimensions.paddingSizeMedium),

                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),


                ///Price Range
                _TitleWidget(title: getTranslated('price_range', context)!),

                ProductPriceRangeWidget(
                  minPriceController: minPriceController,
                  maxPriceController: maxPriceController,
                ),
                const SizedBox(height: Dimensions.paddingSizeMedium),

                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),


                ///Date Range
                _TitleWidget(title: getTranslated('created_at', context)!),

                InkWell(
                  onTap: () {
                    _onCloseKeyboard(minPriceController, maxPriceController);

                    showDialog(context: context, builder: (BuildContext context){
                    return Dialog(child: SizedBox(height: 400, child: CustomCalendarWidget(
                      initDateRange: PickerDateRange(productProvider.startDate, productProvider.endDate),
                      onSubmit: (PickerDateRange? range) => productProvider.selectDate(range?.startDate, range?.endDate),
                    )));
                  });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          CustomDateRangePickerWidget(
                            text: productProvider.startDate == null
                                ? 'dd-mm-yyyy'
                                : DateConverter.dateStringMonthYear(productProvider.startDate),
                          ),

                          const Icon(Icons.horizontal_rule, size: Dimensions.iconSizeMedium),

                          CustomDateRangePickerWidget(
                            text: productProvider.endDate == null
                                ? 'dd-mm-yyyy'
                                : DateConverter.dateStringMonthYear(productProvider.endDate),
                          ),
                        ]),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: SizedBox(width: Dimensions.iconSizeMedium, height: Dimensions.iconSizeMedium, child: Image.asset(Images.calendarIconFilter)),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeMedium),

                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),


                ///Brand
                if(productProvider.selectedProductType != ProductTypeEnum.digital)...[
                  _TitleWidget(title: getTranslated('brand', context)!),

                  Consumer<ProductController>(builder: (context, productController, _) {
                    return Container(
                      height: productProvider.brandSeeMore || (productController.brandList?.length ?? 0) < 4 ? null : 150,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                      child: ListView.builder(
                        itemCount: productController.brandList?.length ?? 0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index){
                          if(productController.brandList?[index].id == null) return const SizedBox.shrink();

                          return _FilterItem(
                            title: productController.brandList?[index].name,
                            checked: productProvider.selectedBrandIds.contains(productController.brandList?[index].id),
                            onTap: () {
                              _onCloseKeyboard(minPriceController, maxPriceController);
                              productProvider.onChangeBrandIds(productController.brandList![index].id!);
                            },
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  _ViewMoreWidget(
                    onTap: () {
                      _onCloseKeyboard(minPriceController, maxPriceController);
                      productProvider.toggleBrandSeeMore();
                    } ,
                    isMore: productProvider.brandSeeMore,
                    isActive: (Provider.of<ProductController>(context, listen: false).brandList?.length ?? 0) > 3,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeMedium,),

                  Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),
                ],

                if(productProvider.selectedProductType != ProductTypeEnum.physical) ...[
                  _PublisherFilterItemWidget(minPriceController, maxPriceController),

                  _AuthorFilterItemWidget(minPriceController, maxPriceController),
                ],





                ///Category
                _TitleWidget(title: getTranslated('category', context)!),

                Consumer<CategoryController>(builder: (context, addProductProvider, _) {
                  return Container(
                    height: productProvider.categorySeeMore ? null : 150,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                    child: ListView.builder(
                      itemCount: addProductProvider.categoryList?.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index){
                        return _FilterItem(
                          title: addProductProvider.categoryList?[index].name,
                          checked: addProductProvider.categoryList?[index].checked ?? false,
                          onTap: () {
                            _onCloseKeyboard(minPriceController, maxPriceController);
                            addProductProvider.toggleCategoryChecked(index);
                          },
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(height: Dimensions.paddingSizeSmall,),

                _ViewMoreWidget(
                  onTap: () {
                    _onCloseKeyboard(minPriceController, maxPriceController);
                    productProvider.toggleCategorySeeMore();
                  },
                  isMore: productProvider.categorySeeMore,
                  isActive: (Provider.of<CategoryController>(context, listen: false).categoryList?.length ?? 0) > 3,
                ),
                const SizedBox(height: Dimensions.paddingSizeMedium,),

                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

              ],
            )))),

            _ButtonWidget(minPriceController, maxPriceController)
          ]),
        );
      }),
    );
  }
}


class _PublisherFilterItemWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  const _PublisherFilterItemWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductController>(builder: (context, productController, _) {
        return Consumer<DigitalProductController>(builder: (context, digitalProductController, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TitleWidget(title: getTranslated('publisher', context)!),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Container(
                  height: productController.publishingHouseSeeMore ||  (digitalProductController.publishingHouseList?.length ?? 0) < 4 ? null : 150,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: digitalProductController.publishingHouseList?.length ?? 0,
                    itemBuilder: (context, index){

                      if(digitalProductController.publishingHouseList?[index].id == null) return const SizedBox.shrink();

                      return _FilterItem(
                        title: digitalProductController.publishingHouseList?[index].name,
                        checked: productController.selectedPublishingHouseIds.contains(digitalProductController.publishingHouseList?[index].id),
                        onTap: () => productController.onChangePublisherIds(digitalProductController.publishingHouseList![index].id!),
                      );
                    },
                  ),),
              ),
              const SizedBox(height: Dimensions.paddingSizeMedium),

              _ViewMoreWidget(
                onTap: () {
                  _onCloseKeyboard(minPriceController, maxPriceController);
                  productController.onTogglePublishingHouseSeeMore();
                } ,
                isMore: productController.publishingHouseSeeMore,
                isActive: (digitalProductController.publishingHouseList?.length ?? 0) > 3,
              ),
              const SizedBox(height: Dimensions.paddingSizeMedium,),

              Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),
            ],
          );
        });
      }
    );
  }
}

class _ViewMoreWidget extends StatelessWidget {
  final Function() onTap;
  final bool isMore;
  final bool isActive;
  const _ViewMoreWidget({
    required this.onTap, required this.isMore, required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return isActive ?  Center(child: InkWell(
      onTap: ()=> onTap(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
        child: Text(getTranslated(isMore ?  'view_less' : 'view_more', context)!, style: robotoRegular.copyWith(
          color: Theme.of(context).primaryColor.withValues(alpha: .7),
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).primaryColor.withValues(alpha: .7),
        )),
      ),
    )) : const SizedBox();
  }
}

class _AuthorFilterItemWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  const _AuthorFilterItemWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(builder: (context, productController, _) {
      return Consumer<DigitalProductController>(builder: (context, digitalProductController, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TitleWidget(title: getTranslated('author', context)!),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Container(
                height: productController.authorSeeMore || (digitalProductController.authorsList?.length ?? 0) < 4 ? null : 150,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: digitalProductController.authorsList?.length ?? 0,
                  itemBuilder: (context, index){

                    if(digitalProductController.authorsList?[index].id == null) return const SizedBox.shrink();

                    return _FilterItem(
                      title: digitalProductController.authorsList?[index].name,
                      checked: productController.selectedAuthorIds.contains(digitalProductController.authorsList?[index].id),
                      onTap: () => productController.onChangeAuthorIds(digitalProductController.authorsList![index].id!),
                    );
                  },
                ),),
            ),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            _ViewMoreWidget(
              onTap: (){
                _onCloseKeyboard(minPriceController, maxPriceController);
                productController.onToggleAuthorSeeMore();
              },
              isMore: productController.authorSeeMore,
              isActive: (digitalProductController.authorsList?.length ?? 0) > 3,
            ),
            const SizedBox(height: Dimensions.paddingSizeMedium,),

            Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),
          ],
        );
      });
    });
  }
}



class _TitleWidget extends StatelessWidget {
  final String title;
  const _TitleWidget({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
      child: Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }
}

class _FilterTitleWidget extends StatelessWidget {
  const _FilterTitleWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 60, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
      child: Stack(children: [
        Align(alignment: Alignment.center,
          child: Text(getTranslated('filter_data', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge,)),
        ),

        Positioned(right: 0, top: Dimensions.paddingSizeMedium, child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).hintColor.withValues(alpha: .25),
            ),
            child: Center(child: Image.asset(Images.crossIcon, width: 10,)),
          ),

        )),
      ]),
    ));
  }
}

class _ButtonWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;

  const _ButtonWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
          spreadRadius: 0.5, blurRadius: 0.3,
        )],
      ),
      height: 80,
      child: Consumer<ProductController>(builder: (ctx, productController, _) {
        return Row(children: [
          Expanded(child: CustomButtonWidget(
            isColor: true,
            btnTxt: '${getTranslated('clear_filter', context)}',
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .125),
            buttonHeight: 55,
            fontColor: Theme.of(context).textTheme.bodyLarge?.color,
            onTap: () async {
              Navigator.pop(context);

              if(_canResetFilters(context, )) {
                productController.getSellerProductList(
                  '${Provider.of<ProfileController>(context, listen: false).userId}',
                  productController.sellerProductModel?.offset ?? 1,
                  'en',
                  productController.sellerProductModel?.search ?? '',
                  isUpdate: true,
                );

                productController.setPriceRange(0, Provider.of<SplashController>(context, listen: false).configModel?.productMaxPriceRange ?? 0);
              }

            },
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: Consumer<AddProductController>(builder: (ctx, addProductProvider, _) {
            return CustomButtonWidget(
              isLoading: productController.sellerProductModel == null,
              onTap: !_canFilter(productController.sellerProductModel, context) ? null : () async {

                final priceRange = _getPriceRange(min: productController.minPrice, max: productController.maxPrice, context: ctx);

                await productController.getSellerProductList(
                  '${Provider.of<ProfileController>(context, listen: false).userId}',
                  productController.sellerProductModel?.offset ?? 1,
                  'en',
                  productController.sellerProductModel?.search ?? '',
                  brandIds: productController.selectedBrandIds.toList(),
                  categoryIds: _getSelectedCategoryIds(context),
                  isUpdate: true,
                  productType: productController.selectedProductType?.name,
                  minPrice: priceRange.minPrice,
                  maxPrice: priceRange.maxPrice,
                  startDate: productController.startDate,
                  endDate: productController.endDate,
                  publishingHouseIds: productController.selectedPublishingHouseIds.toList(),
                  authorIds: productController.selectedAuthorIds.toList(),
                );

                if(context.mounted) {
                  Navigator.pop(context);

                }
              },
              btnTxt: '${getTranslated('filter', context)}',
              backgroundColor: _canFilter(productController.sellerProductModel, context) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.6),
              buttonHeight: 55,
            );
          })),

        ]);
      }),
    );
  }

  ({double? minPrice, double? maxPrice}) _getPriceRange({required double? min, required double? max, required BuildContext context}) {

    if((min == null || min == 0) && max == Provider.of<SplashController>(context, listen: false).configModel?.productMaxPriceRange) return (minPrice: null, maxPrice: null);

    return (minPrice: min, maxPrice: max);
  }

  bool _canResetFilters(BuildContext context) {
    final productController = Provider.of<ProductController>(context, listen: false);

    return (productController.sellerProductModel?.brandIds?.isNotEmpty ?? false) ||
        (productController.sellerProductModel?.categoryIds?.isNotEmpty ?? false) ||
        (productController.sellerProductModel?.authorIds?.isNotEmpty ?? false) ||
        (productController.sellerProductModel?.publishHouseIds?.isNotEmpty ?? false) ||
        productController.sellerProductModel?.productType != null ||
        productController.sellerProductModel?.startDate != null ||
        productController.sellerProductModel?.endDate != null ||
        productController.sellerProductModel?.maxPrice != null ||
        productController.sellerProductModel?.minPrice != null;
  }


  List<int> _getSelectedCategoryIds(BuildContext context) {
    return (Provider.of<CategoryController>(context, listen: false).categoryList ?? [])
        .where((category) => category.checked ?? false) // Filter checked brands
        .map((category) => category.id!) // Map to their IDs
        .toList(); // Convert to List<int>
  }

  bool _canFilter(ProductModel? productModel, BuildContext context) {

    if(productModel == null) return false;

    final ProductController productController = Provider.of<ProductController>(context, listen: false);
    final CategoryController categoryController = Provider.of<CategoryController>(context, listen: false);

    if(!productController.isPriceRangeValid) return false;

    return productController.endDate != productModel.endDate ||
        productController.startDate != productModel.startDate ||
        productController.selectedProductType != productModel.productType ||
        productController.minPrice != productModel.minPrice ||
        (productController.maxPrice != productModel.maxPrice && productModel.maxPrice != null) ||
        !_areCategoriesEqual(categoryController.categoryList, productModel.categoryIds) ||
        !_areBrandsEqual(productController.selectedBrandIds, productModel.brandIds ?? {}, productModel.productType) ||
        !_areAuthorsEqual(productController.selectedAuthorIds, productModel.authorIds ?? {}, productModel.productType) ||
        !_arePublishersEqual(productController.selectedPublishingHouseIds, productModel.publishHouseIds ?? {}, productModel.productType);

  }

  bool _areCategoriesEqual(List<CategoryModel>? categoryList, List<int>? currentCategoryIds) {

    final Set<int> selectedCategoryIds = (categoryList?.isEmpty ?? true) ? {} : categoryList!
        .where((category) => category.checked == true)
        .map((category) => category.id!)
        .toSet();

    final Set<int> currentCategorySet = currentCategoryIds?.toSet() ?? {};

    return selectedCategoryIds.length == currentCategorySet.length &&
        selectedCategoryIds.containsAll(currentCategorySet);
  }


  bool _areAuthorsEqual(Set<int> authorIds, Set<int> currentAuthorIds, ProductTypeEnum? type) {
    if(type == ProductTypeEnum.physical) return true;

    return authorIds.length == currentAuthorIds.length &&
        authorIds.containsAll(currentAuthorIds);
  }

  bool _arePublishersEqual(Set<int> publisherIds, Set<int> currentPublisherIds, ProductTypeEnum? type) {
    if(type == ProductTypeEnum.physical) return true;

    return publisherIds.length == currentPublisherIds.length &&
        publisherIds.containsAll(currentPublisherIds);
  }

  bool _areBrandsEqual(Set<int> brandIds, Set<int> currentBrandIds, ProductTypeEnum? type) {
    if(type == ProductTypeEnum.digital) return true;

    return brandIds.length == currentBrandIds.length &&
        brandIds.containsAll(currentBrandIds);
  }

}


class _FilterItem extends StatelessWidget {
  final String? title;
  final bool checked;
  final Function()? onTap;
  const _FilterItem({required this.title, required this.checked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.min, children: [
            Expanded(child: Text(title??'', style: robotoRegular.copyWith(color: checked ? null : Theme.of(context).hintColor))),

            Icon(checked ? Icons.check_box_outlined : Icons.check_box_outline_blank_rounded,
              color: (checked && !Provider.of<ThemeController>(context, listen: false).darkTheme) ?
              Theme.of(context).primaryColor:(checked && Provider.of<ThemeController>(context, listen: false).darkTheme)?
              Colors.white : Theme.of(context).hintColor.withValues(alpha:.5),
            ),

          ]),
        ),
      ),
    );
  }
}

void _onCloseKeyboard(TextEditingController minController, TextEditingController maxController){
  _onCheckPriceRangeValidity(minController, maxController);
  FocusManager.instance.primaryFocus?.unfocus();
}


void _onCheckPriceRangeValidity(TextEditingController minController, TextEditingController maxController){
  final ProductController productController = Provider.of<ProductController>(Get.context!, listen: false);

  if(!productController.isPriceRangeValid){
    final ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;
    final double systemMaxPrice = PriceConverter.convertAmount(configModel?.productMaxPriceRange ?? 1, Get.context!);

    final double tempMin = productController.invalidMinPrice ?? 0;
    final double tempMax = productController.invalidMaxPrice ?? 0;

    if(tempMin > systemMaxPrice || tempMax > systemMaxPrice){
      productController.setPriceRange(systemMaxPrice, systemMaxPrice);
      minController.text = systemMaxPrice.toString();
      maxController.text = systemMaxPrice.toString();
    }
    else if(tempMin > tempMax){
      productController.setPriceRange(tempMin, tempMin);
      minController.text = tempMin.toString();
      maxController.text = tempMin.toString();
    }
  }
}


