import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/pos/controllers/cart_controller.dart';
import 'package:zulors_shop_vendor/features/pos/domain/models/temporary_cart_for_customer_model.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/hold_order_header_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/hold_order_item_widget.dart';
import 'package:zulors_shop_vendor/features/pos/widgets/hold_order_search_bar_widget.dart';
import 'package:zulors_shop_vendor/utill/dimensions.dart';

class HoldOrderScreen extends StatefulWidget {
  const HoldOrderScreen({super.key});

  @override
  State<HoldOrderScreen> createState() => _HoldOrderScreenState();
}

class _HoldOrderScreenState extends State<HoldOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CartController>(
        builder: (context, cartController, _) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 15),

                const Padding(
                  padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: HoldOrderHeaderWidget()
                ),

                cartController.customerCartList.length > 1 ?
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 0),
                  child: HoldOrderSearchBarWidget()
                ) : const SizedBox(),

                cartController.customerCartList.isNotEmpty ?
                Expanded(
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      itemCount: cartController.customerCartList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        TemporaryCartListModel customerCard = cartController.customerCartList[index];
                        return  HoldOrderItemWidget(customerCard: customerCard, index: index);
                      }
                    ),
                  ),
                ) : const Expanded(child: NoDataScreen(title: 'no_hold_order')),

                const SizedBox(height: Dimensions.paddingSizeSmall),

              ],
            ),
          );
        })
    );
  }
}
