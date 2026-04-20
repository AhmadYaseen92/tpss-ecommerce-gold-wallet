import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/repositories/checkout_otp_repository.dart';

class RequestCheckoutOtpUseCase {
  const RequestCheckoutOtpUseCase(this._repository);

  final ICheckoutOtpRepository _repository;

  Future<CheckoutOtpSessionEntity> call(
    CheckoutOtpRequestContextEntity context,
  ) {
    return _repository.requestOtp(context);
  }
}

class ResendCheckoutOtpUseCase {
  const ResendCheckoutOtpUseCase(this._repository);

  final ICheckoutOtpRepository _repository;

  Future<CheckoutOtpSessionEntity> call({
    required int userId,
    required String otpRequestId,
    required bool forceEmailFallback,
  }) {
    return _repository.resendOtp(
      userId: userId,
      otpRequestId: otpRequestId,
      forceEmailFallback: forceEmailFallback,
    );
  }
}

class VerifyCheckoutOtpUseCase {
  const VerifyCheckoutOtpUseCase(this._repository);

  final ICheckoutOtpRepository _repository;

  Future<CheckoutOtpVerificationEntity> call({
    required int userId,
    required String otpRequestId,
    required String otpCode,
  }) {
    return _repository.verifyOtp(
      userId: userId,
      otpRequestId: otpRequestId,
      otpCode: otpCode,
    );
  }
}
