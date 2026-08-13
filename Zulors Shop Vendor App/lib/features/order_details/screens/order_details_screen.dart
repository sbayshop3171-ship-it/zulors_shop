import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/change_amount_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/order_details_shimmer.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/order_setup_bottom_sheet.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/features/order/controllers/order_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_divider_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/image_diaglog_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/customer_contact_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/delivery_man_information_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/order_product_list_item_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/order_top_section_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/payment_status_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/shipping_and_biilling_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/third_party_delivery_info_widget.dart';


class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final bool fromNotification;
  const OrderDetailsScreen({super.key,  required this.orderId, this.fromNotification = false});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _loadData(BuildContext context) async {
    if(widget.fromNotification && Provider.of<SplashController>(Get.context!, listen: false).configModel == null) {
      await Provider.of<SplashController>(Get.context!, listen: false).initConfig();
    }
    Provider.of<OrderDetailsController>(Get.context!, listen: false).getOrderDetails(widget.orderId.toString());
    Provider.of<OrderDetailsController>(Get.context!, listen: false).initOrderStatusList(
      Provider.of<SplashController>(Get.context!, listen: false).configModel!.shippingMethod == 'inhouse_shipping' ?  'inhouse_shipping' : "seller_wise"
    );
  }


  bool _onlyDigital = true;

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        Provider.of<OrderDetailsController>(context, listen: false).emptyOrderDetails();
        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route)=> false);
        } else {
          return;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(elevation: 1,
          backgroundColor: Theme.of(context).cardColor, toolbarHeight: 120,
          leadingWidth: 0, automaticallyImplyLeading: false,
          surfaceTintColor: Theme.of(context).highlightColor,
          title: Consumer<OrderDetailsController>(
            builder: (context, orderDetailsController,_) {
              return OrderTopSectionWidget(orderModel: orderDetailsController.orderDetails?[0].order, fromNotification: widget.fromNotification);
            }
          ),
        ),

        body: RefreshIndicator(
          onRefresh: () async => _loadData(context),
          child: Consumer<OrderController>(
            builder:(context, orderController, child){
              return Consumer<OrderDetailsController>(
                builder: (context, orderDetailsController, child) {
                  double itemsPrice = 0;
                  double discount = 0;
                  double? eeDiscount = 0;
                  double tax = 0;
                  double coupon = 0;
                  double shipping = 0;
                  double referAndEarnDiscount = 0;
                  bool isFreeShipping = false;

                  if (orderDetailsController.orderDetails != null && orderDetailsController.orderDetails!.isNotEmpty) {
                    coupon = orderDetailsController.orderDetails![0].order!.discountAmount!;
                    shipping = orderDetailsController.orderDetails![0].order!.shippingCost!;
                    isFreeShipping = orderDetailsController.orderDetails?[0].order?.isShippingFree ?? false;
                    for (var orderDetails in orderDetailsController.orderDetails!) {
                      if(orderDetails.productDetails?.productType == "physical") {
                        _onlyDigital =  false;
                      }
                      itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.qty!);
                      discount = discount + orderDetails.discount!;
                    }
                    tax = orderDetailsController.orderDetails![0].order?.totalTaxAmount ?? 0;

                    if(orderDetailsController.orderDetails![0].order!.orderType == 'POS') {
                      if(orderDetailsController.orderDetails![0].order!.extraDiscountType == 'percent') {
                        eeDiscount = (itemsPrice - coupon - discount) * (orderDetailsController.orderDetails![0].order!.extraDiscount!/100);
                      }else{
                        eeDiscount = orderDetailsController.orderDetails![0].order!.extraDiscount;
                      }
                    }

                    if(orderDetailsController.orderDetails != null && orderDetailsController.orderDetails![0].order!.orderType != 'POS') {
                      referAndEarnDiscount = orderDetailsController.orderDetails?[0].order?.referAndEarnDiscount ?? 0;
                    }

                  }
                  double subTotal = itemsPrice + tax - discount;

                  double totalPrice = subTotal + (isFreeShipping ? 0 : shipping) - coupon - eeDiscount! - referAndEarnDiscount;

                  return orderDetailsController.orderDetails != null ? orderDetailsController.orderDetails!.isNotEmpty ?
                  CustomScrollView(slivers: [
                    SliverToBoxAdapter(child: Column(children: [
                      Container(height: 10, color: Theme.of(context).primaryColor.withValues(alpha:.1)),

                      Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: ThemeShadow.getShadow(context)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

                          if(Provider.of<SplashController>(context, listen: false).configModel?.orderVerification == 1 &&  orderDetailsController.orderDetails![0].order!.orderType != 'POS')
                            Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                              child: Center(child: Text.rich(TextSpan(children: [
                                TextSpan(text: '${getTranslated('order_verification_code', context)} : ', style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                                TextSpan(text: orderDetailsController.orderDetails![0].order?.verificationCode??'', style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                              ])),),
                            ),

                          orderDetailsController.orderDetails![0].order!.orderType == 'POS' ? const SizedBox():
                          ShippingAndBillingWidget(orderModel: orderDetailsController.orderDetails![0].order!, onlyDigital: _onlyDigital, orderType: orderDetailsController.orderDetails![0].order!.orderType!),

                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            Container(padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault,
                                Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),

                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  SizedBox(width: 15, child: Image.asset(Images.orderSummery)),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(getTranslated('order_summery', context)!,
                                    style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault,),

                                ListView.builder(
                                  padding: const EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: orderDetailsController.orderDetails!.length,
                                  itemBuilder: (context, index) {
                                    return OrderedProductListItemWidget(orderDetailsModel: orderDetailsController.orderDetails![index],
                                      paymentStatus: orderController.paymentStatus,orderId: widget.orderId,
                                      index: index, length: orderDetailsController.orderDetails!.length,
                                    );
                                  },
                                ),
                              ],
                              ),),

                            orderDetailsController.orderDetails![0].order!.orderNote != null?
                            Container(decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withValues(alpha:.25),spreadRadius: .11,blurRadius: .11, offset: const Offset(0,2))],
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeSmall),
                                    bottomRight: Radius.circular(Dimensions.paddingSizeSmall))),
                              child: Container(decoration: BoxDecoration(
                                color: Theme.of(context).hintColor.withValues(alpha:.07),
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(Dimensions.paddingSizeSmall),
                                    bottomRight: Radius.circular(Dimensions.paddingSizeSmall)),),
                                padding: const EdgeInsets.fromLTRB( Dimensions.paddingSizeDefault,Dimensions.paddingSizeDefault,Dimensions.paddingSizeDefault,
                                    Dimensions.paddingSizeDefault),

                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                                  Row(children: [
                                    Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                      child: Image.asset(Images.orderNote,color: Theme.of(context).textTheme.bodyLarge?.color, width: Dimensions.iconSizeSmall ),),
                                    Text(getTranslated('order_note', context)!, style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                                      color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),)),
                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text(orderDetailsController.orderDetails![0].order!.orderNote != null? orderDetailsController.orderDetails![0].order!.orderNote ?? '': "",
                                      style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                ]),
                              ),
                            ):const SizedBox(),


                            Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,
                                vertical: Dimensions.paddingSizeDefault),
                              child: Column(children: [

                                // Total
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('sub_total', context)!,
                                    style: titilliumRegular.copyWith(
                                    color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),

                                  Text(PriceConverter.convertPrice(context, itemsPrice),
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),


                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('tax', context)!,
                                    style: titilliumRegular.copyWith(
                                    color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))
                                  ),

                                  Text(' + ${PriceConverter.convertPrice(context, tax)}',
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),]),
                                const SizedBox(height: Dimensions.paddingSizeSmall,),


                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('discount', context)!,
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),


                                  Text('- ${PriceConverter.convertPrice(context, discount)}',
                                      style: titilliumRegular.copyWith(
                                        color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                                      )),]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),


                                if(referAndEarnDiscount > 0)
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('referral_discount', context)!,
                                    style: titilliumRegular.copyWith(
                                    color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))
                                  ),

                                  Text('- ${PriceConverter.convertPrice(context, referAndEarnDiscount)}',
                                    style: titilliumRegular.copyWith(
                                      color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                                    )),
                                ]),

                                if(referAndEarnDiscount > 0)
                                const SizedBox(height: Dimensions.paddingSizeSmall,),


                                orderDetailsController.orderDetails![0].order!.orderType == "POS"?
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('extra_discount', context)!,
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                  Text('- ${PriceConverter.convertPrice(context, eeDiscount)}',
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                ]):const SizedBox(),
                                SizedBox(height:  orderDetailsController.orderDetails![0].order!.orderType == "POS"? Dimensions.paddingSizeSmall: 0),


                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('coupon_discount', context)!,
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                  Text('- ${PriceConverter.convertPrice(context, coupon)}',
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),]),
                                const SizedBox(height: Dimensions.paddingSizeSmall,),


                                if(!_onlyDigital)Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('shipping_fee', context)! + _shippingFreeText(orderDetailsController.orderDetails![0].order),
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                  Text('${(isFreeShipping) ? '' : '+'} ${PriceConverter.convertPrice(context, shipping)}',
                                      style: titilliumRegular.copyWith(
                                          color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),]),

                                const Padding(padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                    child: CustomDividerWidget()),


                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(getTranslated('total_amount', context)!,
                                    style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)
                                  ),
                                  Text(PriceConverter.convertPrice(context, totalPrice),
                                    style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge,
                                    color: Theme.of(context).primaryColor),
                                  ),
                                ]),

                                if (orderDetailsController.orderDetails![0].order!.orderType == 'POS')
                                  Column(
                                    children: [
                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Text(getTranslated('paid_amount', context)!,
                                            style: titilliumRegular.copyWith(
                                                color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                        Text(PriceConverter.convertPrice(context, orderDetailsController.orderDetails![0].order!.paidAmount),
                                            style: titilliumRegular.copyWith(
                                                color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),]
                                      ),
                                      const SizedBox(height: Dimensions.paddingSizeSmall),

                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Text(getTranslated('change_amount', context)!,
                                            style: titilliumRegular.copyWith(
                                                color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),
                                        Text(PriceConverter.convertPrice(context, orderDetailsController.orderDetails![0].order!.paidAmount! - double.parse(totalPrice.toStringAsFixed(2))),
                                            style: titilliumRegular.copyWith(
                                                color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))),]
                                      ),
                                     // const SizedBox(height: Dimensions.paddingSizeSmall),
                                    ],
                                  ),
                              ],),),
                          ]),


                          PaymentStatusWidget(order: orderController, orderModel: orderDetailsController.orderDetails![0].order!),

                          ChangeAmountWidget(
                            amount: orderDetailsController.orderDetails![0].order?.bringCashAmount ?? 0,
                            currency: orderDetailsController.orderDetails![0].order?.bringChangeAmountCurrency ?? '',
                          ),

                          CustomerContactWidget(orderModel: orderDetailsController.orderDetails![0].order),

                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                          orderDetailsController.orderDetails![0].order!.deliveryMan != null?
                          Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            child: DeliveryManContactInformationWidget(orderModel: orderDetailsController.orderDetails![0].order, orderType: orderDetailsController.orderDetails![0].order!.orderType, onlyDigital: _onlyDigital),
                          ):const SizedBox(),

                          orderDetailsController.orderDetails![0].order!.thirdPartyServiceName != null?
                          Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            child: ThirdPartyDeliveryInfoWidget(orderModel: orderDetailsController.orderDetails![0].order),
                          ):const SizedBox.shrink(),

                          if(orderDetailsController.orderDetails != null && orderDetailsController.orderDetails![0].verificationImages != null && orderDetailsController.orderDetails![0].verificationImages!.isNotEmpty)
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,  Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall),
                                child: Text('${getTranslated('completed_service_picture', context)}',
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),),),

                              SizedBox(height: 120,
                                child: ListView.builder(
                                    itemCount: orderDetailsController.orderDetails![0].verificationImages?.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index){

                                      return InkWell(onTap: () => showDialog(context: context, builder: (_)=> ImageDialogWidget(imageUrl: '${orderDetailsController.orderDetails![0].verificationImages?[index].imageFullUrl?.path}')),
                                        child: Padding(padding:  EdgeInsets.only(left: Dimensions.paddingSizeSmall,
                                            right: orderDetailsController.orderDetails![0].verificationImages!.length == index+1? Dimensions.paddingSizeSmall : 0),
                                          child: SizedBox(width: 200,
                                            child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                              child: Container(decoration: BoxDecoration(
                                                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha:.25), width: .25),
                                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
                                                  child: CustomImageWidget(image: '${orderDetailsController.orderDetails![0].verificationImages?[index].imageFullUrl?.path}')),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                            ),



                        ])),

                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                    ))
                  ],
                  ) : const NoDataScreen() :
                  const OrderDetailsShimmer();
                }
              );
            }
          ),
        ),

        bottomNavigationBar: Consumer<OrderDetailsController>(builder: (_, orderDetailsController, __) {

          if(orderDetailsController.orderDetails?.isEmpty ?? true) return const SizedBox();

          return orderDetailsController.orderDetails?[0].order?.orderType == 'POS'  ? const SizedBox() : Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: ThemeShadow.getShadow(context)),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
            child: CustomButtonWidget(
              backgroundColor: (orderDetailsController.orderDetails == null ) ? Theme.of(context).hintColor : Theme.of(context).primaryColor,
              borderRadius: Dimensions.paddingSizeExtraSmall,
              btnTxt: getTranslated('order_setup', context),
              onTap: (orderDetailsController.orderDetails == null ) ? null : () {

                showModalBottomSheet(
                  backgroundColor: Theme.of(context).cardColor,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context){

                    return OrderSetupBottomSheet(
                      orderModel: orderDetailsController.orderDetails?[0].order,
                      onlyDigital: _onlyDigital,
                      bottomContext: context,
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }


  String _shippingFreeText(Order? order) {
    if((order?.isShippingFree ?? false) && order?.shippingResponsibility == 'inhouse_shipping') {
      return ' (${getTranslated('expense_bearer_admin', context)})';
    } else if ((order?.isShippingFree ?? false) && order?.shippingResponsibility == 'sellerwise_shipping' ) {
      return ' (${getTranslated('expense_bearer_vendor', context)})';
    }
    return '';
  }

}
