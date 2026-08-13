import 'package:zulors_shop/features/shipping/domain/repositories/shipping_repository_interface.dart';
import 'package:zulors_shop/features/shipping/domain/services/shipping_service_interface.dart';

class ShippingService implements ShippingServiceInterface{
  ShippingRepositoryInterface shippingRepositoryInterface;
  ShippingService({required this.shippingRepositoryInterface});

  @override
  Future addShippingMethod(int? id, String? cartGroupId) async{
    return await shippingRepositoryInterface.addShippingMethod(id,cartGroupId);
  }
  @override
  Future getChosenShippingMethod() async{
    return await shippingRepositoryInterface.getChosenShippingMethod();
  }


  @override
  Future getShippingMethod(int? sellerId, String? type) async {
    return await shippingRepositoryInterface.getShippingMethod(sellerId, type);
  }


}