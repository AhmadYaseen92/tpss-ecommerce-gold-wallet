import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/datasources/checkout_otp_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/repositories/checkout_otp_repository.dart';

class CheckoutOtpRepositoryImpl implements ICheckoutOtpRepository {
  CheckoutOtpRepositoryImpl(this._remoteDataSource);

  final CheckoutOtpRemoteDataSource _remoteDataSource;

  @override
  Future<CheckoutOtpSessionEntity> requestOtp(
    CheckoutOtpRequestContextEntity context,
  ) async {
    final model = await _remoteDataSource.requestOtp(context);
    return CheckoutOtpSessionEntity(otpRequestId: model.otpRequestId);
  }

  @override
  Future<CheckoutOtpSessionEntity> resendOtp({
    required int userId,
    required String otpRequestId,
    required bool forceEmailFallback,
  }) async {
    final model = await _remoteDataSource.resendOtp(
      userId: userId,
      otpRequestId: otpRequestId,
      forceEmailFallback: forceEmailFallback,
    );
    return CheckoutOtpSessionEntity(otpRequestId: model.otpRequestId);
  }

  @override
  Future<CheckoutOtpVerificationEntity> verifyOtp({
    required int userId,
    required String otpRequestId,
    required String otpCode,
  }) async {
    final model = await _remoteDataSource.verifyOtp(
      userId: userId,
      otpRequestId: otpRequestId,
      otpCode: otpCode,
    );
    return CheckoutOtpVerificationEntity(
      otpRequestId: model.otpRequestId,
      verificationToken: model.verificationToken,
    );
  }
}
