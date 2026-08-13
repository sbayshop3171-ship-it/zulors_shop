import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';


class OrderTopSectionWidget extends StatelessWidget {
  final Order? orderModel;
  final bool? fromNotification;
  const OrderTopSectionWidget({super.key, this.orderModel, this.fromNotification});

  @override
  Widget build(BuildContext context) {
    return orderModel != null?
    Stack(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
        child: Column(children: [

          Text('${getTranslated('order_no', context)}#${orderModel!.id} ${orderModel!.orderType == 'POS' ? '(POS)':''}',
            style: titilliumSemiBold.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                fontSize: Dimensions.fontSizeLarge),),

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${getTranslated('your_order_is', context)}',
                  style: titilliumSemiBold.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                      fontSize: Dimensions.fontSizeLarge)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                  child: Text(getTranslated('${orderModel!.orderStatus}', context)!,
                      style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).colorScheme.onTertiaryContainer)),
                ),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.only(left: 2,top: Dimensions.paddingSizeExtraSmall),
            child: Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(orderModel!.createdAt!)),
                style: robotoRegular.copyWith(color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
          ),
        ]),
      ),
      InkWell(onTap: () {
        if(fromNotification == true) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route)=> false);
        }else{
          Navigator.of(context).pop();
        }
        Provider.of<OrderDetailsController>(context, listen: false).emptyOrderDetails();
      },
        child: const Padding(padding: EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault),
          child: Icon(CupertinoIcons.back),
        ),
      )
    ],
    ): const SizedBox();
  }
}
