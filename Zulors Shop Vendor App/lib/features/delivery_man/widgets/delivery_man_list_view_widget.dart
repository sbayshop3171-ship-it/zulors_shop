import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/widgets/delivery_man_card_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/pos_product_shimmer_widget.dart';

class DeliveryManListViewWidget extends StatelessWidget {
  const DeliveryManListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryManController>(
      builder: (context, prodProvider, child) {
        return Column(mainAxisSize: MainAxisSize.min, children: [

          if(prodProvider.listOfDeliveryMan == null) const PosProductShimmerWidget(),

          (prodProvider.listOfDeliveryMan?.isNotEmpty ?? false) ?
          Padding(
            padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall),
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prodProvider.listOfDeliveryMan?.length,
              itemBuilder: (context, index) {
                return DeliveryManCardWidget(deliveryMan: prodProvider.listOfDeliveryMan![index]);
              },
            ),
          ) : const NoDataScreen(),

        ]);
      },
    );
  }
}
