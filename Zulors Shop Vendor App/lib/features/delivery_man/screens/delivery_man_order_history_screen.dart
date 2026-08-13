import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zulors_shop_vendor/common/basewidgets/paginated_list_view_widget.dart';
import 'package:zulors_shop_vendor/features/delivery_man/domain/model/top_delivery_man.dart';
import 'package:zulors_shop_vendor/features/delivery_man/controllers/delivery_man_controller.dart';
import 'package:zulors_shop_vendor/common/basewidgets/no_data_screen.dart';
import 'package:zulors_shop_vendor/features/delivery_man/widgets/delivery_man_order_history_widget.dart';

class DeliveryManOrderListScreen extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  const DeliveryManOrderListScreen({super.key, this.deliveryMan});

  @override
  State<DeliveryManOrderListScreen> createState() => _DeliveryManOrderListScreenState();
}

class _DeliveryManOrderListScreenState extends State<DeliveryManOrderListScreen> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryManController>(
      builder: (context, order, child) {

        if(order.deliveryManDetails == null) return const Center(child: CircularProgressIndicator());

        return (order.deliverymanOrderList?.orders?.isNotEmpty ?? false) ?
        RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          onRefresh: () async {
            await order.getDeliveryManOrderList(context,1,widget.deliveryMan!.id);
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: PaginatedListViewWidget (
              scrollController: scrollController,
              totalSize: order.deliverymanOrderList!.totalSize,
              offset: int.tryParse(order.deliverymanOrderList!.offset!),
              onPaginate: (int? offset) async {
                await order.getDeliveryManOrderList(context, offset!, widget.deliveryMan!.id, reload: false);
              },
              itemView: ListView.builder (
                //controller: scrollController,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: order.deliverymanOrderList!.orders!.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  return DeliveryManOrderHistoryWidget(orderModel: order.deliverymanOrderList!.orders![index]);
                }
              ),
            ),
          ),
        ) : const NoDataScreen(title: 'no_order_found', padding: EdgeInsets.only(top: 100));
      }
    );
  }
}
