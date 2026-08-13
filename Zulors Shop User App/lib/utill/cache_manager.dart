import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:zulors_shop/data/local/cache_response.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/main.dart';

class CacheManager {

  static Future<CacheResponseData?> getLocalData(String endpoint) async {
    return await database.getCacheResponseById(endpoint);
  }

  static Future<void> storeBrandListInCache(bool hasLocalData, String endpoint, ApiResponseModel apiResponse) async {
    final cacheData = CacheResponseCompanion(
      endPoint: Value(endpoint),
      header: Value(jsonEncode(apiResponse.response!.headers.map)),
      response: Value(jsonEncode(apiResponse.response!.data)),
    );

    // if(hasLocalData) {
    //   print("=update lcoal data=");
    //   await database.updateCacheResponse(endpoint, cacheData);
    // } else {
      await database.insertCacheResponse(cacheData);
   // }
  }




}
