import 'package:flutter/material.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/delivery_man/widgets/order_change_log_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/screens/order_details_screen.dart';

class DeliveryManOrderHistoryWidget extends StatelessWidget {
  final Order orderModel;
  final int? index;
  const DeliveryManOrderHistoryWidget({super.key, required this.orderModel, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),

      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.125),blurRadius: 1, spreadRadius: 1, offset: const Offset(1,2))]
            ),
            child: Column( crossAxisAlignment: CrossAxisAlignment.start,children: [

              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.paddingSizeSmall), topRight: Radius.circular(Dimensions.paddingSizeSmall))
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 0),
                  child: Row(mainAxisAlignment : MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => OrderDetailsScreen (orderId: orderModel.id))),
                        child: Container(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha:.05),
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                        ),
                          child: Row(
                            children: [
                              Text('${getTranslated('order_no', context)}# ',
                                style: titilliumSemiBold.copyWith(color: Theme.of(context).primaryColor,fontSize: Dimensions.fontSizeLarge),),
                              Text('${orderModel.id} ${orderModel.orderType == 'POS'? '(POS)':''} ',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: (){
                          showDialog(context: context, builder: (_){
                            return OrderChangeLogWidget(orderId: orderModel.id);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Image.asset(Images.alarm, width: Dimensions.iconSizeSmall,height: Dimensions.iconSizeSmall,),
                          ),),
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen (orderId: orderModel.id))),
                child: Container(decoration: BoxDecoration(color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeSmall), bottomRight: Radius.circular(Dimensions.paddingSizeSmall))),
                  child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Column(children: [



                      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center, children: [
                          orderModel.createdAt != null?
                          Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(orderModel.createdAt!)),
                              style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)):const SizedBox(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(PriceConverter.convertPrice(context, orderModel.orderAmount ?? 0),
                              style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                          ),



                        ],),

                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Row( mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: Dimensions.iconSizeSmall, width: Dimensions.iconSizeSmall,

                                child: Image.asset(orderModel.orderStatus == 'pending'?
                                Images.orderPendingIcon:
                                orderModel.orderStatus == 'out_for_delivery'?
                                Images.outIcon:
                                orderModel.orderStatus == 'returned'?
                                Images.returnIcon:
                                orderModel.orderStatus == 'delivered'?
                                Images.deliveredIcon:
                                Images.confirmPurchase

                                )),

                              Padding(padding: const EdgeInsets.all(8.0),
                                child: Text(getTranslated(orderModel.orderStatus, context)!,
                                    style: robotoMedium.copyWith(
                                        color: orderModel.orderStatus == 'pending'?
                                        Theme.of(context).primaryColor:
                                        orderModel.orderStatus == 'out_for_delivery'?
                                        Colors.green:
                                        orderModel.orderStatus == 'returned'?
                                        Theme.of(context).primaryColor:
                                        orderModel.orderStatus == 'delivered'?
                                        Colors.green:
                                        Theme.of(context).colorScheme.error
                                    )),
                              ),
                            ],
                          ),
                          Row(children: [

                            Text( (orderModel.paymentMethod == 'pay_by_wallet' || orderModel.paymentMethod == 'cash_on_delivery')?
                            getTranslated(orderModel.paymentMethod, context)!: getTranslated('digital_payment', context)!,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            SizedBox(height: Dimensions.iconSizeDefault, width: Dimensions.iconSizeDefault,

                              child: CustomAssetImageWidget(orderModel.paymentMethod == 'cash_on_delivery'? Images.cashPaymentIcon:
                              orderModel.paymentMethod == 'pay_by_wallet'? Images.payByWalletIcon : Images.digitalPaymentIcon),),
                          ],),

                        ],),
                    ],),
                  ),),
              )
            ],),),
          const SizedBox(height: Dimensions.paddingSizeDefault),

        ],
      ),
    );
  }
}

