import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/addProduct/domain/models/category_model.dart';
import 'package:zulors_shop_vendor/features/product/controllers/category_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';

class CategoryFilterBottomSheetWidget extends StatelessWidget {
  const CategoryFilterBottomSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryController>(
      builder: (context, categoryProvider, _) {
        List<CategoryModel>? categoryList = [];
        categoryList = categoryProvider.categoryList;
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.paddingSizeSmall),
              topRight: Radius.circular(Dimensions.paddingSizeSmall),
            )
          ),
          child: (categoryList != null && categoryList.isNotEmpty && categoryProvider.selectedCategory.isNotEmpty) ? Column( mainAxisSize: MainAxisSize.min,
            children: [
              Text(getTranslated('category_wise_filter', context)!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: categoryList.length,
                        itemBuilder: (context, index){
                          return Row(children: [
                            Checkbox(value: categoryProvider.selectedCategory[index],
                                onChanged: (onChanged){
                                  categoryProvider.setSelectedCategoryForFilter(index, onChanged);
                                }),
                            Text(categoryList![index].name!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          ],);
                        }),
                    ],
                  ),
                ),
              ),



              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Consumer<ProductController>(
                  builder: (context, productProvider, _) {
                    List<String> ids = [];
                    return CustomButtonWidget(btnTxt: getTranslated('search', context),
                      onTap: (){

                        if(categoryProvider.selectedCategory.isNotEmpty){
                          for(int i=0; i< categoryProvider.selectedCategory.length; i++){
                            if(categoryProvider.selectedCategory[i]!){
                              ids.add(categoryList![i].id.toString());
                            }
                          }
                          Navigator.pop(context);
                          Provider.of<ProductController>(context, listen: false).getPosProductList(1, context,ids);
                        }else{
                          showCustomSnackBarWidget(getTranslated('please_select_a_category_to_filter', context), context, isToaster: true);
                        }},);
                  }
                ),
              )



            ],
          ) : const Center(child: CircularProgressIndicator()),
        );
      }
    );
  }
}
