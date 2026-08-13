

import 'dart:io';

abstract class ProductDetailsServiceInterface {
  Future<dynamic> getProductDetails(int? productId);
  Future<dynamic> productStatusOnOff(int? productId, int status);
  Future<HttpClientResponse> previewDownload(String url);
}