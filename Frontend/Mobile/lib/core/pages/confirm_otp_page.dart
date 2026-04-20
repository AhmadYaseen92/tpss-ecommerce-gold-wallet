import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/otp_input_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_otp_entities.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/presentation/cubit/checkout_otp_cubit.dart';

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
  String otp = '';
  int secondsRemaining = 30;
  Timer? timer;
  bool _isSubmitting = false;
  CheckoutOtpCubit? _checkoutOtpCubit;

  @override
  void initState() {
    super.initState();
    if (widget.useCheckoutOtpFlow) {
      _checkoutOtpCubit = context.read<CheckoutOtpCubit>();
      final userId = widget.userId;
      if (userId != null) {
        unawaited(
          _checkoutOtpCubit!.initialize(
            CheckoutOtpRequestContextEntity(
              userId: userId,
              productId: widget.productId,
              quantity: widget.quantity,
              productIds: widget.productIds ?? const [],
              forceEmailFallback: widget.forceEmailFallback,
            ),
          ),
        );
      }
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
    final scaffold = Scaffold(
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

    if (_checkoutOtpCubit == null) {
      return scaffold;
    }

    return BlocListener<CheckoutOtpCubit, CheckoutOtpState>(
      bloc: _checkoutOtpCubit,
      listener: (context, state) {
        if (state is CheckoutOtpFailure) {
          _showSnack(state.message);
          return;
        }
        if (state is CheckoutOtpReady && widget.useCheckoutOtpFlow) {
          if (secondsRemaining == 0 || timer == null || !(timer?.isActive ?? false)) {
            _startTimer();
          }
        }
      },
      child: scaffold,
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
      if (_checkoutOtpCubit == null || widget.userId == null) {
        _showSnack('Unable to resend OTP right now. Please retry.');
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final resent = await _checkoutOtpCubit!.resendOtp(
          userId: widget.userId!,
          forceEmailFallback: widget.forceEmailFallback,
        );
        if (!resent) return;
        setState(() => otp = '');
        FocusScope.of(context).unfocus();
        _startTimer();
        _showSnack('OTP resent successfully');
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

    if (_checkoutOtpCubit == null || widget.userId == null) {
      _showSnack('OTP session is unavailable. Please request a new code.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final verification = await _checkoutOtpCubit!.verifyOtp(
        userId: widget.userId!,
        otpCode: otp,
      );
      if (verification == null) {
        return;
      }

      if (!mounted) return;
      Navigator.pop(context, {
        'verified': true,
        'otpRequestId': verification.otpRequestId,
        'otpVerificationToken': verification.verificationToken,
      });
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
