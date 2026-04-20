import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/otp_input_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';

class ConfirmOtpPage extends StatefulWidget {
  const ConfirmOtpPage({
    super.key,
    this.title,
    this.subtitle,
    this.userId,
    this.productId,
    this.quantity,
    this.productIds,
    this.forceEmailFallback = false,
    this.useCheckoutOtpFlow = false,
  });

  final String? title;
  final String? subtitle;
  final int? userId;
  final int? productId;
  final int? quantity;
  final List<int>? productIds;
  final bool forceEmailFallback;
  final bool useCheckoutOtpFlow;

  @override
  State<ConfirmOtpPage> createState() => _ConfirmOtpPageState();
}

class _ConfirmOtpPageState extends State<ConfirmOtpPage> {
  final Dio _dio = InjectionContainer.dio();
  String otp = '';
  int secondsRemaining = 30;
  Timer? timer;
  String? _otpRequestId;
  String? _verificationToken;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.useCheckoutOtpFlow) {
      unawaited(_requestCheckoutOtp());
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Confirm OTP',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                Text(
                  widget.title ?? 'OTP Verification Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  widget.subtitle ??
                      'Enter the 6-digit code sent to your registered WhatsApp number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                OtpInputWidget(
                  value: otp,
                  onChanged: (value) {
                    setState(() => otp = value);
                  },
                  onCompleted: (value) {
                    setState(() => otp = value);
                    _verifyOtp();
                  },
                ),

                const SizedBox(height: 18),

                secondsRemaining > 0
                    ? Text(
                        'Resend available in 00:${secondsRemaining.toString().padLeft(2, '0')}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: _resendOtp,
                        child: const Text('Resend OTP'),
                      ),

                const Spacer(),

                AppButton(
                  label: 'Verify OTP',
                  icon: Icons.verified_user_outlined,
                  onPressed: otp.length == 6 && !_isSubmitting ? _verifyOtp : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    secondsRemaining = 30;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_isSubmitting) return;

    if (widget.useCheckoutOtpFlow) {
      if (_otpRequestId == null || widget.userId == null) {
        _showSnack('Unable to resend OTP right now. Please retry.');
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        await _dio.post(
          '/checkout/otp/resend',
          data: {
            'userId': widget.userId,
            'otpRequestId': _otpRequestId,
            'forceEmailFallback': widget.forceEmailFallback,
          },
        );
        setState(() => otp = '');
        FocusScope.of(context).unfocus();
        _startTimer();
        _showSnack('OTP resent successfully');
      } on DioException catch (e) {
        _showSnack(
          ApiErrorParser.friendlyMessage(
            e,
            fallback: 'Failed to resend OTP. Please try again.',
          ),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }

    setState(() {
      otp = '';
    });

    FocusScope.of(context).unfocus();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP resent successfully'),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    if (otp.length < 6) {
      _showSnack('Please enter the full 6-digit OTP.');
      return;
    }

    if (!widget.useCheckoutOtpFlow) {
      Navigator.pop(context, true);
      return;
    }

    if (_otpRequestId == null || widget.userId == null) {
      _showSnack('OTP session is unavailable. Please request a new code.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _dio.post(
        '/checkout/otp/verify',
        data: {
          'userId': widget.userId,
          'otpRequestId': _otpRequestId,
          'otpCode': otp,
        },
      );
      final payload = response.data as Map<String, dynamic>? ?? const {};
      final data = payload['data'] as Map<String, dynamic>? ?? const {};
      final verificationToken = (data['verificationToken'] ?? '').toString();
      if (verificationToken.isEmpty) {
        _showSnack('OTP verified but token is missing. Please retry.');
        return;
      }

      _verificationToken = verificationToken;
      if (!mounted) return;
      Navigator.pop(context, {
        'verified': true,
        'otpRequestId': _otpRequestId,
        'otpVerificationToken': _verificationToken,
      });
    } on DioException catch (e) {
      _showSnack(
        ApiErrorParser.friendlyMessage(
          e,
          fallback: 'Invalid OTP. Please try again.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _requestCheckoutOtp() async {
    if (widget.userId == null) {
      _showSnack('Missing user information for OTP request.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await _dio.post(
        '/checkout/otp/request',
        data: {
          'userId': widget.userId,
          if (widget.productIds != null && widget.productIds!.isNotEmpty) 'productIds': widget.productIds,
          if (widget.productId != null) 'productId': widget.productId,
          if (widget.quantity != null) 'quantity': widget.quantity,
          'forceEmailFallback': widget.forceEmailFallback,
        },
      );
      final payload = response.data as Map<String, dynamic>? ?? const {};
      final data = payload['data'] as Map<String, dynamic>? ?? const {};
      _otpRequestId = (data['otpRequestId'] ?? '').toString();
      if (_otpRequestId == null || _otpRequestId!.isEmpty) {
        _showSnack('Failed to initialize OTP session. Please retry.');
        return;
      }
      _startTimer();
    } on DioException catch (e) {
      _showSnack(
        ApiErrorParser.friendlyMessage(
          e,
          fallback: 'Failed to request OTP. Please try again.',
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
