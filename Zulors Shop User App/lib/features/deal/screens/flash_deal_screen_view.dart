import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/custom_app_bar_widget.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/features/deal/controllers/flash_deal_controller.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/common/basewidget/title_row_widget.dart';
import 'package:zulors_shop/features/deal/widgets/flash_deals_list_widget.dart';
import 'package:provider/provider.dart';

class FlashDealScreenView extends StatefulWidget {
  const FlashDealScreenView({super.key});
  @override
  State<FlashDealScreenView> createState() => _FlashDealScreenViewState();
}
class _FlashDealScreenViewState extends State<FlashDealScreenView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('flash_deal', context)),
      body: Column(children: [
        // CustomAppBar(title: getTranslated('flash_deal', context)?.toUpperCase()),

        SafeArea(
          child: Padding(padding: const EdgeInsets.only(
            left:  Dimensions.paddingSizeSmall,
            right:  Dimensions.paddingSizeSmall,
            top:  Dimensions.paddingSizeSmall,
          ),
            child: TitleRowWidget(title: getTranslated('flash_deal', context)?.toUpperCase(),
              eventDuration: Provider.of<FlashDealController>(context).duration, isFlash: true, isBackExist: true)),
        ),


        Expanded(child: RefreshIndicator(
          onRefresh: () async => await Provider.of<FlashDealController>(context, listen: false).getFlashDealList(true, false),
          child: Padding(padding: EdgeInsets.only(
            top: Dimensions.paddingSizeExtraSmall,
            left:  Dimensions.paddingSizeSmall,
            right:  Dimensions.paddingSizeSmall,
            bottom:  Dimensions.paddingSizeSmall,
          ),
          child: FlashDealsListWidget(isHomeScreen: false))))]));
  }
}
