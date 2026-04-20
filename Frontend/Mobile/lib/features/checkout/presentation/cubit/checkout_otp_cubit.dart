import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/usecases/checkout_otp_usecases.dart';

part 'checkout_otp_state.dart';

class CheckoutOtpCubit extends Cubit<CheckoutOtpState> {
  CheckoutOtpCubit({
    required RequestCheckoutOtpUseCase requestCheckoutOtpUseCase,
    required ResendCheckoutOtpUseCase resendCheckoutOtpUseCase,
    required VerifyCheckoutOtpUseCase verifyCheckoutOtpUseCase,
  }) : _requestCheckoutOtpUseCase = requestCheckoutOtpUseCase,
       _resendCheckoutOtpUseCase = resendCheckoutOtpUseCase,
       _verifyCheckoutOtpUseCase = verifyCheckoutOtpUseCase,
       super(CheckoutOtpInitial());

  final RequestCheckoutOtpUseCase _requestCheckoutOtpUseCase;
  final ResendCheckoutOtpUseCase _resendCheckoutOtpUseCase;
  final VerifyCheckoutOtpUseCase _verifyCheckoutOtpUseCase;

  String? otpRequestId;

  Future<void> initialize(CheckoutOtpRequestContextEntity context) async {
    emit(CheckoutOtpLoading());
    try {
      final session = await _requestCheckoutOtpUseCase(context);
      if (session.otpRequestId.trim().isEmpty) {
        emit(CheckoutOtpFailure('Failed to initialize OTP session. Please retry.'));
        return;
      }
      otpRequestId = session.otpRequestId;
      emit(CheckoutOtpReady(session.otpRequestId));
    } on DioException catch (e) {
      emit(
        CheckoutOtpFailure(
          ApiErrorParser.friendlyMessage(
            e,
            fallback: 'Failed to request OTP. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emit(CheckoutOtpFailure('Failed to request OTP. Please try again.'));
    }
  }

  Future<bool> resendOtp({
    required int userId,
    required bool forceEmailFallback,
  }) async {
    final currentOtpRequestId = otpRequestId;
    if (currentOtpRequestId == null || currentOtpRequestId.trim().isEmpty) {
      emit(CheckoutOtpFailure('Unable to resend OTP right now. Please retry.'));
      return false;
    }

    emit(CheckoutOtpLoading());
    try {
      final session = await _resendCheckoutOtpUseCase(
        userId: userId,
        otpRequestId: currentOtpRequestId,
        forceEmailFallback: forceEmailFallback,
      );

      if (session.otpRequestId.trim().isNotEmpty) {
        otpRequestId = session.otpRequestId;
      }
      emit(CheckoutOtpReady(otpRequestId ?? currentOtpRequestId));
      return true;
    } on DioException catch (e) {
      emit(
        CheckoutOtpFailure(
          ApiErrorParser.friendlyMessage(
            e,
            fallback: 'Failed to resend OTP. Please try again.',
          ),
        ),
      );
      return false;
    } catch (_) {
      emit(CheckoutOtpFailure('Failed to resend OTP. Please try again.'));
      return false;
    }
  }

  Future<CheckoutOtpVerificationEntity?> verifyOtp({
    required int userId,
    required String otpCode,
  }) async {
    final currentOtpRequestId = otpRequestId;
    if (currentOtpRequestId == null || currentOtpRequestId.trim().isEmpty) {
      emit(CheckoutOtpFailure('OTP session is unavailable. Please request a new code.'));
      return null;
    }

    emit(CheckoutOtpLoading());
    try {
      final verification = await _verifyCheckoutOtpUseCase(
        userId: userId,
        otpRequestId: currentOtpRequestId,
        otpCode: otpCode,
      );

      if (verification.verificationToken.trim().isEmpty) {
        emit(CheckoutOtpFailure('OTP verified but token is missing. Please retry.'));
        return null;
      }

      emit(CheckoutOtpReady(currentOtpRequestId));
      return verification;
    } on DioException catch (e) {
      emit(
        CheckoutOtpFailure(
          ApiErrorParser.friendlyMessage(
            e,
            fallback: 'Invalid OTP. Please try again.',
          ),
        ),
      );
      return null;
    } catch (_) {
      emit(CheckoutOtpFailure('Invalid OTP. Please try again.'));
      return null;
    }
  }
}
