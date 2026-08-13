import 'dart:io';
import 'package:zulors_shop/interface/repo_interface.dart';

abstract class ProductDetailsRepositoryInterface implements RepositoryInterface{
  Future<dynamic> getCount(String productID);
  Future<dynamic> getSharableLink(String productID);
  Future<HttpClientResponse> previewDownload(String url);

}