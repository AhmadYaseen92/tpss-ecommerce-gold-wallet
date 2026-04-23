import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';

class SecuritySetupPage extends StatefulWidget {
  const SecuritySetupPage({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  State<SecuritySetupPage> createState() => _SecuritySetupPageState();
}

class _SecuritySetupPageState extends State<SecuritySetupPage> {
  bool _biometric = false;
  final _pinController = TextEditingController();

  Future<void> _complete() async {
    if (_pinController.text.isNotEmpty && (_pinController.text.length < 4 || _pinController.text.length > 6)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 4-6 digits')));
      return;
    }

    if (_pinController.text.isNotEmpty) {
      await AuthSessionStore.setPin(_pinController.text);
      await AuthSessionStore.setQuickUnlockEnabled(true);
    }
    await AuthSessionStore.setBiometricEnabled(_biometric);
    await AuthSessionStore.setLocked(false);

    if (!mounted) return;
    widget.onDone?.call();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeRoute, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure your app')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Biometric'),
              value: _biometric,
              onChanged: (v) => setState(() => _biometric = v),
            ),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Set PIN (4-6 digits)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await AuthSessionStore.setQuickUnlockEnabled(false);
                      await AuthSessionStore.removePin();
                      await AuthSessionStore.setBiometricEnabled(false);
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeRoute, (_) => false);
                    },
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _complete, child: const Text('Save'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
