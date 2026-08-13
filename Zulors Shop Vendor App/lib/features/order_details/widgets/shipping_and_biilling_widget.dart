import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/order/domain/models/order_model.dart';
import 'package:zulors_shop_vendor/features/order_details/controllers/order_details_controller.dart';
import 'package:zulors_shop_vendor/features/splash/controllers/splash_controller.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/order/screens/edit_address_screen.dart';
import 'package:zulors_shop_vendor/features/order/widgets/icon_with_text_row_widget.dart';
import 'package:zulors_shop_vendor/features/order_details/widgets/show_on_map_dialog_widget.dart';

class ShippingAndBillingWidget extends StatelessWidget {
  final Order? orderModel;
  final bool? onlyDigital;
  final String orderType;
  const ShippingAndBillingWidget({super.key, this.orderModel, this.onlyDigital, required this.orderType});

  @override
  Widget build(BuildContext context) {
    bool showEditButton = (orderModel?.orderStatus == 'out_for_delivery' || orderModel?.orderStatus == 'delivered' || orderModel?.orderStatus == 'returned');

    return Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(Images.mapBg), fit: BoxFit.cover)),
      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if(!onlyDigital!)Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall).copyWith(bottom: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: ThemeShadow.getShadow(context),
              borderRadius: BorderRadius.vertical(
                top : Radius.circular(Dimensions.paddingSizeSmall),
                bottom: (orderModel!.billingAddressData == null) ? Radius.circular(Dimensions.paddingSizeSmall) : Radius.circular(0) ,
              )
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                Row(children: [
                  SizedBox(width: 20, child: Image.asset(Images.shippingIcon)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                      child: Text('${getTranslated('address_info', context)}'))
                ]),

                orderType != 'POS' || !onlyDigital!?
                Provider.of<SplashController>(context, listen: false).configModel!.mapApiStatus == 1 ?
                Consumer<OrderDetailsController>(
                  builder:  (context, resProvider, child) {
                    return GestureDetector(onTap: (){
                      showDialog(context: context, builder: (_) {
                        BillingAddressData billingAddressData = resProvider.getAddressForMap(orderModel!.shippingAddressData!, orderModel!.billingAddressData);
                        Provider.of<OrderDetailsController>(context, listen: false).setMarker(billingAddressData);
                        return  ShowOnMapDialogWidget(billingAddressData: billingAddressData);
                      });
                    },
                      child: Row(children: [
                        Text('${getTranslated('show_on_map', context)}', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Image.asset(Images.showOnMap, width: Dimensions.iconSizeDefault)),
                      ]),
                    );
                  }
                ) : const SizedBox() : const SizedBox(),
              ]),
              Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.30), thickness: 1),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('shipping_address', context) ?? '', style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                )),

                !showEditButton ?
                InkWell(onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>
                      EditAddressScreen(isBilling: false,
                        orderId: orderModel?.id.toString(),
                        address: orderModel!.shippingAddressData?.address,
                        city: orderModel!.shippingAddressData?.city,
                        zip: orderModel!.shippingAddressData?.zip,
                        name: orderModel!.shippingAddressData?.contactPersonName,
                        number: orderModel!.shippingAddressData?.phone,
                        email: orderModel!.shippingAddressData?.email,
                        lat: orderModel!.shippingAddressData?.latitude??'0',
                        lng: orderModel!.shippingAddressData?.longitude??'0',
                      )));
                },
                    child: SizedBox(width: 20, child: Image.asset(Images.edit,color: Theme.of(context).primaryColor,))) : const SizedBox(),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if(orderModel!.shippingAddressData != null)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.contactPersonName ?? '', icon: Icons.person)),

                  Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.phone ?? '', icon: Icons.call)),
                ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.addressType ?? '', icon: Icons.home)),

                Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.country ?? '', icon: Icons.flag)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.city ?? '', icon: Icons.location_city)),

                Expanded(child: IconWithTextRowWidget(text: orderModel!.shippingAddressData?.zip ?? '', icon: Icons.keyboard)),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if(orderModel!.shippingAddressData != null && orderModel!.shippingAddressData?.email != null)
                IconWithTextRowWidget(text: '${orderModel!.shippingAddressData?.email}',icon: Icons.email),

              if(orderModel!.shippingAddressData != null && orderModel!.shippingAddressData?.email != null)
                const SizedBox(height: Dimensions.paddingSizeSmall),

              IconWithTextRowWidget(
                  text: orderModel!.shippingAddressData?.address ?? '',
                  icon: Icons.location_on,
                  textColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
              ),
              if(orderModel!.billingAddressData != null ||!isBillingSameAsShipping())
              Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.30), thickness: 1),

              if(orderModel!.billingAddressData == null ||isBillingSameAsShipping())
              SizedBox(height: Dimensions.paddingSizeSmall),

            ]),
          ),


          if(orderModel!.billingAddressData != null || !isBillingSameAsShipping())
          Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium).copyWith(top: 0),
            decoration: BoxDecoration(color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(
                  bottom : Radius.circular(Dimensions.paddingSizeSmall),
                  top: (onlyDigital ?? false) ? Radius.circular(Dimensions.paddingSizeSmall) : Radius.circular(0),
                )),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if(onlyDigital ?? false)
                SizedBox(height: Dimensions.paddingSizeSmall),
              if(orderModel!.billingAddressData != null || !isBillingSameAsShipping())
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('billing_address', context)!, style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
                )),

                (orderModel!.billingAddressData != null && !showEditButton) ?
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>
                        EditAddressScreen(isBilling: true,
                          orderId: orderModel?.id.toString(),
                          address: orderModel!.billingAddressData?.address??'',
                          city: orderModel!.billingAddressData?.city??'',
                          zip: orderModel!.billingAddressData?.zip??'',
                          name: orderModel!.billingAddressData?.contactPersonName??'',
                          email: orderModel!.billingAddressData?.email??'',
                          number: orderModel!.billingAddressData?.phone??'',
                          lat: orderModel!.billingAddressData?.latitude??'0',
                          lng: orderModel!.billingAddressData?.longitude??'0',
                        )));
                  },
                  child: SizedBox(width: 20, child: Image.asset(Images.edit,color: Theme.of(context).primaryColor,)),
                ) : const SizedBox(),
              ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),


              if(!isBillingSameAsShipping())
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye, vertical: Dimensions.paddingSizeExtraSmall),
                  child: Text(getTranslated('same_as_shipping_address', context)!, style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeSmall,
                  )),
                )
              else ...[
                if(orderModel!.billingAddressData != null)
                Row(children: [
                 Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData != null ?
                 orderModel!.billingAddressData?.contactPersonName?.trim()??''  : '',icon: Icons.person)),


                  Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData != null ?
                  orderModel!.billingAddressData?.phone?.trim()??''  : '',icon: Icons.call)),
                ]),
                if(orderModel!.billingAddressData != null)
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(orderModel!.billingAddressData != null)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.addressType ?? '', icon: Icons.home)),

                  Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.country ?? '', icon: Icons.flag)),
                ]),
                if(orderModel!.billingAddressData != null)
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(orderModel!.billingAddressData != null)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.city ?? '', icon: Icons.location_city)),

                  Expanded(child: IconWithTextRowWidget(text: orderModel!.billingAddressData?.zip ?? '', icon: Icons.keyboard)),
                ]),
                if(orderModel!.billingAddressData != null)
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(orderModel!.billingAddressData != null)
                if(orderModel!.billingAddressData?.email != null)
                  IconWithTextRowWidget(text: orderModel!.billingAddressData?.email?? '' ,icon: Icons.email),

                if(orderModel!.billingAddressData != null)
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                if(orderModel!.billingAddressData != null)
                IconWithTextRowWidget(
                  text: orderModel!.billingAddressData != null
                      ? orderModel!.billingAddressData?.address?.trim() ?? ''
                      : '', icon: Icons.location_on,
                  textColor: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.80),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  bool isBillingSameAsShipping() {
    return orderModel?.shippingAddressData?.contactPersonName != orderModel?.billingAddressData?.contactPersonName ||
      orderModel?.shippingAddressData?.phone != orderModel?.billingAddressData?.phone ||
      orderModel?.shippingAddressData?.addressType != orderModel?.billingAddressData?.addressType ||
      orderModel?.shippingAddressData?.country != orderModel?.billingAddressData?.country ||
      orderModel?.shippingAddressData?.city != orderModel?.billingAddressData?.city ||
      orderModel?.shippingAddressData?.zip != orderModel?.billingAddressData?.zip ||
      orderModel?.shippingAddressData?.email != orderModel?.billingAddressData?.email ||
      orderModel?.shippingAddressData?.address != orderModel?.billingAddressData?.address;
  }
}
