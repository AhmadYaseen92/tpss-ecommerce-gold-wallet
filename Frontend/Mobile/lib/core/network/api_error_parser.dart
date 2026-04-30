import 'package:dio/dio.dart';

class ApiError {
  final String message;
  final String? errorCode;
  final List<String> errors;

  ApiError({required this.message, this.errorCode, this.errors = const []});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final errorsRaw = json['errors'] ?? json['Errors'];
    final errors = (errorsRaw as List?)?.map((e) => e.toString()).toList() ?? [];

    final messageRaw = json['message'] ?? json['Message'];
    final message = errors.isNotEmpty
        ? errors.first
        : (messageRaw?.toString().isNotEmpty == true
              ? messageRaw.toString()
              : 'Something went wrong. Please try again later.');

    final errorCodeRaw = json['errorCode'] ?? json['ErrorCode'];

    return ApiError(message: message, errorCode: errorCodeRaw?.toString(), errors: errors);
  }
}

class ApiErrorParser {
  static ApiError parse(DioException error) {
    final payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      return ApiError.fromJson(payload);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ApiError(message: 'No internet connection. Please check your connection.');
    }

    return ApiError(message: 'Something went wrong. Please try again later.');
  }

  static String friendlyMessage(DioException error, {String fallback = 'Something went wrong. Please try again later.'}) {
    final parsed = parse(error);
    return parsed.message.trim().isNotEmpty ? parsed.message.trim() : fallback;
  }

  static String friendlyFromAny(Object error, {String fallback = 'Something went wrong. Please try again later.'}) {
    if (error is DioException) {
      return friendlyMessage(error, fallback: fallback);
    }
    return fallback;
  }
}
