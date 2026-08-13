import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zulors_shop_vendor/features/dashboard/screens/dashboard_screen.dart';
import 'package:zulors_shop_vendor/features/refund/domain/models/refund_model.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/refund/controllers/refund_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/refund/widgets/refund_widget.dart';
import '../../../theme/controllers/theme_controller.dart';

class RefundScreen extends StatelessWidget {
  final bool isBacButtonExist;
  final bool fromNotification;
  const RefundScreen({super.key, this.isBacButtonExist = false, required this.fromNotification});

  @override
  Widget build(BuildContext context) {
    Provider.of<RefundController>(context, listen: false).getRefundList(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if(fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
        }
        return;
      },
      child: Scaffold(
        body: Consumer<RefundController>(builder: (context, refund, child) {
          List<RefundModel>? refundList = [];
          if (refund.refundTypeIndex == 0) {
            refundList = refund.pendingList;
          }else if (refund.refundTypeIndex == 1) {
            refundList = refund.approvedList;
          }else if (refund.refundTypeIndex == 2) {
            refundList = refund.deniedList;
          }else if (refund.refundTypeIndex == 3) {
            refundList = refund.doneList;
          }
          return Column(children: [
              CustomAppBarWidget(title: getTranslated('refund', context), isBackButtonExist: isBacButtonExist,
                onBackPressed: () {
                  if(fromNotification) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()));
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),

              refund.pendingList != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                child: SizedBox(
                  height: 40,
                  child: ListView(shrinkWrap: true, scrollDirection: Axis.horizontal, children: [
                      RefundTypeButton(text: getTranslated('pending', context), index: 0, refundList: refund.pendingList),
                      const SizedBox(width: 5),
                      RefundTypeButton(text: getTranslated('approved', context), index: 1, refundList: refund.approvedList),
                      const SizedBox(width: 5),
                      RefundTypeButton(text: getTranslated('rejected', context), index: 2, refundList: refund.deniedList),
                      const SizedBox(width: 5),
                      RefundTypeButton(text: getTranslated('refunded', context), index: 3, refundList: refund.doneList),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
              ) : const SizedBox(),

              refund.pendingList != null ? refundList!.isNotEmpty ?
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await refund.getRefundList(context, isReload: true);
                  }, child: ListView.builder(
                    itemCount: refundList.length,
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) => RefundWidget(refundModel : refundList![index], isLast: refundList.length-1 == index),
                  ),
                ),
              ) : const Expanded(child: NoDataScreen(title: 'no_refund_request_found')) : const Expanded(child: OrderShimmer()),
            ],
          );
        },
        ),
      ),
    );
  }
}

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(0),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          color: Theme.of(context).highlightColor,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(height: 10, width: 150, color: Theme.of(context).colorScheme.secondaryContainer),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Container(height: 45, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Container(height: 20, color: Theme.of(context).colorScheme.secondaryContainer),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(height: 10, width: 70, color: Colors.white),
                              const SizedBox(width: 10),
                              Container(height: 10, width: 20, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RefundTypeButton extends StatelessWidget {
  final String? text;
  final int index;
  final List<RefundModel>? refundList;
  const RefundTypeButton({super.key, required this.text, required this.index, required this.refundList});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Provider.of<RefundController>(context, listen: false).setIndex(index),
      child: Consumer<RefundController>(builder: (context, refund, child) {
        return Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: refund.refundTypeIndex == index ? Theme.of(context).primaryColor :
            Provider.of<ThemeController>(context).darkTheme ?
            ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
            Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
          ),
          child: Text(text!, style: refund.refundTypeIndex == index ? titilliumBold.copyWith(color: refund.refundTypeIndex == index
              ? Theme.of(context).colorScheme.secondaryContainer :
          Theme.of(context).textTheme.bodyLarge?.color):
          robotoRegular.copyWith(color: refund.refundTypeIndex == index
              ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color)),
        );
      },
      ),
    );
  }
}
