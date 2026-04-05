import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/password_requirements_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/form_header.dart';

class SetNewPasswordForm extends StatelessWidget {
  SetNewPasswordForm({super.key, required this.cubit});

  final ForgotPasswordCubit cubit;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Form(
      key: formKey,
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormHeader(
                title: 'Set New Password',
                subtitle:
                    'Please create a secure password to access your Imseeh Gold Wallet.',
              ),
              const SizedBox(height: 28),
              Text(
                'New Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                builder: (context, state) {
                  return AppTextField(
                    initialValue: cubit.newPassword,
                    label: '',
                    hint: 'Enter new password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: cubit.obscureNew,
                    onToggleObscure: cubit.toggleNewPasswordVisibility,
                    textInputAction: TextInputAction.next,
                    onChanged: cubit.updateNewPassword,
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Password is required.';
                      if (v.length < 8) {
                        return 'Password must be at least 8 characters.';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                builder: (context, state) {
                  return AppTextField(
                    initialValue: cubit.confirmPassword,
                    label: '',
                    hint: 'Confirm new password',
                    prefixIcon: Icons.lock_open_outlined,
                    isPassword: true,
                    obscureText: cubit.obscureConfirm,
                    onToggleObscure: cubit.toggleConfirmVisibility,
                    textInputAction: TextInputAction.done,
                    onChanged: cubit.updateConfirmPassword,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password.';
                      }
                      if (v != cubit.newPassword)
                        return 'Passwords do not match.';
                      return null;
                    },
                  );
                },
              ),
              if (cubit.passwordStrength > 0) ...[
                BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(60.0, 20, 0.0, 0),
                      child: PasswordRequirementsWidget(
                        hasMinChars: cubit.hasMinChars,
                        hasNumber: cubit.hasNumber,
                        hasSpecialChar: cubit.hasSpecialChar,
                        hasUppercase: cubit.hasUppercase,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          AppButton(
            label: 'Reset Password',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                cubit.resetPassword(cubit.newPassword, cubit.confirmPassword);
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
