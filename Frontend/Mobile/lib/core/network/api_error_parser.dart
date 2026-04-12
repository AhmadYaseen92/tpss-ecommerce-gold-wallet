import 'package:dio/dio.dart';

class ApiErrorParser {
  static String friendlyMessage(
    DioException error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final cached = error.requestOptions.extra['friendlyMessage'];
    if (cached is String && cached.trim().isNotEmpty) {
      return cached.trim();
    }

    final payload = error.response?.data;
    final serverMessage = _extractServerMessage(payload);
    if (serverMessage.isNotEmpty) return serverMessage;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your internet connection and try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach server. Please check your internet connection.';
    }

    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      400 => 'Invalid request. Please review your input and try again.',
      401 || 403 => 'Your session has expired. Please log in again.',
      404 => 'Requested resource was not found.',
      409 => 'Request conflict. Please refresh and retry.',
      422 => 'Validation failed. Please check submitted values.',
      500 || 502 || 503 || 504 =>
        'Server is temporarily unavailable. Please try again shortly.',
      _ => fallback,
    };
  }

  static String _extractServerMessage(dynamic payload) {
    if (payload is String) {
      final trimmed = payload.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }

    if (payload is Map<String, dynamic>) {
      final directMessage = payload['message']?.toString().trim() ?? '';
      if (directMessage.isNotEmpty) return directMessage;

      final errors = payload['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first.toString().trim();
        if (first.isNotEmpty) return first;
      }

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final nestedMessage = data['message']?.toString().trim() ?? '';
        if (nestedMessage.isNotEmpty) return nestedMessage;
      }
    }

    return '';
  }
}
