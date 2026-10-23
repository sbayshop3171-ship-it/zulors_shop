import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;

  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (kDebugMode) {
      print(
          "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path} request=${response.requestOptions.headers['X-Request-Id']}");
    }
    if (kDebugMode) {
      print("<-- END HTTP");
    }

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print(
          "ERROR[${err.response?.statusCode ?? err.type.name}] => PATH: ${err.requestOptions.path} request=${err.requestOptions.headers['X-Request-Id']}");
    }
    return super.onError(err, handler);
  }
}
