import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_drop_down_item_widget.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/order/widgets/delivery_man_assign_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/features/order_details/domain/models/order_setup_model.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class OrderSetupBottomSheet extends StatefulWidget {
  final Order? orderModel;
  final bool onlyDigital;
  final BuildContext bottomContext;
  const OrderSetupBottomSheet({super.key, this.orderModel, this.onlyDigital = false, required this.bottomContext});

  @override
  State<OrderSetupBottomSheet> createState() => _OrderSetupBottomSheetState();
}

class _OrderSetupBottomSheetState extends State<OrderSetupBottomSheet> {
  bool isSellerWiseShipping = false;
  bool inHouseShipping = false;
  final List<String> paymentTypeList = ['paid', 'unpaid'];

  void _clearAllTextField(DeliveryManController deliveryManController) {
    deliveryManController.deliveryManChargeTextEditingController.clear();
    deliveryManController.expectedDeliveryDateTextEditingController.clear();
    deliveryManController.thirdPartyShippingNameTextEditingController.clear();
    deliveryManController.thirdPartyShippingTrackingIdTextEditingController.clear();
  }

  @override
  void initState() {
    final DeliveryManController deliveryManController = Provider.of<DeliveryManController>(Get.context!, listen: false);
    deliveryManController.setDeliveryTypeIndex(_getIndexByDeliveryType(), false);
    deliveryManController.getDeliveryManList(widget.orderModel);
    _clearAllTextField(deliveryManController);

    isSellerWiseShipping = Provider.of<SplashController>(context,listen: false).configModel!.shippingMethod == 'sellerwise_shipping';
    _getShippingMethod();

    final OrderDetailsController orderDetailsController = Provider.of<OrderDetailsController>(Get.context!, listen: false);
    orderDetailsController.initializeOrderSetupModel(order: widget.orderModel);


    super.initState();
  }

  int _getIndexByDeliveryType() {
    return widget.orderModel?.deliveryType == 'by_self_delivery_man'
      ? 1 : widget.orderModel?.deliveryType == 'third_party_delivery' ? 2 : 0;
  }

  void _getShippingMethod() {
    String? shipping = Provider.of<SplashController>(context, listen: false).configModel?.shippingMethod;

    if(shipping == 'inhouse_shipping'
        && (widget.orderModel?.orderStatus == 'out_for_delivery'
        || widget.orderModel?.orderStatus == 'delivered'
        || widget.orderModel?.orderStatus == 'returned'
        || widget.orderModel?.orderStatus == 'failed'
        || widget.orderModel?.orderStatus == 'canceled')
    ){
      inHouseShipping = true;
    }else{
      inHouseShipping = false;
    }
  }


