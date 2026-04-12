import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/cubit/login_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/widgets/remember_me_row_widget.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<LoginCubit>(context);
    final palette = context.appPalette;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Server: ${cubit.currentBaseUrl}',
                style: TextStyle(fontSize: 12, color: palette.textSecondary),
              ),
              TextButton.icon(
                onPressed: () => _openServerSettings(context, cubit),
                icon: const Icon(Icons.settings_ethernet, size: 18),
                label: const Text('Server Settings'),
              ),
            ],
          ),
          if (cubit.currentBaseUrl.contains('localhost') ||
              cubit.currentBaseUrl.contains('127.0.0.1'))
            Text(
              '⚠️ localhost works only on emulator/simulator. Use your LAN IP for real device.',
              style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            ),
          Text(
            'Dev quick test prefill: investor@goldwallet.com / Password@123',
            style: TextStyle(fontSize: 12, color: palette.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          AppTextField(
            initialValue: cubit.identifier,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email.';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email.';
              }
              return null;
            },
            onChanged: cubit.updateIdentifier,
          ),
          const SizedBox(height: 18),
          Text(
            'Password',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          AppTextField(
            initialValue: cubit.password,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            obscureText: cubit.obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            onToggleObscure: cubit.togglePasswordVisibility,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
            onChanged: cubit.updatePassword,
          ),
          const SizedBox(height: 14),
          RememberMeRow(cubit: cubit),
          const SizedBox(height: 24),
          AppButton(
            cubit: cubit,
            label: 'Log In',
            onPressed: () => cubit.onLoginPressed(formKey),
          ),
        ],
      ),
    );
  }

  Future<void> _openServerSettings(BuildContext context, LoginCubit cubit) async {
    final baseUrlController = TextEditingController(text: cubit.currentBaseUrl);
    final timeoutController = TextEditingController(
      text: cubit.currentTimeoutSeconds.toString(),
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Server Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'http://192.168.1.2:5095/api',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeoutController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Timeout (seconds)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final timeout = int.tryParse(timeoutController.text.trim()) ?? 20;
                cubit.updateServerConfig(
                  baseUrl: baseUrlController.text.trim(),
                  timeoutSeconds: timeout,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                final timeout = int.tryParse(timeoutController.text.trim()) ?? 20;
                cubit.updateServerConfig(
                  baseUrl: baseUrlController.text.trim(),
                  timeoutSeconds: timeout,
                );
                cubit.checkServerConnection();
              },
              child: const Text('Save & Test'),
            ),
          ],
        );
      },
    );
  }
}
