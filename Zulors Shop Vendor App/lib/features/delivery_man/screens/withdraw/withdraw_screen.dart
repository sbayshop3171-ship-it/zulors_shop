import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/helper/color_helper.dart';
import 'package:zulors_shop_vendor/localization/language_constrants.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/theme/controllers/theme_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/utill/styles.dart';
import 'package:zulors_shop_vendor/common/basewidgets/custom_app_bar_widget.dart';
import 'package:zulors_shop_vendor/features/delivery_man/screens/withdraw/withdraw_list.dart';



class DeliveryManWithdrawScreen extends StatefulWidget {
  const DeliveryManWithdrawScreen({super.key});

  @override
  State<DeliveryManWithdrawScreen> createState() => _DeliveryManWithdrawScreenState();
}

class _DeliveryManWithdrawScreenState extends State<DeliveryManWithdrawScreen> {

  @override
  void initState() {
    Provider.of<DeliveryManController>(context, listen: false).getDeliveryManWithdrawList(1, 'all');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('withdraw_list', context),isBackButtonExist: true,),
      body: RefreshIndicator(
        onRefresh: () async{
        },
        child: CustomScrollView(
          slivers: [

            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          WithdrawTypeButton(text: getTranslated('all', context), index: 0),
                          const SizedBox(width: 5),

                          WithdrawTypeButton(text: getTranslated('pending', context), index: 1),
                          const SizedBox(width: 5),

                          WithdrawTypeButton(text: getTranslated('accepted', context), index: 2),
                          const SizedBox(width: 5),

                          WithdrawTypeButton(text: getTranslated('denied', context), index: 3),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),

                  const WithdrawListView(),
                ],
              ),
            )
          ],
        ),),
    );
  }
}


class WithdrawTypeButton extends StatelessWidget {
  final String? text;
  final int index;
  const WithdrawTypeButton({super.key, required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          Provider.of<DeliveryManController>(context, listen: false).setIndex(context, index);
        },
        child: Consumer<DeliveryManController>(builder: (context, order, child) {
          return Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: order.withdrawTypeIndex == index ? Theme.of(context).primaryColor : Provider.of<ThemeController>(context).darkTheme ?
              ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
              Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeLarge),
            ),
            child: Text(text!, style: order.withdrawTypeIndex == index ? titilliumBold.copyWith(color: order.withdrawTypeIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color):
            robotoRegular.copyWith(color: order.withdrawTypeIndex == index
                ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).textTheme.bodyLarge?.color)),
          );
        },
        ),
      ),
    );
  }
}