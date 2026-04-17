import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/otp_input_widget.dart';

class ConfirmOtpPage extends StatefulWidget {
  const ConfirmOtpPage({super.key, this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  State<ConfirmOtpPage> createState() => _ConfirmOtpPageState();
}

class _ConfirmOtpPageState extends State<ConfirmOtpPage> {
  String otp = '';
  int secondsRemaining = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
        title: const Text('Confirm OTP'),
        centerTitle: true,
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
                  onPressed: otp.length == 6 ? _verifyOtp : null,
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

  void _resendOtp() {
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

  void _verifyOtp() {
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the full 6-digit OTP.'),
        ),
      );
      return;
    }

    Navigator.pop(context, true);
  }
}