import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_loader_widget.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class OrderChangeLogWidget extends StatelessWidget {
  final int? orderId;
  const OrderChangeLogWidget({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    Provider.of<DeliveryManController>(context, listen: false).getDeliveryManOrderHistoryLogList(context, orderId);

    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall))),
      child: Consumer<DeliveryManController>(
          builder: (context, changelog,_) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!,
                    spreadRadius: 0.5, blurRadius: 0.3)],),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  Text('${getTranslated('history_of_order_no', context)} : $orderId',
                      style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  (changelog.changeLogList?.isNotEmpty ?? false) ?
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: changelog.changeLogList?.length,
                        itemBuilder: (context,index) {

                          return IntrinsicHeight(
                            child: Row(mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Expanded(flex: 2,
                                  child:Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Container(
                                      width: 30,height: 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      child: Icon(Icons.info_outline,size: Dimensions.iconSizeDefault, color: Theme.of(context).cardColor),
                                    ),
                                    index == (changelog.changeLogList?.length ?? 0) - 1 ? const SizedBox() :
                                    Expanded(child: Container(width: 2, color: Theme.of(context).primaryColor)),
                                  ]),
                                ),


                                Expanded(flex:6,
                                  child: Container(margin: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall,
                                      right: Dimensions.paddingSizeExtraSmall),

                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                      Text(getTranslated(changelog.changeLogList?[index].status, context)!,
                                          style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),


                                      Text(changelog.changeLogList?[index].userType ?? '',
                                          style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                                      Text(DateConverter.isoStringToDateTimeString(changelog.changeLogList?[index].createdAt ?? ''),
                                          style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),

                                    ]),
                                  ),
                                ),
                              ],
                            ),

                          );
                        }
                    ),
                  ) :
                  CustomLoaderWidget(height: MediaQuery.of(context).size.height / 2),
                ]),
              ),
            );
          }
      ),
    );
  }
}
