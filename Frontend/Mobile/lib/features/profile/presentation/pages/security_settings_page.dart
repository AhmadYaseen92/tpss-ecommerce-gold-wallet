import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  bool _biometric = false;
  bool _hasBiometricSupport = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final Dio _dio = InjectionContainer.dio();

  @override
  void initState() {
    super.initState();
    _biometric = AppReleaseConfig.loginByBiometricEnabled && AuthSessionStore.biometricEnabled;
    _pinController.text = (AppReleaseConfig.loginByPinEnabled && AuthSessionStore.hasPin) ? '••••' : '';
    _hydrateSecurityPolicy();
    _checkBiometricSupport();
  }

  Future<void> _hydrateSecurityPolicy() async {
    await AuthSessionStore.applyAdminUnlockPolicy();
    if (!mounted) return;
    setState(() {
      _biometric = AppReleaseConfig.loginByBiometricEnabled && AuthSessionStore.biometricEnabled;
      _pinController.text = (AppReleaseConfig.loginByPinEnabled && AuthSessionStore.hasPin) ? '••••' : '';
    });
  }

  Future<void> _checkBiometricSupport() async {
    final auth = LocalAuthentication();
    final supported = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!mounted) return;
    setState(() => _hasBiometricSupport = supported);
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled && !_hasBiometricSupport) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric is not supported on this device.')),
      );
      return;
    }

    await AuthSessionStore.setBiometricEnabled(enabled);
    if (enabled && !AuthSessionStore.quickUnlockEnabled) {
      await AuthSessionStore.setQuickUnlockEnabled(true);
    }
    setState(() {
      _biometric = AuthSessionStore.biometricEnabled;
    });
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4 || pin.length > 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 4-6 digits.')));
      return;
    }

    await AuthSessionStore.setPin(pin);
    _pinController.text = '••••';
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated.')));
  }

  Future<void> _removePin() async {
    await AuthSessionStore.removePin();
    _pinController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AuthSessionStore.hasUnlockMethod
              ? 'PIN removed. Biometric unlock still active.'
              : 'PIN removed. Biometric/PIN unlock is now disabled.',
        ),
      ),
    );
  }

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
            await AuthSessionStore.clearAll();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.loginRoute, (route) => false);
          }
          if (state is ProfileError) {
            await AppModalAlert.show(
              context,
              title: 'Error',
              message: state.message,
              variant: AppModalAlertVariant.failed,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('Security')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Local Session Protection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                if (AppReleaseConfig.loginByBiometricEnabled)
                  SwitchListTile(
                    title: const Text('Biometric unlock'),
                    subtitle: Text(_hasBiometricSupport ? 'Use Face ID / Touch ID.' : 'Biometric not available'),
                    value: _biometric,
                    onChanged: _toggleBiometric,
                  ),
                const SizedBox(height: 8),
                if (AppReleaseConfig.loginByPinEnabled) ...[
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    obscureText: true,
                    onTap: () {
                      if (_pinController.text == '••••') {
                        _pinController.clear();
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Set / Change PIN (4-6 digits)'),
                  ),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: _savePin, child: const Text('Save PIN'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextButton(onPressed: AuthSessionStore.hasPin ? _removePin : null, child: const Text('Remove PIN'))),
                    ],
                  ),
                ],
                if (!AppReleaseConfig.loginByBiometricEnabled && !AppReleaseConfig.loginByPinEnabled)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Biometric and PIN quick unlock are disabled by admin.'),
                  ),
                const Divider(height: 32),
                const Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Current Password',
                        hint: 'Current Password',
                        prefixIcon: Icons.lock_outline,
                        controller: cubit.securityControllers['Current Password'],
                        enabled: true,
                        isPassword: true,
                        obscureText: _obscureCurrent,
                        onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Current password is required' : null,
                      ),
                      AppTextField(
                        label: 'New Password',
                        hint: 'New Password',
                        prefixIcon: Icons.lock_reset,
                        controller: cubit.securityControllers['New Password'],
                        enabled: true,
                        isPassword: true,
                        obscureText: _obscureNew,
                        onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'New password is required' : null,
                      ),
                      AppTextField(
                        label: 'Confirm New Password',
                        hint: 'Confirm New Password',
                        prefixIcon: Icons.lock,
                        controller: cubit.securityControllers['Confirm New Password'],
                        enabled: true,
                        isPassword: true,
                        obscureText: _obscureConfirm,
                        onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Confirm password is required';
                          if (value.trim() != (cubit.securityControllers['New Password']?.text.trim() ?? '')) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                AppButton(
                  cubit: cubit,
                  label: 'Update Password',
                  onPressed: () async {
                    if (_passwordFormKey.currentState?.validate() ?? false) {
                      await _submitPasswordWithOtpPolicy(cubit);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitPasswordWithOtpPolicy(ProfileCubit cubit) async {
    if (!AppReleaseConfig.isOtpRequiredForAction('change_password')) {
      await cubit.saveSecuritySettings();
      return;
    }

    final userId = AuthSessionStore.userId;
    if (userId == null) {
      await AppModalAlert.show(
        context,
        title: 'Error',
        message: 'No logged-in user.',
        variant: AppModalAlertVariant.failed,
      );
      return;
    }

    try {
      final actionReferenceId = 'profile:change_password:$userId';
      final requestResp = await _dio.post(
        '/otp/request',
        data: {
          'userId': userId,
          'actionType': 'change_password',
          'actionReferenceId': actionReferenceId,
        },
      );
      final requestData = (requestResp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final otpRequestId = (requestData['otpRequestId'] ?? '').toString().trim();
      if (otpRequestId.isEmpty) {
        throw StateError('OTP request failed.');
      }

      final otpCode = await _showOtpInputDialog();
      if (!mounted || otpCode == null || otpCode.length < 6) return;

      final verifyResp = await _dio.post(
        '/otp/verify',
        data: {
          'userId': userId,
          'otpRequestId': otpRequestId,
          'otpCode': otpCode,
        },
      );
      final verifyData = (verifyResp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final verificationToken = (verifyData['verificationToken'] ?? '').toString().trim();
      final verifiedRef = (verifyData['actionReferenceId'] ?? '').toString().trim();
      if (verificationToken.isEmpty) {
        throw StateError('OTP verification failed.');
      }

      await cubit.saveSecuritySettings(
        otpVerificationToken: verificationToken,
        otpActionReferenceId: verifiedRef.isEmpty ? actionReferenceId : verifiedRef,
      );
    } catch (e) {
      await AppModalAlert.show(
        context,
        title: 'OTP Failed',
        message: _extractDisplayErrorMessage(e),
        variant: AppModalAlertVariant.failed,
      );
    }
  }

  Future<String?> _showOtpInputDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm OTP'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'OTP Code'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  String _extractDisplayErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = (data['message'] ?? data['error'] ?? '').toString().trim();
        if (message.isNotEmpty) return message;
        final nested = data['data'];
        if (nested is Map) {
          final nestedMessage = (nested['message'] ?? nested['error'] ?? '').toString().trim();
          if (nestedMessage.isNotEmpty) return nestedMessage;
        }
      }
      if (data is String && data.trim().isNotEmpty) return data.trim();
    }
    return 'Something went wrong. Please try again.';
  }
}
