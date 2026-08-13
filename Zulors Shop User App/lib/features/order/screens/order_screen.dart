import 'package:flutter/material.dart';
import 'package:zulors_shop/features/order/controllers/order_controller.dart';
import 'package:zulors_shop/features/order/widgets/order_shimmer_widget.dart';
import 'package:zulors_shop/features/order/widgets/order_type_button_widget.dart';
import 'package:zulors_shop/features/order/widgets/order_widget.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/main.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/utill/dimensions.dart';
import 'package:zulors_shop/utill/images.dart';
import 'package:zulors_shop/common/basewidget/custom_app_bar_widget.dart';
import 'package:zulors_shop/common/basewidget/no_internet_screen_widget.dart';
import 'package:zulors_shop/common/basewidget/not_loggedin_widget.dart';
import 'package:zulors_shop/common/basewidget/paginated_list_view_widget.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromDashboard;
  final bool fromPlaceOrder;
  const OrderScreen({super.key, this.isBacButtonExist = true, this.fromDashboard = false, this.fromPlaceOrder = false}) ;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ScrollController scrollController  = ScrollController();
   bool isGuestMode = !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn();
  @override
  void initState() {
    if(!isGuestMode){
      Provider.of<OrderController>(context, listen: false).setIndex(0, notify: false);
      Provider.of<OrderController>(context, listen: false).getOrderList(1,'ongoing');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromPlaceOrder) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
        } else {
          return;
        }
      },
      child: Scaffold(
       appBar: CustomAppBar(title: getTranslated('order', context), isBackButtonExist: widget.isBacButtonExist,
       onBackPressed: () {
         if(widget.fromPlaceOrder) {
           RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
         } else {
           Navigator.of(context).pop();
         }
        },
       ),
        body: isGuestMode ? NotLoggedInWidget(message: getTranslated('to_view_the_order_history', context), fromPage: widget.fromDashboard ? '${RouterHelper.dashboardScreen}?page=orders' : RouterHelper.orderScreen, ) :
        Consumer<OrderController>(
          builder: (context, orderController, child) {
            return Column(children: [


              Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Row(children: [
                  OrderTypeButton(text: getTranslated('RUNNING', context), index: 0),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  OrderTypeButton(text: getTranslated('DELIVERED', context), index: 1),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  OrderTypeButton(text: getTranslated('CANCELED', context), index: 2)])),



                Expanded(child: orderController.orderModel != null ? (orderController.orderModel!.orders != null &&
                    orderController.orderModel!.orders!.isNotEmpty)?
                  SingleChildScrollView(
                    controller: scrollController,
                    child: PaginatedListView(scrollController: scrollController,
                      onPaginate: (int? offset) async{
                        await orderController.getOrderList(offset!, orderController.selectedType);
                      },
                      totalSize: orderController.orderModel?.totalSize,
                      offset: orderController.orderModel?.offset != null ? int.parse(orderController.orderModel!.offset!):1,
                      itemView: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orderController.orderModel?.orders!.length,
                        padding: const EdgeInsets.all(0),
                        itemBuilder: (context, index) => OrderWidget(orderModel: orderController.orderModel?.orders![index]),
                      ),
                    ),
                  ) : const NoInternetOrDataScreenWidget(isNoInternet: false, icon: Images.noOrder, message: 'no_order_found') :
                    const OrderShimmerWidget()
                )

              ],
            );
          }
        ),
      ),
    );
  }
}




