import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/forgot_password/widgets/otp_input_widget.dart';

class VerifyOtpForm extends StatelessWidget {
  const VerifyOtpForm({super.key, required this.cubit});

  final ForgotPasswordCubit cubit;

  @override
  Widget build(BuildContext context) {
    final seconds = cubit.secondsRemaining;
    final canResend = seconds == 0;
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text(
          'Verify OTP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Please enter the 6-digit code sent to',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: palette.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          cubit.maskedTarget,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 36),
        OtpInputWidget(
          value: cubit.otp,
          onChanged: cubit.updateOtp,
          onCompleted: cubit.updateOtp,
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Resend code in  ',
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
            Text(
              cubit.formatTimer(seconds),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: canResend ? cubit.resendOtp : null,
          child: Text(
            'Resend Code',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: canResend
                  ? palette.primary
                  : palette.border,
              decoration: canResend
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 40),
        AppButton(
          label: 'Verify',
          icon: Icons.check_circle_outline,
          onPressed: cubit.verifyOtp,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
