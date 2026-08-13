import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/order/enums/dleivery_type_enums.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/features/order/controllers/order_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_snackbar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/textfeild/custom_text_feild_widget.dart';

class DeliveryManAssignWidget extends StatefulWidget {
  final int? orderId;
  final String? orderType;
  final Order? orderModel;
  const DeliveryManAssignWidget({super.key, this.orderType, this.orderModel, this.orderId});

  @override
  State<DeliveryManAssignWidget> createState() => _DeliveryManAssignWidgetState();
}

class _DeliveryManAssignWidgetState extends State<DeliveryManAssignWidget> {


  final FocusNode _thirdPartyShippingNameNode = FocusNode();
  final FocusNode _thirdPartyShippingIdNode = FocusNode();
  String deliveryType = 'select delivery type';


  @override
  void initState() {
    final DeliveryManController deliveryManController = Provider.of<DeliveryManController>(context, listen: false);

    if(widget.orderModel!.deliverymanCharge != null){
      deliveryManController.deliveryManChargeTextEditingController.text = widget.orderModel!.deliverymanCharge!.toString();
    }
    if(widget.orderModel!.expectedDeliveryDate != null){
      deliveryManController.expectedDeliveryDateTextEditingController.text = widget.orderModel!.expectedDeliveryDate!;
    }

    if(widget.orderModel!.thirdPartyServiceName != null){
      deliveryManController.thirdPartyShippingNameTextEditingController.text = widget.orderModel!.thirdPartyServiceName!;
    }
    if(widget.orderModel!.thirdPartyTrackingId != null){
      deliveryManController.thirdPartyShippingTrackingIdTextEditingController.text = widget.orderModel!.thirdPartyTrackingId!;
    }
    if(widget.orderModel!.deliveryType != null){
      if(widget.orderModel!.deliveryType == getDeliveryType(DeliveryType.bySelfDeliveryMan)){
        Provider.of<DeliveryManController>(context, listen: false).setDeliveryTypeIndex(1, false);
      }else{
        Provider.of<DeliveryManController>(context, listen: false).setDeliveryTypeIndex(2, false);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<DeliveryManController>(
      builder: (context, deliverymanController, _) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Text(getTranslated('delivery_type', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          SizedBox(
            height: 45,
            child: Container(padding: const EdgeInsets.symmetric(horizontal:Dimensions.fontSizeExtraSmall),
                decoration: BoxDecoration(color: Theme.of(context).highlightColor,
                    border: Border.all(width: .5,color: Theme.of(context).hintColor.withValues(alpha:.5)),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                child: DropdownButton<String>(
                  value: deliverymanController.selectedDeliveryTypeIndex == 0
                      ? 'select_delivery_type'
                      : deliverymanController.selectedDeliveryTypeIndex == 1
                      ? 'by_self_delivery_man'
                      : 'by_third_party_delivery_service',
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: widget.orderModel?.orderStatus == 'delivered' ? null : (String? newValue) {
                    deliverymanController.setDeliveryTypeIndex(newValue == 'select_delivery_type' ? 0 : newValue == 'by_self_delivery_man' ? 1 : 2, true);
                  },
                  items: deliverymanController.deliveryTypeList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(getTranslated(value, context)!),
                    );
                  }).toList(),
                )
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          deliverymanController.selectedDeliveryTypeIndex == 1 ?
          Padding(padding: const EdgeInsets.only(bottom: 20.0),
            child: widget.orderType == 'POS' ? const SizedBox() : Consumer<DeliveryManController>(builder: (context, deliveryMan, child) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(getTranslated('deliveryman', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Row(children: [Expanded(child: Container(
                    padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,),
                    decoration: BoxDecoration(color: Theme.of(context).highlightColor,
                      border: Border.all(width: .5, color: Theme.of(context).hintColor.withValues(alpha:.5)),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),),
                    alignment: Alignment.center,
                    child: DropdownButtonFormField<int>(
                      initialValue: deliveryMan.deliveryManIndex,
                      isExpanded: true,
                      decoration: const InputDecoration(border: InputBorder.none),
                      iconSize: 24, elevation: 16, style: titilliumRegular,
                      items: deliveryMan.deliveryManIds.map((int? value) {
                        return DropdownMenuItem<int>(
                          value: deliveryMan.deliveryManIds.indexOf(value),
                          child: Text(value != 0 ?
                          '${deliveryMan.deliveryManList![(deliveryMan.deliveryManIds.indexOf(value) - 1)].fName} '
                              '${deliveryMan.deliveryManList![(deliveryMan.deliveryManIds.indexOf(value) - 1)].lName}' :
                          getTranslated('select_delivery_man', context)!,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        );
                      }).toList(),
                      onChanged: widget.orderModel?.orderStatus == 'delivered' ? null : (int? value) {
                        if(widget.orderModel?.orderStatus == 'delivered'){
                          showCustomSnackBarWidget(getTranslated('order_is_delivered_you_cant_change_delivery_man', context)!, context, sanckBarType: SnackBarType.warning );
                        }else{
                          deliveryMan.setDeliverymanIndex(value, true);
                        }
                      },
                    ),
                  ))]),




                  if(deliveryMan.deliveryManIndex != 0)...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(getTranslated('additional_delivery_man_fee', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: CustomTextFieldWidget(
                        hintText: getTranslated('delivery_man_charge', context),
                        idDate: widget.orderModel?.orderStatus == 'delivered' || deliveryMan.deliveryManIndex == 0,
                        border: true,
                        controller: deliveryMan.deliveryManChargeTextEditingController,
                        isAmount: true,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(getTranslated('expected_delivery_date', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color) ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Consumer<OrderController>(
                      builder: (context, orderProvider, _) {
                        return GestureDetector(
                          onTap : deliveryMan.deliveryManIndex == 0 ? null : () {
                            DateTime ? parsedDate;

                            if(deliveryMan.expectedDeliveryDateTextEditingController.text != '') {
                              parsedDate = DateTime.parse(deliveryMan.expectedDeliveryDateTextEditingController.text);
                            }

                            orderProvider.selectDate(context, dateTime: parsedDate).then((value) async {
                              Future.delayed(const Duration(seconds: 1));
                              String expectedDate = orderProvider.startDate != null  ?
                              orderProvider.dateFormat.format(orderProvider.startDate!) : widget.orderModel!.expectedDeliveryDate != null ?
                              widget.orderModel!.expectedDeliveryDate! : '';

                              deliveryMan.expectedDeliveryDateTextEditingController.text = expectedDate;
                            });
                          },
                          child: AbsorbPointer(
                            child: CustomTextFieldWidget(
                              hintText: widget.orderModel!.expectedDeliveryDate ?? getTranslated('expected_delivery_date', context),
                              border: true,
                              controller: deliveryMan.expectedDeliveryDateTextEditingController,
                              idDate: false,
                              suffixIconImage: Images.calenderIcon,
                              readOnly: true,
                            ),
                          ),
                        );
                      }
                    ),

                  ],

                ],
              );
            }),
          ) :
          deliverymanController.selectedDeliveryTypeIndex == 2 ?
          Padding(padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(getTranslated('third_party_delivery_service', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                border: true,
                hintText: 'Ex: xyz service',
                idDate : widget.orderModel?.orderStatus == 'delivered',
                controller: deliverymanController.thirdPartyShippingNameTextEditingController,
                focusNode: _thirdPartyShippingNameNode,
                nextNode: _thirdPartyShippingIdNode,
                textInputAction: TextInputAction.next,
                textInputType: TextInputType.name,
                isAmount: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),


              Text(getTranslated('third_party_delivery_tracking_id', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextFieldWidget(
                hintText: 'Ex: xyz-12345678',
                border: true,
                idDate : widget.orderModel?.orderStatus == 'delivered',
                controller: deliverymanController.thirdPartyShippingTrackingIdTextEditingController,
                focusNode: _thirdPartyShippingIdNode,
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.text,
                isAmount: false,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),


            ]),
          ) : const SizedBox(),
        ]);
      }
    );
  }
}
