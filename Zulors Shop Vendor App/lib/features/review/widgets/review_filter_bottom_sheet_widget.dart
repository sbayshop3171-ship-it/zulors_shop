import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/customer_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/product/controllers/product_controller.dart';
import 'package:zulors_shop_vendor/features/review/controllers/product_review_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_container_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_date_picker_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_drop_down_item_widget.dart';
import 'package:zulors_shop_vendor/features/pos/screens/customer_search_screen.dart';
import 'package:zulors_shop_vendor/features/review/widgets/review_product_filter_widget.dart';


class ReviewFilterBottomSheetWidget extends StatefulWidget {
  const ReviewFilterBottomSheetWidget({super.key});

  @override
  State<ReviewFilterBottomSheetWidget> createState() => _ReviewFilterBottomSheetWidgetState();
}

class _ReviewFilterBottomSheetWidgetState extends State<ReviewFilterBottomSheetWidget> {

  @override
  void initState() {
    Provider.of<ProductReviewController>(Get.context!,listen: false).setAllFieldSelected(true, isUpdate: false);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Consumer<ProductReviewController>(
        builder: (context, reviewProvider,_) {
          return Consumer<ProductController>(
            builder: (context, productProvider,_) {
              return Container(decoration: BoxDecoration(color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                      topRight: Radius.circular(Dimensions.paddingSizeDefault))),

                child: Column(mainAxisSize: MainAxisSize.min, children: [


                  Row(
                    children: [
                      Expanded(flex: 1, child: SizedBox()),

                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault,
                              top: Dimensions.paddingSizeExtraLarge,),
                              child: Text(getTranslated('filter_date', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),),),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            (reviewProvider.startDate != null || reviewProvider.endDate != null || reviewProvider.reviewStatusIndex != 0 || Provider.of<CustomerController>(context, listen: false).customerId != 0 || Provider.of<ProductReviewController>(context, listen: false).selectedProductId != 0)  ?
                            InkWell(
                              onTap: () async {
                                reviewProvider.resetReviewData();
                              },
                              child: Row(children: [
                                SizedBox(width: 20, child: Image.asset(Images.reset)),
                                Text('${getTranslated('reset', context)}', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                                const SizedBox(width: Dimensions.paddingSizeDefault,)
                              ]),
                            ) : SizedBox(),
                          ],
                        ))
                    ],
                  ),





                    if(productProvider.sellerProductModel != null && productProvider.sellerProductModel!.products != null && productProvider.sellerProductModel!.products!.isNotEmpty)

                  Consumer<ProductReviewController>(
                    builder: (context,productReviewController,_){
                      return CustomContainerWidget(title: productReviewController.selectedProductName, onTap: (){
                        showDialog(context: context, barrierDismissible: true,
                            builder: (_) => const ReviewProductFilterWidget());
                      });
                    },
                  ),

                  Consumer<CartController>(
                    builder: (context,cartController,_) {
                      return InkWell(
                          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const CustomerSearchScreen())),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                              child: Container(width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(width: .25, color: Theme.of(context).hintColor.withValues(alpha:.75)),
                                      color: Theme.of(context).cardColor,
                                      boxShadow: ThemeShadow.getShadow(context),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                                  ),
                                  child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSize),
                                    child: Row(children: [
                                        Expanded(child: Text(cartController.searchCustomerController.text.trim().isNotEmpty?
                                        cartController.searchCustomerController.text: '${getTranslated('select_customer', context)}',
                                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                                      const Icon(Icons.arrow_drop_down_sharp)
                                      ],
                                    ),
                                  )),
                            ),
                          ));
                    }
                  ),


                    CustomDropDownItemWidget(
                      widget: DropdownButtonFormField<String>(
                        initialValue: reviewProvider.reviewStatusName,
                        isExpanded: true,
                        decoration: const InputDecoration(border: InputBorder.none),
                        iconSize: 24, elevation: 16, style: robotoRegular,
                        onChanged: (value){
                          reviewProvider.setReviewStatusIndex(value == 'select_status'? 0 : value == 'active'? 1 :2);
                        },
                        items: reviewProvider.reviewStatusList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(getTranslated(value, context)!,
                                style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                          );
                        }).toList(),
                      ),
                    ),

                    Row(children: [
                      Expanded(child: CustomDatePickerWidget(
                        title: getTranslated('from', context),
                        image: Images.calenderIcon,
                        text: reviewProvider.startDate != null ?
                        reviewProvider.dateFormat.format(reviewProvider.startDate!).toString() : getTranslated('select_date', context),
                        selectDate: () => reviewProvider.selectDate("start", context),
                      )),
                      Expanded(child: CustomDatePickerWidget(
                        title: getTranslated('to', context),
                        image: Images.calenderIcon,
                        text: reviewProvider.endDate != null ?
                        reviewProvider.dateFormat.format(reviewProvider.endDate!).toString() : getTranslated('select_date', context),
                        selectDate: () => reviewProvider.selectDate("end", context),
                      )),
                    ],),
                    const SizedBox(height: Dimensions.paddingSizeDefault),



                    //const SizedBox(height: Dimensions.paddingSizeDefault),
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: CustomButtonWidget(btnTxt: getTranslated('search', context),
                      onTap: () {
                        if(reviewProvider.startDate == null && reviewProvider.endDate == null && reviewProvider.reviewStatusIndex == 0 && Provider.of<CustomerController>(context, listen: false).customerId == 0 && Provider.of<ProductReviewController>(context, listen: false).selectedProductId == 0) {
                          showCustomToast(message: getTranslated('select_all_fields', context)!, context:  context, isSuccess: false);
                        } else if ((reviewProvider.startDate != null &&  reviewProvider.endDate == null) || (reviewProvider.startDate == null &&  reviewProvider.endDate != null)) {
                          showCustomToast(message: getTranslated('select_start_and_end_time', context)!, context:  context, isSuccess: false);
                        } else if(reviewProvider.startDate != null && reviewProvider.endDate != null && !isEndDateValid(reviewProvider.startDate!, reviewProvider.endDate!)) {
                          showCustomToast(message: getTranslated('end_date_should_not_before_start_date', context)!, context:  context, isSuccess: false);
                        } else{
                          reviewProvider.setAllFieldSelected(true);
                          int?  productId = Provider.of<ProductReviewController>(context, listen: false).selectedProductId;
                          int?  customerId = Provider.of<CustomerController>(context, listen: false).customerId;
                          reviewProvider.filterReviewList(context, productId, customerId);
                        }
                      }),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault,),

              ],),);
            }
          );
        }
      ),
    );
  }

  bool isEndDateValid(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }

}

