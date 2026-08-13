import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_asset_image_widget.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_attachment_list_widget.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/images.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_image_widget.dart';
import 'package:zulors_shop_vendor/features/refund/screens/refund_details_screen.dart';

class RefundWidget extends StatelessWidget {
  final RefundModel? refundModel;
  final bool isDetails;
  final bool isLast;
  const RefundWidget({super.key, required this.refundModel, this.isDetails = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDetails ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => RefundDetailsScreen(
          refundModel: refundModel, orderDetailsId: refundModel!.orderDetailsId,
          variation: refundModel!.orderDetails!.variant))),
      child: Padding(
        padding: isDetails ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          if(!isDetails)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeMedium),
              child: Text(DateConverter.isoStringToLocalDateAndTime(refundModel!.createdAt!), style: robotoRegular.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
              )),
            ),

          Container(
            decoration: !isDetails ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: isDetails ? BorderRadius.zero : BorderRadius.circular(Dimensions.paddingSizeSmall),
              boxShadow: [BoxShadow(
                color: Provider.of<ThemeController>(context, listen: false).darkTheme
                    ? Theme.of(context).primaryColor.withValues(alpha:0)
                    : Theme.of(context).hintColor.withValues(alpha:.25),
                blurRadius: 2,
                spreadRadius: 2,
                offset: const Offset(1,2),
              )],
            ) : null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
              if(!isDetails)
                Padding(padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,0),
                  child: Row(children: [
                    Text('${getTranslated('order_no', context)}# ', style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color
                    )),

                    Text(' ${refundModel!.orderId.toString()}', style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color
                    )),
                  ]),
                ),

              Padding(padding:  EdgeInsets.only(top : isDetails ? 10 : 0),
                child: Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  decoration: isDetails ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 7,
                    )]
                  ) : null,
                  padding: EdgeInsets.symmetric(horizontal: isDetails ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeOrder, vertical: Dimensions.paddingSizeSmall),
                  child: refundModel != null ?
                  Row(crossAxisAlignment: CrossAxisAlignment.start,children: [

                    refundModel!.product == null ?
                    Expanded(
                      child: Text(getTranslated('product_not_found', context) ?? '', style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.displayLarge?.color
                      ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ) : const SizedBox(),

                    refundModel!.product != null ?
                    Container(
                      width: Dimensions.stockOutImageSize,
                      height: Dimensions.stockOutImageSize,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraSmall))),
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraSmall),),
                          child: CustomImageWidget(image: '${refundModel!.product!.thumbnailFullUrl?.path}')
                      ) ,
                    ) : const SizedBox(),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

                      refundModel!.product != null ?
                      Text(refundModel!.product!.name.toString(), style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color
                      ), maxLines: 1, overflow: TextOverflow.ellipsis) : const SizedBox(),


                      refundModel!.product != null ?
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                        child: Text(PriceConverter.convertPrice(context, refundModel!.product?.unitPrice), style: robotoMedium.copyWith(
                            color: Provider.of<ThemeController>(context, listen: false).darkTheme ? Colors.white :
                            Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge
                        )),
                      ) : const SizedBox(),

                      /// Refund status
                      Container(
                        decoration: BoxDecoration(
                          color: refundModel!.status?.toLowerCase() == 'pending'
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                              : (refundModel?.status?.toLowerCase() == 'approved' || refundModel?.status?.toLowerCase() == 'refunded')
                              ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeOrder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeVeryTiny),
                        child: Text(getTranslated(refundModel!.status, context)!,
                            style: robotoRegular.copyWith(color: refundModel!.status?.toLowerCase() == 'pending'?
                            Theme.of(context).primaryColor : (refundModel!.status?.toLowerCase() == 'approved' || refundModel!.status?.toLowerCase() == 'refunded')?
                            Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      if(isDetails)
                        Row(children: [
                          SizedBox(
                            height: Dimensions.iconSizeMedium,
                            width: Dimensions.iconSizeMedium,
                            child: CustomAssetImageWidget(refundModel!.paymentInfo == 'cash_on_delivery' ? Images.cashPaymentIcon :
                            refundModel!.paymentInfo == 'pay_by_wallet' ? Images.payByWalletIcon : Images.digitalPaymentIcon),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Text(refundModel!.order != null ? getTranslated(refundModel!.order!.paymentMethod, context) ?? '' : '', style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.60),
                          )),
                        ]),
                    ])),
                  ]) : const SizedBox(),
                ),
              ),

              isDetails ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              isDetails ?
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.fontSizeDefault),
                padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSize, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    boxShadow: [BoxShadow(
                      blurRadius: 7,
                      offset: const Offset(0, 1),
                      color: Colors.black.withValues(alpha: 0.1),
                    )]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeVeryTiny),
                      child: Row(children: [
                        Image.asset(Images.reason, height: Dimensions.iconSizeMedium, width: Dimensions.iconSizeMedium,),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Text('${getTranslated('reason', context)}', style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color
                        )),
                      ]),
                    ),

                    if(isDetails)
                      Divider(color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.07), thickness: 1),


                    Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                      child: Text(
                        refundModel!.refundReason!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: isDetails ? 250 : 1,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    ((refundModel?.images?.isNotEmpty ?? false) && isDetails) ?
                    RefundAttachmentListWidget(refundModel: refundModel) : const SizedBox(),

                  ],
                ),
              ) :
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                margin: const EdgeInsets.fromLTRB(18,0, Dimensions.fontSizeDefault, Dimensions.fontSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [

                  Text('${getTranslated('reason', context)}: ', style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).primaryColor,
                  )),
                  const SizedBox(width: Dimensions.paddingSizeVeryTiny),

                  Expanded(child: Text( refundModel!.refundReason!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: isDetails ? 50 : 1,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.70),
                    ),
                  )),
                ]),
              ),
            ]),
          ),

          if(isLast)
          const SizedBox(height: Dimensions.paddingSizeSmall)

        ]),
      ),
    );
  }
}
