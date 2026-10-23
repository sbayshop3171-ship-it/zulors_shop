import 'package:dio/dio.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/main.dart';
import 'package:provider/provider.dart';

class ApiErrorHandler {
  static dynamic getMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final requestId =
          error.requestOptions.headers['X-Request-Id']?.toString();
      final body = error.response?.data;
      final serverMessage = _messageFromBody(body);

      switch (error.type) {
        case DioExceptionType.cancel:
          return 'Request was cancelled';
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return 'The server took too long to respond. Please retry.';
        case DioExceptionType.connectionError:
          return 'Unable to connect. Check your internet connection and retry.';
        case DioExceptionType.badCertificate:
          return 'Secure connection to the server failed.';
        case DioExceptionType.unknown:
          return error.message ?? 'Unexpected network error';
        case DioExceptionType.badResponse:
          if (statusCode == 401) {
            final context = Get.context;
            if (context != null &&
                Provider.of<AuthController>(context, listen: false)
                    .isLoggedIn()) {
              Provider.of<AuthController>(context, listen: false)
                  .clearSharedData();
            }
            return serverMessage.isNotEmpty
                ? serverMessage
                : 'Your session has expired. Please sign in again.';
          }
          if (statusCode == 404) {
            return serverMessage.isNotEmpty
                ? serverMessage
                : 'The requested item was not found.';
          }
          if (statusCode == 429) {
            return 'Too many requests. Please wait a moment and retry.';
          }
          if (statusCode == 500 ||
              statusCode == 502 ||
              statusCode == 503 ||
              statusCode == 504) {
            final reference = requestId == null ? '' : ' (Request: $requestId)';
            return 'The server is temporarily unavailable.$reference';
          }
          return serverMessage.isNotEmpty
              ? serverMessage
              : 'Request failed${statusCode == null ? '' : ' (HTTP $statusCode)'}';
      }
    }

    if (error is FormatException) {
      return 'The server returned data the app could not read.';
    }
    return error?.toString() ?? 'Unexpected error';
  }

  static String _messageFromBody(dynamic body) {
    if (body is Map) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) return message;
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map && first['message'] != null) {
          return first['message'].toString();
        }
        if (first is String) return first;
      }
      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;
        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }
        if (firstValue != null) return firstValue.toString();
      }
    }
    return '';
  }
}
