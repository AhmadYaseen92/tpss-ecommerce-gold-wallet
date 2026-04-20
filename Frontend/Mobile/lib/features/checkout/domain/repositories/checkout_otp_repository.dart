import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';

abstract class ICheckoutOtpRepository {
  Future<CheckoutOtpSessionEntity> requestOtp(CheckoutOtpRequestContextEntity context);

  Future<CheckoutOtpSessionEntity> resendOtp({
    required int userId,
    required String otpRequestId,
    required bool forceEmailFallback,
  });

  Future<CheckoutOtpVerificationEntity> verifyOtp({
    required int userId,
    required String otpRequestId,
    required String otpCode,
  });
}
