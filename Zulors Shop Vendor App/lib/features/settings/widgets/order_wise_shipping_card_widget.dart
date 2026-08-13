import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/shipping/domain/models/shipping_model.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/shipping/controllers/shipping_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:zulors_shop_vendor/features/settings/screens/order_wise_shipping_add_screen.dart';



class OrderWiseShippingCardWidget extends StatelessWidget {
  final ShippingController? shipProv;
  final ShippingModel? shippingModel;
  final int? index;
  const OrderWiseShippingCardWidget({super.key, this.shipProv, this.shippingModel, this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeMedium,0,Dimensions.paddingSizeMedium,Dimensions.paddingSizeSmall,),
      child: Container(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault,Dimensions.paddingSizeDefault,Dimensions.paddingSizeDefault,Dimensions.paddingSizeSmall,),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          boxShadow: ThemeShadow.getShadow(context),),
        child: Stack(
          children: [
            Column(children: [
              Row(children: [Expanded(child: Text('${index!+1}.  ${shippingModel!.title}',
                  maxLines: 1,overflow: TextOverflow.ellipsis,
                  style: robotoMedium.copyWith())),

                FlutterSwitch(value: shippingModel!.status == 1?true:false,
                  activeColor: Theme.of(context).primaryColor,
                  width: 48,height: 25,toggleSize: 20,padding: 2,
                  onToggle: (value){
                    shipProv!.shippingOnOff(context, shippingModel!.id, value?1:0, index);
                  },
                ),
                ],),



             Container(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
               child: Column(children: [
                 Row(
                 children: [
                   Text('${getTranslated('duration', context)}  :   ', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                   Text('${shippingModel!.duration}days', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),

                 ],
               ),
                 const SizedBox(height: Dimensions.paddingSizeSmall),
                 Row(
                 children: [
                   Text('${getTranslated('cost', context)}           :   ', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                   Text(PriceConverter.convertPrice(context, shippingModel!.cost),
                       style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                 ],
               ),
             ],),),

            ],
      ),
            Positioned(bottom: 10,right: 5,
              child: Row(children: [

                InkWell(
                    onTap: (){
                      showDialog(context: context, builder: (BuildContext context){
                        return ConfirmationDialogWidget(icon: Images.delete,
                            description: getTranslated('are_you_sure_want_to_delete_this_shipping_method', context),
                            onYesPressed: () {Provider.of<ShippingController>(context, listen:false).deleteShipping( shippingModel!.id);
                            }

                        );});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: ThemeShadow.getShadow(context),
                        borderRadius: BorderRadius.circular(100)
                      ),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Image.asset(Images.delete,  width: Dimensions.iconSizeMedium),
                        ))),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_)=>OrderWiseShippingAddScreen(shipping: shippingModel));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: ThemeShadow.getShadow(context),
                          borderRadius: BorderRadius.circular(100)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Image.asset(Images.editIcon, width: Dimensions.iconSizeMedium, color: Theme.of(context).primaryColor),
                      )),
                ),



              ],),
            )
          ],
        ),
    ),
    );
  }
}
