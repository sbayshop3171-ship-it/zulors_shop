abstract class VatServiceInterface {

  Future<dynamic> getVatReport(int? limit, int? offset, String? startDate, String? endDate);


}