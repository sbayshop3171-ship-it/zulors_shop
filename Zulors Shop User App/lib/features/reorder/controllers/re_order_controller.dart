import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/features/cart/controllers/cart_controller.dart';
import 'package:zulors_shop/features/reorder/domain/services/re_order_service_interface.dart';
import 'package:zulors_shop/helper/api_checker.dart';
import 'package:zulors_shop/helper/route_healper.dart';
import 'package:zulors_shop/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zulors_shop/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';


class ReOrderController with ChangeNotifier {
  final ReOrderServiceInterface reOrderServiceInterface;
  ReOrderController({required this.reOrderServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  Future<ApiResponseModel> reorder({String? orderId}) async {
    _isLoading =true;
    notifyListeners();
    ApiResponseModel apiResponse = await reOrderServiceInterface.reorder(orderId!);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Provider.of<CartController>(Get.context!, listen: false).setIsCartLoading();
      showCustomSnackBarWidget(apiResponse.response?.data['message'], Get.context!, snackBarType: SnackBarType.success);
      RouterHelper.getCartScreenRoute(action: RouteAction.push);
    }else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }

}
