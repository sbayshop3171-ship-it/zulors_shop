import 'dart:developer';

import 'package:zulors_shop/data/model/api_response.dart';
import 'package:zulors_shop/data/model/error_response.dart';
import 'package:zulors_shop/localization/language_constrants.dart';
import 'package:zulors_shop/main.dart';
import 'package:zulors_shop/features/auth/controllers/auth_controller.dart';
import 'package:zulors_shop/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

class ApiChecker {
  static String? _lastShownMessage;
  static DateTime? _lastShownAt;

  static void checkApi(ApiResponseModel apiResponse,
      {bool firebaseResponse = false}) {
    dynamic errorResponse = apiResponse.error is String
        ? apiResponse.error
        : ErrorResponse.fromJson(apiResponse.error);
    if (apiResponse.error == "Failed to load data - status code: 401") {
      Provider.of<AuthController>(Get.context!, listen: false)
          .clearSharedData();
    } else if (apiResponse.response?.statusCode == 500) {
      _showOnce(getTranslated('internal_server_error', Get.context!) ??
          'Server unavailable');
    } else if (apiResponse.response?.statusCode == 503) {
      _showOnce(apiResponse.response?.data is Map
          ? apiResponse.response?.data['message']?.toString() ??
              'Service unavailable'
          : 'Service unavailable');
    } else {
      log("==ff=>${apiResponse.error}");
      String? errorMessage = apiResponse.error.toString();
      if (apiResponse.error is String) {
        errorMessage = apiResponse.error.toString();
      } else {
        log(errorResponse.toString());
        //errorMessage = errorResponse.errors?[0].message;
      }
      _showOnce(firebaseResponse
          ? errorResponse?.replaceAll('_', ' ')
          : errorMessage);
    }
  }

  static void _showOnce(String? message) {
    final context = Get.context;
    if (context == null || message == null || message.trim().isEmpty) return;
    final now = DateTime.now();
    final deduplicationKey =
        message.replaceAll(RegExp(r'\s*\(Request: [^)]+\)'), '').trim();
    if (_lastShownMessage == deduplicationKey &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(seconds: 4)) {
      return;
    }
    _lastShownMessage = deduplicationKey;
    _lastShownAt = now;
    showCustomSnackBarWidget(message, context,
        snackBarType: SnackBarType.error);
  }

  static ErrorResponse getError(ApiResponseModel apiResponse) {
    ErrorResponse error;

    try {
      error = ErrorResponse.fromJson(apiResponse.response?.data);
    } catch (e) {
      if (apiResponse.error is String) {
        error = ErrorResponse(
            errors: [Errors(code: '', message: apiResponse.error.toString())]);
      } else {
        error = ErrorResponse.fromJson(apiResponse.error);
      }
    }
    return error;
  }
}
