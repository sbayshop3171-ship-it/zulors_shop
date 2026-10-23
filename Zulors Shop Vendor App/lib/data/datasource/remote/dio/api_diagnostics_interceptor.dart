import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiDiagnosticsInterceptor extends InterceptorsWrapper {
  ApiDiagnosticsInterceptor(this._dio);

  final Dio _dio;
  static final Random _random = Random.secure();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final randomPart = _random.nextInt(1 << 32).toRadixString(16);
    options.headers.putIfAbsent('X-Request-Id', () => '$timestamp-$randomPart');
    options.extra['_requestStartedAt'] ??=
        DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final startedAt =
          response.requestOptions.extra['_requestStartedAt'] as int?;
      final elapsed = startedAt == null
          ? -1
          : DateTime.now().millisecondsSinceEpoch - startedAt;
      debugPrint(
        'API ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.path} ${elapsed}ms '
        'request=${response.requestOptions.headers['X-Request-Id']}',
      );
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retries = options.extra['_safeGetRetries'] as int? ?? 0;
    final status = err.response?.statusCode;
    final retryableStatus =
        status == 500 || status == 502 || status == 503 || status == 504;
    final retryableNetworkError =
        err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError;

    if (options.method.toUpperCase() == 'GET' &&
        retries == 0 &&
        (retryableStatus || retryableNetworkError)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        final response = await _dio.fetch<dynamic>(
          options.copyWith(
            extra: <String, dynamic>{...options.extra, '_safeGetRetries': 1},
          ),
        );
        handler.resolve(response);
        return;
      } on DioException catch (retryError) {
        if (kDebugMode) {
          final startedAt = options.extra['_requestStartedAt'] as int?;
          final elapsed = startedAt == null
              ? -1
              : DateTime.now().millisecondsSinceEpoch - startedAt;
          debugPrint(
            'API retry failed ${retryError.response?.statusCode} '
            '${options.method} ${options.path} ${elapsed}ms '
            'request=${options.headers['X-Request-Id']}',
          );
        }
        handler.next(retryError);
        return;
      } catch (_) {
        handler.next(err);
        return;
      }
    }

    final startedAt = options.extra['_requestStartedAt'] as int?;
    final elapsed = startedAt == null
        ? -1
        : DateTime.now().millisecondsSinceEpoch - startedAt;
    if (kDebugMode) {
      debugPrint(
        'API error ${status ?? err.type.name} ${options.method} '
        '${options.path} ${elapsed}ms '
        'request=${options.headers['X-Request-Id']}',
      );
    }
    handler.next(err);
  }
}
