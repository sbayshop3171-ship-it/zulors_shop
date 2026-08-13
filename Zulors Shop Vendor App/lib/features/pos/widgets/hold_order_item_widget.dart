import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_button_widget.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/hold_order_product_list_popup.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';

class HoldOrderItemWidget extends StatefulWidget {
  final TemporaryCartListModel customerCard;
  final int index;
  final bool formSearch;
  const HoldOrderItemWidget({super.key, required this.customerCard, required this.index, this.formSearch = false});

  @override
  State<HoldOrderItemWidget> createState() => _HoldOrderItemWidgetState();
}

class _HoldOrderItemWidgetState extends State<HoldOrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, cartController, _) {
        return Stack(
          children: [
            Positioned(
              top: 0, right: 0,
              child: InkWell(
                onTap: () {
                  cartController.removeCartItem(widget.index);
                },
                child: Padding(
                  padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Container(
                    height: 30, width: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Theme.of(context).cardColor),
                  ),
                ),
              )
            ),

            Padding(
              padding: EdgeInsets.only(
                top:  Dimensions.paddingSizeDefault,
                left: widget.formSearch ? 0 : Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).hintColor.withValues(alpha:0.15)
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSize),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: getTranslated('hold_Id', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault),
                            children: <TextSpan>[
                              TextSpan(text: widget.customerCard.userIndex.toString(), style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)),
                            ],
                          ),
                        ),
                      ),


                      Column(
                        children: [
                          Text(widget.customerCard.customerName ?? '',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)
                          ),

                          if(widget.customerCard.phoneNumber != 'NULL' && widget.customerCard.phoneNumber != '' && Provider.of<CartController>(context, listen: false).containsNumberExceptZero(widget.customerCard.phoneNumber ?? ''))...[
                            Text(widget.customerCard.phoneNumber ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ]
                        ],
                      )
                    ],
                    ),
                  ),
                  Divider(color: Theme.of(context).hintColor.withValues(alpha:0.50)),

                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSize),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return HoldOrderProductListPopup(cart: widget.customerCard.cart);
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: (widget.customerCard.cart?.length).toString(),
                              style: robotoBold.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeLarge,
                                  decoration: TextDecoration.underline
                              ),
                              children: <TextSpan>[
                                TextSpan(text: ' ${getTranslated('items', context)!}',
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Dimensions.fontSizeLarge,
                                    decoration: TextDecoration.underline
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),

                        SizedBox(
                          width: 90,
                          child: CustomButtonWidget(
                            btnTxt: getTranslated('resume', context)!,
                            onTap: () {
                              cartController.resumeHoldOrder(widget.customerCard, widget.index);
                              Provider.of<CartController>(context, listen: false).getTaxAmount();
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}
