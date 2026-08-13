import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_detail_shimmer.dart';
import 'package:zulors_shop_vendor/helper/date_converter.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/main.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/change_log_widget.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_details_widget.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';

class RefundDetailsScreen extends StatefulWidget {
  final RefundModel? refundModel;
  final int? orderDetailsId;
  final String? variation;
  final bool? fromNotification;
  const RefundDetailsScreen({super.key, this.refundModel, this.orderDetailsId, this.variation, this.fromNotification = false});

  @override
  State<RefundDetailsScreen> createState() => _RefundDetailsScreenState();
}

class _RefundDetailsScreenState extends State<RefundDetailsScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  int selectedIndex = 0;
  RefundModel? refundModel;

  @override
  void initState() {
    super.initState();

    final refundController = Provider.of<RefundController>(context, listen: false);
    refundController.emptyRefundDetailsModel();
    refundController.getRefundReqInfo(context, widget.orderDetailsId);

    if(widget.fromNotification!){
      Provider.of<RefundController>(context, listen: false).emptyRefundModel();
      Provider.of<RefundController>(context, listen: false).getSingleRefundModel(Get.context!, widget.refundModel?.id);
    } else {
      refundModel = widget.refundModel;
    }
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    _tabController?.addListener((){
      if (kDebugMode) {
        print('my index is${_tabController!.index}');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        if(widget.fromNotification == true) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route)=> false);
        } else {
          return;
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.maxFinite, 60),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Provider.of<ThemeController>(context, listen: false).darkTheme? Theme.of(context).primaryColor.withValues(alpha:0):
                Theme.of(context).primaryColor.withValues(alpha:.10),
                  offset: const Offset(0, 2.0), blurRadius: 4.0,
                )
              ]
            ),
            child: AppBar(
              backgroundColor: Theme.of(context).highlightColor,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  if(widget.fromNotification == true) {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route)=> false);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Icon(CupertinoIcons.back, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              title:  Consumer<RefundController>(
                  builder: (context,refundReq,_) {
                  return Column(children: [
                    Text('${refundModel?.orderId != null ?  '${getTranslated('order', context)!}#' : ''} ${refundModel?.orderId ?? ' '}', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
                   const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(refundModel?.createdAt != null ?  DateConverter.isoStringToLocalDateAndTime(refundModel!.createdAt!) : ' ',
                        style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall)),
                  ]);
                }
              ),
              actions: [
                Consumer<RefundController>(
                  builder: (context,refundReq,_) {
                    return InkWell(onTap: refundModel?.order?.paymentMethod  == null ? null : () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangeLogWidget(paidBy: refundModel!.order!.paymentMethod ?? '')));
                      },
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(100)
                          ),
                          child: const Center(child: Icon(Icons.history, color: Colors.white, size: Dimensions.iconSizeMedium)),
                        ),
                      ),
                    );
                  }
                )],
            ),
          ),
        ),

        body: Consumer<RefundController>(
          builder: (context,refundController,_) {
            if(widget.fromNotification! && widget.refundModel?.status == null){
              refundModel = refundController.refundModel;
            }
            return ((widget.fromNotification! &&  refundController.refundModel == null) || refundController.refundDetailsModel == null) ?
            const RefundDetailShimmer() :
            RefundDetailWidget(refundModel: refundModel, orderDetailsId: widget.orderDetailsId, variation: widget.variation);
          }
        )
      ),
    );
  }
}
