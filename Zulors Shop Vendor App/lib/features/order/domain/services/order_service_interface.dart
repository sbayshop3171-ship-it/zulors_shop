abstract class OrderServiceInterface {
  Future<dynamic> getOrderList(int offset, String status);
  Future<dynamic> orderAddressEdit({String? orderID, String? addressType, String? contactPersonName, String? phone, String? city, String? zip,
    String? address, String? email, String? latitude, String? longitude,
  });
}