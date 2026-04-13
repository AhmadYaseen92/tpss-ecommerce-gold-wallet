import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfilePasswordChangedRequiresRelogin) {
            await AppModalAlert.show(
              context,
              title: 'Password Updated',
              message: 'For security, please login again with your new password.',
            );
            AuthSessionStore.clear();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.loginRoute,
              (route) => false,
            );
          }
          if (state is ProfileError) {
            await AppModalAlert.show(
              context,
              title: 'Validation Error',
              message: state.message,
              variant: AppModalAlertVariant.failed,
            );
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final palette = context.appPalette;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Security Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: cubit.toggleEdit,
                  icon: Icon(cubit.isEditing ? Icons.close : Icons.edit),
                  label: Text(cubit.isEditing ? 'Cancel' : 'Edit'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormHeader(
                        title: 'Security',
                        subtitle: 'Change your password and keep your account secure.',
                      ),
                      const SizedBox(height: 20),
                      const FormSectionLabel(label: 'CHANGE PASSWORD'),
                      AppTextField(
                        label: 'Current Password',
                        hint: 'Current Password',
                        prefixIcon: Icons.lock_outline,
                        controller: cubit.securityControllers['Current Password'],
                        enabled: cubit.isEditing,
                        isPassword: true,
                        obscureText: _obscureCurrent,
                        onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        requiredField: true,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Current password is required' : null,
                      ),
                      AppTextField(
                        label: 'New Password',
                        hint: 'New Password',
                        prefixIcon: Icons.lock_reset,
                        controller: cubit.securityControllers['New Password'],
                        enabled: cubit.isEditing,
                        isPassword: true,
                        obscureText: _obscureNew,
                        onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                        requiredField: true,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'New password is required' : null,
                      ),
                      AppTextField(
                        label: 'Confirm New Password',
                        hint: 'Confirm New Password',
                        prefixIcon: Icons.lock_open_outlined,
                        controller: cubit.securityControllers['Confirm New Password'],
                        enabled: cubit.isEditing,
                        isPassword: true,
                        obscureText: _obscureConfirm,
                        onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        requiredField: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Confirm password is required';
                          final newPass = cubit.securityControllers['New Password']?.text.trim() ?? '';
                          if (value.trim() != newPass) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      if (cubit.isEditing)
                        AppButton(
                          cubit: cubit,
                          label: 'Save Changes',
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              cubit.saveSecuritySettings();
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
