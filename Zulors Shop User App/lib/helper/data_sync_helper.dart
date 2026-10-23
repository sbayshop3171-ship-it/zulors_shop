import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:zulors_shop/common/enums/data_source_enum.dart';
import 'package:zulors_shop/data/local/cache_response.dart';
import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/helper/api_checker.dart';

class DataSyncHelper {
  /// Generic method to fetch data from local and remote sources
  static Future<void> fetchAndSyncData({
    required Future<ApiResponseModel<CacheResponseData>> Function()
        fetchFromLocal,
    required Future<ApiResponseModel<Response>> Function() fetchFromClient,
    required Function(dynamic, DataSourceEnum source) onResponse,
    void Function(String error)? onError,
  }) async {
    // Step 1: Try to load from the local source
    ApiResponseModel<CacheResponseData>? localResponse;
    try {
      localResponse = await fetchFromLocal();
    } catch (_) {
      // A broken or unavailable local cache must not prevent a network fetch.
    }

    var hasLocalData = localResponse?.isSuccess == true;
    if (hasLocalData) {
      try {
        onResponse(jsonDecode(localResponse!.response!.response),
            DataSourceEnum.local);
      } catch (_) {
        // Corrupt or outdated cache data must not prevent a fresh network request.
        hasLocalData = false;
      }
    }

    // Step 2: Try to load from the client (remote) source and update if successful
    ApiResponseModel<Response>? clientResponse;
    try {
      clientResponse = await fetchFromClient();
    } catch (error) {
      if (!hasLocalData) {
        if (onError != null) {
          onError(error.toString());
        } else {
          ApiChecker.checkApi(ApiResponseModel.withError(error.toString()));
        }
      }
      return;
    }
    if (clientResponse.isSuccess) {
      try {
        onResponse(clientResponse.response?.data, DataSourceEnum.client);
      } catch (error) {
        if (!hasLocalData) {
          if (onError != null) {
            onError(error.toString());
          } else {
            ApiChecker.checkApi(ApiResponseModel.withError(error.toString()));
          }
        }
      }
    } else if (!hasLocalData) {
      if (onError != null) {
        onError(clientResponse.error?.toString() ??
            'Unable to load data. Please retry.');
      } else {
        ApiChecker.checkApi(clientResponse);
      }
    }
  }
}