  @override
  Widget build(BuildContext context) {
  final double keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        InkWell(
          onTap: () => Navigator.pop(context),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.cancel_outlined,
              size: Dimensions.iconSizeMedium,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),

        Text(
          getTranslated('order_setup', context)!,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: Dimensions.paddingSizeMedium),

        Consumer<OrderDetailsController>(
          builder: (_, orderDetailsController, __) {
            bool paymentActive = _isPaymentActive(orderDetailsController);

            return Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: keyBoardHeight),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      inHouseShipping ?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeExtraSmall,
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeSmall,
                        ),
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(width: .5,color: Theme.of(context).hintColor.withValues(alpha:.125)),
                                color: Theme.of(context).hintColor.withValues(alpha:.12),
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.paddingSize),
                              child: Text(getTranslated(widget.orderModel!.orderStatus, context)!),
                            ),
                        ),
                      ) :
                      CustomDropDownItemWidget(
                        title: 'order_status',
                        widget: DropdownButtonFormField<String>(
                          initialValue: widget.orderModel!.orderStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(border: InputBorder.none),
                          iconSize: 24, elevation: 16, style: robotoRegular,
                          onChanged: widget.orderModel?.orderStatus == 'delivered' ? null :  (value){
                            orderDetailsController.orderSetupModel.orderStatus = value;
                          },
                          items: orderDetailsController.orderStatusList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(getTranslated(value, context)!,
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                            );
                          }).toList(),
                        ),
                      ),

                      CustomDropDownItemWidget(
                        title: 'payment_status',
                        widget: DropdownButtonFormField<String>(
                          initialValue: widget.orderModel!.paymentStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(border: InputBorder.none),
                          iconSize: 24, elevation: 16, style: robotoRegular,
                          onChanged: !paymentActive ? null : (value) {
                            orderDetailsController.setPaymentMethodIndex(value == 'paid' ? 0 : 1);
                            orderDetailsController.orderSetupModel.paymentStatus = value;
                          },
                          items: paymentTypeList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(getTranslated(value, context)!,
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                            );
                          }).toList(),
                        ),
                      ),

                      _deliverySetUpExist() ?
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: DeliveryManAssignWidget(
                          orderType: widget.orderModel?.orderType,
                          orderModel: widget.orderModel,
                          orderId: widget.orderModel!.id,
                        ),
                      ) : const SizedBox(),

                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        child: CustomButtonWidget(
                          btnTxt: getTranslated('update', context),
                          backgroundColor: Theme.of(context).primaryColor,
                          borderRadius: 8,
                          onTap: () async {
                            DeliveryManController deliveryManController = Provider.of<DeliveryManController>(context, listen: false);
                            _populateOrderSetUpModel(orderDetailsController.orderSetupModel, deliveryManController);

                            if(_canUpdate(orderDetailsController.orderSetupModel, widget.orderModel)){
                             await orderDetailsController.setUpOrder(orderSetupModel: orderDetailsController.orderSetupModel);

                              if (context.mounted) Navigator.pop(context);
                            }
                            else{
                              final deliveryManController = Provider.of<DeliveryManController>(context, listen: false);

                              if(deliveryManController.selectedDeliveryTypeIndex == 1 && deliveryManController.deliveryManIndex == 0){
                                showToast(message: getTranslated('please_select_delivery_man', context)!);
                                return false;
                              }
                              else if(deliveryManController.selectedDeliveryTypeIndex == 1
                                  && deliveryManController.deliveryManIndex != 0
                                  && deliveryManController.deliveryManChargeTextEditingController.text.isEmpty ){
                                showToast(message: getTranslated('please_enter_delivery_incentive', context)!);
                                return false;
                              }
                              else if(deliveryManController.selectedDeliveryTypeIndex == 2
                                  && deliveryManController.thirdPartyShippingNameTextEditingController.text.isEmpty){
                                showToast(message: getTranslated('please_enter_delivery_service_name', context)!);
                                return false;
                              }
                              else if(deliveryManController.selectedDeliveryTypeIndex == 2
                                  && deliveryManController.thirdPartyShippingTrackingIdTextEditingController.text.isEmpty) {
                                showToast(message: getTranslated('please_enter_tracking_id', context)!);
                                return false;
                              }
                              else{
                                showToast(message: getTranslated('there_is_no_change_to_update', context)!);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

          }
        ),
      ]),
    );
  }

  void showToast({Color backGroundColor = Colors.red, required String message}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: backGroundColor,
        textColor: Colors.white,
        fontSize: Dimensions.fontSizeDefault
    );
  }

  void _populateOrderSetUpModel(OrderSetupModel orderSetUpModel, DeliveryManController deliveryManController) {

    if(deliveryManController.deliveryManIndex != 0){
      orderSetUpModel.deliveryManId = deliveryManController.deliveryManIds[deliveryManController.deliveryManIndex!];
    }
    if(deliveryManController.deliveryManChargeTextEditingController.text.isNotEmpty){
      orderSetUpModel.deliveryManCharge = deliveryManController.deliveryManChargeTextEditingController.text;
    }
    if(deliveryManController.thirdPartyShippingNameTextEditingController.text.isNotEmpty){
      orderSetUpModel.thirdPartyDeliveryServiceName = deliveryManController.thirdPartyShippingNameTextEditingController.text;
    }
    if(deliveryManController.thirdPartyShippingTrackingIdTextEditingController.text.isNotEmpty){
      orderSetUpModel.thirdPartyDeliveryServiceTrackingId = deliveryManController.thirdPartyShippingTrackingIdTextEditingController.text;
    }
    if(deliveryManController.expectedDeliveryDateTextEditingController.text.isNotEmpty){
      orderSetUpModel.expectedDeliveryDate = deliveryManController.expectedDeliveryDateTextEditingController.text;
    }
    if(deliveryManController.selectedDeliveryTypeIndex != 0 ){
      orderSetUpModel.deliveryType = deliveryManController.selectedDeliveryTypeIndex == 1 ? 'by_self_delivery_man' : 'third_party_delivery';
    }
  }

  bool _canUpdate(OrderSetupModel orderSetUpModel, Order? order) {

    return order?.paymentStatus != orderSetUpModel.paymentStatus
        || order?.orderStatus != orderSetUpModel.orderStatus
        || order?.thirdPartyServiceName != orderSetUpModel.thirdPartyDeliveryServiceName
        || order?.thirdPartyTrackingId != orderSetUpModel.thirdPartyDeliveryServiceTrackingId
        || order?.deliveryManId != orderSetUpModel.deliveryManId
        || order?.deliverymanCharge?.toString() != orderSetUpModel.deliveryManCharge
        || order?.expectedDeliveryDate != orderSetUpModel.expectedDeliveryDate;
  }

  bool _isPaymentActive(OrderDetailsController orderDetailsController) {
    if(widget.orderModel?.paymentStatus == 'paid') return false;

    return true;
    // return orderDetailsController.orderDetails != null
    //     ? widget.orderModel?.paymentMethod == 'cash_on_delivery'
    //     ? (widget.orderModel?.paymentMethod == 'cash_on_delivery'
    //     && widget.orderModel?.orderStatus == 'delivered'
    //     && widget.orderModel?.paymentStatus != 'paid')
    //     : true : false;
  }

  bool _deliverySetUpExist() => isSellerWiseShipping && !widget.onlyDigital && widget.orderModel?.orderType != 'POS';

}
