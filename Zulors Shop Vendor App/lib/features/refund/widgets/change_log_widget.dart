import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/addProduct/screens/add_product_screen.dart';


class ChangeLogWidget extends StatelessWidget {
  final String paidBy;
  const ChangeLogWidget({super.key, required this.paidBy});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('change_log', context),),
      body: Consumer<RefundController>(
        builder: (context, refundReq, _) {
          String payment = paidBy.replaceAll('_', ' ');

          return Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(
                color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                spreadRadius: 0.5,
                blurRadius: 0.3,
              )],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column( children: [
                if(refundReq.refundDetailsModel != null && refundReq.refundDetailsModel!.refundRequest != null && refundReq.refundDetailsModel!.refundRequest!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: ItemWidget(
                      lestValue: 'refund_request',
                      rightValue: DateConverter.localDateToIsoStringDate(DateTime.parse(refundReq.refundDetailsModel!.refundRequest![0].createdAt!)),
                    ),
                  ),
                ItemWidget(lestValue: 'paid_by', rightValue: payment.capitalize(), isPayment: true,),
                const SizedBox(height: Dimensions.paddingSizeButton),

                refundReq.refundDetailsModel != null? (refundReq.refundDetailsModel!.refundRequest != null && refundReq.refundDetailsModel!.refundRequest!.isNotEmpty) ?
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: refundReq.refundDetailsModel!.refundRequest![0].refundStatus!.length,
                      itemBuilder: (context,index) {
                        return IntrinsicHeight(
                          child: Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 1, child:Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                                  color: Theme.of(context).primaryColor,),
                                child: Icon(Icons.info_outline,color: Theme.of(context).cardColor),
                              ),
                          
                              index == refundReq.refundDetailsModel!.refundRequest![0].refundStatus!.length - 1 ?
                              const SizedBox() : Expanded(child: Container(width: 2, color: Theme.of(context).primaryColor)),
                          
                            ])),
                          
                          
                            Expanded(flex:6,
                              child: Container(
                                margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          
                                  ItemWidget(lestValue: 'status',rightValue: refundReq.refundDetailsModel!.refundRequest![0].refundStatus![index].status!.capitalize()),
                          
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                    child: ItemWidget(lestValue: 'updated_by',rightValue: refundReq.refundDetailsModel!.refundRequest![0].refundStatus![index].changeBy ?? ''),
                                  ),
                          
                                  ItemWidget(lestValue: 'reason', rightValue: refundReq.refundDetailsModel!.refundRequest![0].refundStatus![index].message ?? ''),

                                  const SizedBox(height: Dimensions.paddingSizeSmall)
                          
                                ]),
                              ),
                            ),

                          ],
                          ),
                        );
                      }
                  ),
                ) : const NoDataScreen(): const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
              ),
            ),
          );
        }
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String? lestValue;
  final String? rightValue;
  final bool isPayment;
  const ItemWidget({super.key, required this.lestValue, required this.rightValue,  this.isPayment = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${getTranslated(lestValue, context)} : ',
          style: titilliumRegular.copyWith(color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault)),
      Expanded(
        child: Text(rightValue ?? '', style: robotoBold.copyWith(color: rightValue! == 'Pending'? Theme.of(context).primaryColor : rightValue! == 'Refunded'? Theme.of(context).colorScheme.onTertiaryContainer : rightValue! == 'Rejected'? Theme.of(context).colorScheme.error : rightValue! == 'Approved'? Theme.of(context).colorScheme.onTertiaryContainer : isPayment? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeDefault), maxLines: 30, overflow: TextOverflow.ellipsis),
      )]);
  }
}
