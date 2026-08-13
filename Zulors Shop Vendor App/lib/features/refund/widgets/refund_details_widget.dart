import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_details_model.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/helper/price_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/approve_reject_widget.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/customer_info_widget.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/delivery_man_info_widget.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_pricing_widget.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_widget.dart';



class RefundDetailWidget extends StatefulWidget {
  final RefundModel? refundModel;
  final int? orderDetailsId;
  final String? variation;
  const RefundDetailWidget({super.key, required this.refundModel, required this.orderDetailsId, this.variation});
  @override
  RefundDetailWidgetState createState() => RefundDetailWidgetState();
}

class RefundDetailWidgetState extends State<RefundDetailWidget> {

  final ScrollController _scrollController = ScrollController();
  bool _hasReachedMaxScroll = false;


  @override
  void initState() {
    Provider.of<RefundController>(context, listen: false).setInitialResetButton();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }
  bool showButton = false;

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }



  void _scrollListener() {
    // Check if scroll position is at the bottom
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_hasReachedMaxScroll) {
        setState(() {
          _hasReachedMaxScroll = true;
        });
      }
    } else if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      if (_hasReachedMaxScroll) {
        setState(() {
          _hasReachedMaxScroll = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    return Column(children: [
        Expanded(child: SingleChildScrollView(
          controller: _scrollController,
            child: Consumer<RefundController>(
                builder: (context,refundReq,_) {
          
                  if(refundReq.refundDetailsModel != null){
                    List<RefundStatus>? status =[];

                    if(refundReq.refundDetailsModel?.refundRequest != null && refundReq.refundDetailsModel!.refundRequest!.isNotEmpty) {
                      status = refundReq.refundDetailsModel?.refundRequest![0].refundStatus;
                      widget.refundModel?.status = refundReq.refundDetailsModel?.refundRequest![0].status;
                    }

          
                    String changeBy = '';
                    for(RefundStatus action in status!){
                      if (kDebugMode) {
                        print('=====>${action.changeBy}');
                      }
                      if(action.changeBy == 'admin'){
                        changeBy = 'admin';
                        showButton = false;
                      }
                    }
          
                    if(changeBy != 'admin'){
                      showButton = true;
                    }
                  }
                  
                  return Column(mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
          
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          child: RefundWidget(refundModel: widget.refundModel, isDetails: true),
                        ),
                        
                        const RefundPricingWidget(),
          
                        const SizedBox(height: Dimensions.paddingSizeSmall),
          
          
                        widget.refundModel!.customer != null ?
                        CustomerInfoWidget(refundModel: widget.refundModel) : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: Text("Customer not found", style: robotoMedium.copyWith(color: Colors.red),),
                        ),
          
                        const SizedBox(height: Dimensions.paddingSizeSmall,),
          
                        (refundReq.refundDetailsModel !=null && refundReq.refundDetailsModel!.deliverymanDetails != null)?
                        DeliveryManInfoWidget(refundReq: refundReq) : const SizedBox(),

                        // _hasReachedMaxScroll ?
                        // ApprovedAndRejectWidget(refundModel: widget.refundModel, orderDetailsId: widget.orderDetailsId) : SizedBox(),
                      ]);
                }
            ),
          ),
        ),


        Consumer<RefundController>(
            builder: (context,refundReq,_) {
            return
              //refundReq.refundDetailsModel!.refundRequest![0].refundStatus![ (refundReq.refundDetailsModel!.refundRequest![0].refundStatus?.length ?? 0) -1].changeBy != 'admin' ?
              ApprovedAndRejectWidget(refundModel: widget.refundModel, orderDetailsId: widget.orderDetailsId);
              // : const SizedBox();
          }
        ),

      ],

    );
  }
}


class ProductCalculationItem extends StatelessWidget {
  final String? title;
  final double? price;
  final bool isQ;
  final int? qty;
  final bool isNegative;
  final bool isPositive;
  const ProductCalculationItem({super.key, this.title, this.price, this.isQ = false, this.isNegative = false, this.isPositive = false, this.qty});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      isQ ?
      Text('${getTranslated(title, context)} (x$qty)', style: titilliumRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
      )) :
      Text('${getTranslated(title, context)}', style: robotoRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7),
      )),

      const Spacer(),

      isNegative ?
      Text('- ${PriceConverter.convertPrice(context, price)}', style: titilliumSemiBold.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      )) :
      isPositive ?
      Text('+ ${PriceConverter.convertPrice(context, price)}', style: titilliumSemiBold.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      )) :
      Text(PriceConverter.convertPrice(context, price), style: titilliumSemiBold.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      )),
    ],);
  }
}
