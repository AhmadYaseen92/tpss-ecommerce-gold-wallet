import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/cubit/signup_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/password_requirements_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/terms_row.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/widgets/document_type_toggle_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/widgets/nationality_dropdown_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';

class SignupStep2Form extends StatefulWidget {
  const SignupStep2Form({super.key, required this.cubit});
  final SignupCubit cubit;

  @override
  State<SignupStep2Form> createState() => _SignupStep2FormState();
}

class _SignupStep2FormState extends State<SignupStep2Form> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  late final TextEditingController _idController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(text: widget.cubit.password);
    _confirmController  = TextEditingController(text: widget.cubit.confirmPassword);
    _idController       = TextEditingController(text: widget.cubit.idNumber);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override

  Future<void> _showTermsModal(String title, String message) async {
    await AppModalAlert.show(
      context,
      title: title,
      message: message,
      buttonText: 'Close',
      variant: AppModalAlertVariant.warning,
    );
  }

  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormHeader(
            title: 'Complete Your Profile',
            subtitle: 'Step 2: Verify your identity and set a secure password.',
          ),
          const SizedBox(height: 28),
          Text('Identity Verification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: palette.textPrimary),
          ),
          const SizedBox(height: 16),
          const FormSectionLabel(label: 'NATIONALITY'),
          const SizedBox(height: 8),
          BlocBuilder<SignupCubit, SignupState>(
            buildWhen: (_, curr) => curr is SignupNationalityChanged,
            builder: (context, state) => NationalityDropdown(
              selectedNationality: widget.cubit.nationality,
              onChanged: widget.cubit.updateNationality,
            ),
          ),
          const SizedBox(height: 16),
          const FormSectionLabel(label: 'DOCUMENT TYPE'),
          const SizedBox(height: 8),
          BlocBuilder<SignupCubit, SignupState>(
            buildWhen: (_, curr) => curr is SignupDocumentTypeChanged,
            builder: (context, state) => DocumentTypeToggle(
              selectedType: widget.cubit.documentType,
              onChanged: widget.cubit.updateDocumentType,
            ),
          ),
          const SizedBox(height: 16),
          const FormSectionLabel(label: 'ID NUMBER'),
          const SizedBox(height: 8),
          AppTextField(
            controller: _idController,
            label: '',
            hint: 'Enter ID Number',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: widget.cubit.updateIdNumber,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'ID number is required.'
                : null,
          ),
          const SizedBox(height: 14),
          Divider(thickness: 1, color: palette.border),
          const SizedBox(height: 14),
          Text('Security',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: palette.textPrimary),
          ),
          const SizedBox(height: 16),
          BlocBuilder<SignupCubit, SignupState>(
            buildWhen: (_, curr) => curr is SignupPasswordVisibilityChanged,
            builder: (context, state) => AppTextField(
              controller: _passwordController,
              label: '',
              hint: 'Create Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              obscureText: widget.cubit.obscurePassword,
              onToggleObscure: widget.cubit.togglePasswordVisibility,
              textInputAction: TextInputAction.next,
              onChanged: widget.cubit.updatePassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required.';
                if (v.length < 8) return 'Password must be at least 8 characters.';
                return null;
              },
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _passwordController,
            builder: (context, value, _) => Padding(
              padding: const EdgeInsets.fromLTRB(60.0, 20, 0.0, 20),
              child: PasswordRequirementsWidget(
                hasMinChars: value.text.length >= 8,
                hasUppercase: RegExp(r'[A-Z]').hasMatch(value.text),
                hasNumber: RegExp(r'[0-9]').hasMatch(value.text),
                hasSpecialChar: RegExp(r'[!@#\$%^&*]').hasMatch(value.text),
              ),
            ),
          ),
          BlocBuilder<SignupCubit, SignupState>(
            buildWhen: (_, curr) => curr is SignupPasswordVisibilityChanged,
            builder: (context, state) => AppTextField(
              controller: _confirmController,
              label: '',
              hint: 'Confirm Password',
              prefixIcon: Icons.lock_open_outlined,
              isPassword: true,
              obscureText: widget.cubit.obscureConfirm,
              onToggleObscure: widget.cubit.toggleConfirmVisibility,
              textInputAction: TextInputAction.done,
              onChanged: widget.cubit.updateConfirmPassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password.';
                if (v != widget.cubit.password) return 'Passwords do not match.';
                return null;
              },
            ),
          ),
          const SizedBox(height: 14),
          Divider(thickness: 1, color: palette.border),
          const SizedBox(height: 16),
          BlocBuilder<SignupCubit, SignupState>(
            buildWhen: (_, curr) => curr is SignupTermsChanged,
            builder: (context, state) => TermsRow(
              value: widget.cubit.termsAgreed,
              onChanged: (val) => widget.cubit.toggleTerms(val ?? false),
              prefixText: 'I have read and agree to the ',
              connectorText: ' and ',
              secondHighlightedText: 'Privacy Policy',
              suffixText: '.',
              onHighlightedTap: () => _showTermsModal(
                'Terms & Conditions',
                'By creating an account, you agree to follow platform terms, security policies, and responsible usage requirements.',
              ),
              onSecondHighlightedTap: () => _showTermsModal(
                'Privacy Policy',
                'We process your registration data to verify identity, secure your account, and provide wallet services according to applicable privacy laws.',
              ),
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            cubit: widget.cubit,
            label: 'Complete Sign Up',
            onPressed: () => widget.cubit.onSubmit(formKey),
          ),
        ],
      ),
    );
  }
}