import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/addProduct/controllers/add_product_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/features/product/domain/models/product_model.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class SelectCategoryWidget extends StatefulWidget {
  final Product? product;
  const SelectCategoryWidget({super.key, required this.product});

  @override
  SelectCategoryWidgetState createState() => SelectCategoryWidgetState();
}

class SelectCategoryWidgetState extends State<SelectCategoryWidget> {
  
  
  @override
  Widget build(BuildContext context) {
    log("category section===>");
    return Consumer<AddProductController>(
      builder: (context, addProductController, child){
        return Consumer<CategoryController>(
          builder: (context, categoryController, child){
            return Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: Dimensions.paddingSizeSmall),

                categoryController.categoryList != null ? categoryController.categoryList!.isNotEmpty ?
                Column(
                  children: [
                    DropdownDecoratorWidget(
                        child: DropdownButton<int>(
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                          value:   categoryController.categoryIds.isEmpty ? 0 : categoryController.categoryIndex == -1 ? 0 : categoryController.categoryIndex,
                          items: categoryController.categoryIds.map((int? value) {
                            return DropdownMenuItem<int>(
                              value: categoryController.categoryIds.indexOf(value),
                              child: Text(value != 0
                                  ? categoryController.categoryList![(categoryController.categoryIds.indexOf(value) -1)].name!
                                  : getTranslated('select_category', context)!,
                                style: robotoMedium.copyWith(color: value == 0 ? Theme.of(context).hintColor : null),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            categoryController.setCategoryIndex(value, true);
                            categoryController.getSubCategoryList(context, value != 0 ?
                            categoryController.categorySelectedIndex : 0, true, widget.product);},
                          isExpanded: true, underline: const SizedBox())
                    ),

                    addProductController.productTypeIndex == 0 ? const SizedBox(height: Dimensions.paddingSizeMedium) : const SizedBox.shrink(),
                  ],
                ) : const NoDataScreen(title: 'no_category_found',) : const SizedBox.shrink(),


                categoryController.subCategoryList != null ? categoryController.subCategoryList!.isNotEmpty ?
                Column(children: [
                  DropdownDecoratorWidget(
                    child: DropdownButton<int>(
                      icon: const Icon(Icons.keyboard_arrow_down_outlined),
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                      value: categoryController.subCategoryIndex == -1 ? 0 : categoryController.subCategoryIndex,
                      items: categoryController.subCategoryIds.map((int? value) {
                        return DropdownMenuItem<int>(
                          value: categoryController.subCategoryIds.indexOf(value),
                          child: Text(value != 0
                              ? categoryController.subCategoryList![(categoryController.subCategoryIds.indexOf(value) - 1)].name!
                              : getTranslated('sub_category', context)!,
                            style: robotoMedium.copyWith(color: value == 0 ? Theme.of(context).hintColor : null),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        categoryController.setSubCategoryIndex(value, true);
                        categoryController.getSubSubCategoryList( value != 0 ? categoryController.subCategorySelectedIndex : 0, true);
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                    ),
                  ),

                  addProductController.productTypeIndex == 0 ? const SizedBox(height: Dimensions.paddingSizeMedium) : const SizedBox.shrink(),
                ],
                ) : const SizedBox.shrink() : const SizedBox.shrink(),

                categoryController.subSubCategoryList != null ? categoryController.subSubCategoryList!.isNotEmpty ?
                Column(
                  children: [
                    DropdownDecoratorWidget(
                        child: DropdownButton<int>(
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                          value: categoryController.subSubCategoryIndex == -1 ? null :categoryController.subSubCategoryIndex,
                          items: categoryController.subSubCategoryIds.map((int? value) {
                            return DropdownMenuItem<int>(
                                value:  categoryController.subSubCategoryIds.indexOf(value),
                                child: Text(value != 0
                                    ? categoryController.subSubCategoryList![(categoryController.subSubCategoryIds.indexOf(value)-1)].name!
                                    : getTranslated('sub_sub_category', context)!,
                                  style: robotoMedium.copyWith(color: value == 0 ? Theme.of(context).hintColor : null),
                                )
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            categoryController.setSubSubCategoryIndex(value, true);
                          },
                          isExpanded: true,
                          underline: const SizedBox(),
                        ),
                    ),

                    addProductController.productTypeIndex == 0 ? const SizedBox(height: Dimensions.paddingSizeMedium) : const SizedBox.shrink(),
                  ],
                ) : const SizedBox.shrink() : const SizedBox.shrink(),

              ],);
          },

        );
      }
    );
  }
}
