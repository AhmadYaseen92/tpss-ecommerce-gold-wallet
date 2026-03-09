import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/signup_cubit/signup_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/document_type_toggle_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/nationality_dropdown_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/password_strength_indicator.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class SignupStep2Form extends StatelessWidget {
  SignupStep2Form({super.key, required this.cubit});

  final SignupCubit cubit;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SignupHeader(
            title: 'Complete Your Profile',
            subtitle: 'Step 2: Verify your identity and set a secure password.',
          ),
          const SizedBox(height: 28),
          const Text(
            'Identity Verification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          const SignupSectionLabel(label: 'NATIONALITY'),
          const SizedBox(height: 8),
          NationalityDropdown(
            selectedNationality: cubit.nationality,
            onChanged: cubit.updateNationality,
          ),

          const SizedBox(height: 16),
          const SignupSectionLabel(label: 'DOCUMENT TYPE'),
          const SizedBox(height: 8),
          DocumentTypeToggle(
            selectedType: cubit.documentType,
            onChanged: cubit.updateDocumentType,
          ),
          const SizedBox(height: 16),
          const SignupSectionLabel(label: 'ID NUMBER'),
          const SizedBox(height: 8),
          AppTextField(
            initialValue: cubit.idNumber,
            label: '',
            hint: 'Enter ID Number',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: cubit.updateIdNumber,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'ID number is required.'
                : null,
          ),
          const SizedBox(height: 14),
          const Divider(thickness: 1, color: AppColors.greyShade400),
          const SizedBox(height: 14),
          const Text(
            'Security',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              AppTextField(
                initialValue: cubit.password,
                label: '',
                hint: 'Create Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                obscureText: cubit.obscurePassword,
                onToggleObscure: cubit.togglePasswordVisibility,
                textInputAction: TextInputAction.next,
                onChanged: cubit.updatePassword,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required.';
                  if (v.length < 8) {
                    return 'Password must be at least 8 characters.';
                  }
                  return null;
                },
              ),
              PasswordStrengthIndicator(
                strength: cubit.passwordStrength,
                strengthLabel: cubit.passwordStrengthLabel,
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppTextField(
            initialValue: cubit.confirmPassword,
            label: '',
            hint: 'Confirm Password',
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
              if (v != cubit.password) return 'Passwords do not match.';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Divider(thickness: 1, color: AppColors.greyBorder),
          const SizedBox(height: 16),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: cubit.termsAgreed,
                    onChanged: (val) => cubit.toggleTerms(val ?? false),
                    activeColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.greyShade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyShade600,
                      ),
                      children: [
                        TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 32),
        AppButton(
              cubit: cubit,
              label: 'Complete Sign Up',
              onPressed: () => cubit.onSubmit(formKey),
            ),
        ],
      ),
    );
  }
}
