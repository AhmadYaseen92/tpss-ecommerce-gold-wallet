import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_otp_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';

class CheckoutOtpRemoteDataSource {
  CheckoutOtpRemoteDataSource(this._dio);

  final Dio _dio;

  Future<CheckoutOtpDispatchModel> requestOtp(
    CheckoutOtpRequestContextEntity context,
  ) async {
    final response = await _dio.post(
      '/checkout/otp/request',
      data: {
        'userId': context.userId,
        if (context.productIds.isNotEmpty) 'productIds': context.productIds,
        if (context.productId != null) 'productId': context.productId,
        if (context.quantity != null) 'quantity': context.quantity,
        'forceEmailFallback': context.forceEmailFallback,
      },
    );

    final payload = response.data as Map<String, dynamic>? ?? const {};
    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    return CheckoutOtpDispatchModel.fromJson(data);
  }

  Future<CheckoutOtpDispatchModel> resendOtp({
    required int userId,
    required String otpRequestId,
    required bool forceEmailFallback,
  }) async {
    final response = await _dio.post(
      '/checkout/otp/resend',
      data: {
        'userId': userId,
        'otpRequestId': otpRequestId,
        'forceEmailFallback': forceEmailFallback,
      },
    );

    final payload = response.data as Map<String, dynamic>? ?? const {};
    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    return CheckoutOtpDispatchModel.fromJson(data);
  }

  Future<CheckoutOtpVerifyModel> verifyOtp({
    required int userId,
    required String otpRequestId,
    required String otpCode,
  }) async {
    final response = await _dio.post(
      '/checkout/otp/verify',
      data: {
        'userId': userId,
        'otpRequestId': otpRequestId,
        'otpCode': otpCode,
      },
    );

    final payload = response.data as Map<String, dynamic>? ?? const {};
    final data = payload['data'] as Map<String, dynamic>? ?? const {};
    return CheckoutOtpVerifyModel.fromJson(data);
  }
}
