import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/custom_image_widget.dart';
import 'package:zulors_shop/features/order/domain/models/order_model.dart';
import 'package:zulors_shop/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop/helper/date_converter.dart';
import 'package:zulors_shop/helper/price_converter.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/utill/custom_themes.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/utill/images.dart';
import 'package:provider/provider.dart';


class OrderWidget extends StatelessWidget {
  final Orders? orderModel;
  const OrderWidget({super.key, this.orderModel});

  @override
  Widget build(BuildContext context) {

    double orderAmount = 0;
    double tax = 0;

    if(orderModel?.orderType == 'POS') {
      double itemsPrice = 0;
      double discount = 0;
      double? eeDiscount = 0;

      double coupon = 0;
      double shipping = 0;
      if (orderModel?.details != null && orderModel!.details!.isNotEmpty ) {
        coupon = orderModel?.discountAmount ?? 0;
        shipping = orderModel?.shippingCost ?? 0;
        tax = orderModel?.totalTaxAmount ?? 0;

        for (var orderDetails in orderModel!.details!) {
          itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.qty!);
          discount = discount + orderDetails.discount!;
          // tax = tax + orderDetails.tax!;
        }
        if(orderModel!.orderType == 'POS'){
          if(orderModel!.extraDiscountType == 'percent'){
            eeDiscount = itemsPrice * (orderModel!.extraDiscount!/100);
          }else{
            eeDiscount = orderModel!.extraDiscount;
          }
        }
      }
      double subTotal = itemsPrice +tax - discount;

      orderAmount = subTotal + shipping - coupon - eeDiscount!;




      // double ? _extraDiscountAnount = 0;
      // if(orderModel.extraDiscount != null){
      //   _extraDiscountAnount = PriceConverter.convertWithDiscount(context, orderModel.totalProductPrice, orderModel.extraDiscount, orderModel.extraDiscountType == 'percent' ? 'percent' : 'amount' );
      //   if(_extraDiscountAnount != null) {
      //     double percentAmount = _extraDiscountAnount!;
      //     _extraDiscountAnount = orderModel.totalProductPrice! - percentAmount;
      //   }
      // }
      //
      // double totalDiscount = (_extraDiscountAnount! + orderModel.totalProductDiscount!);
      // double totalOrderAmount = (orderModel.totalProductPrice! + orderModel.totalTaxAmount!);
      //
      // orderAmount = totalOrderAmount - totalDiscount;
      //
      // orderAmount = orderModel.orderAmount! - orderModel.totalTaxAmount!;


    }



    return InkWell(
      onTap: () {
        RouterHelper.getOrderDetailsScreenRoute(
          action: RouteAction.push,
          orderId: orderModel!.id!,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                  image: orderModel?.sellerIs == 'admin'
                      ? Provider.of<SplashController>(context, listen: false).configModel ?.inHouseShop?.imageFullUrl?.path ?? ''
                      : '${orderModel?.seller?.shop?.imageFullUrl?.path}',
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${getTranslated('order', context)!} #${orderModel!.id}',
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _getStatusBgColor(context, orderModel!.orderStatus),
                        ),
                        child: Text(
                          getTranslated(orderModel!.orderStatus, context) ?? '',
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: _getStatusTextColor(context, orderModel!.orderStatus),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Text(
                    DateConverter.localDateToIsoStringAMPMOrder(DateTime.parse(orderModel!.createdAt!)),
                    style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.titleMedium?.color,),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.07) ,
                        ),
                        child: Text(
                          '${orderModel?.orderDetailsCount ?? 0} ${getTranslated('products', context)}',
                          style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.titleMedium?.color,),
                        ),
                      ),


                      Text(
                        PriceConverter.convertPrice(
                          context,
                          orderModel!.orderType == 'POS' ? orderAmount : orderModel!.orderAmount,
                        ),
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBgColor(BuildContext context, String? status) {
    switch (status) {
      case 'delivered':
      case 'confirmed':
        return Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: .1);
      case 'pending':
        return Theme.of(context).primaryColor.withValues(alpha: .1);
      case 'processing':
        return Theme.of(context).colorScheme.outline.withValues(alpha: .1);
      case 'canceled':
      case 'failed':
        return Theme.of(context).colorScheme.error.withValues(alpha: .1);
      default:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: .1);
    }
  }

  Color _getStatusTextColor(BuildContext context, String? status) {
    switch (status) {
      case 'delivered':
      case 'confirmed':
        return Theme.of(context).colorScheme.onTertiaryContainer;
      case 'pending':
        return Theme.of(context).primaryColor;
      case 'processing':
        return Theme.of(context).colorScheme.outline;
      case 'canceled':
      case 'failed':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }


}
