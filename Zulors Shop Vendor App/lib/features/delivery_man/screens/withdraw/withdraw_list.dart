import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/features/delivery_man/domain/model/delivery_man_withdraw_model.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/screens/withdraw/withdraw_card.dart';



class WithdrawListView extends StatelessWidget {
  const WithdrawListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryManController>(
      builder: (context, deliveryManProvider, child) {
        List<Withdraws> withdrawList;
        withdrawList = deliveryManProvider.withdrawList;


        return Column(mainAxisSize: MainAxisSize.min, children: [
           withdrawList.isNotEmpty ?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall),
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: withdrawList.length,
              itemBuilder: (context, index) {
                return WithdrawCardWidget(withdraw: withdrawList[index], index: index);
              },
            ),
          ): const NoDataScreen(),

          deliveryManProvider.isLoading ? Center(child: Padding(
            padding: const EdgeInsets.all(Dimensions.iconSizeExtraSmall),
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          )) : const SizedBox.shrink(),

        ]);
      },
    );
  }
}
