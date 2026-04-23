import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';

class SecuritySetupPage extends StatefulWidget {
  const SecuritySetupPage({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  State<SecuritySetupPage> createState() => _SecuritySetupPageState();
}

class _SecuritySetupPageState extends State<SecuritySetupPage> {
  bool _biometric = false;
  bool _deviceHasBiometric = false;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!AppReleaseConfig.quickUnlockAllowed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _skip();
      });
      return;
    }
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final auth = LocalAuthentication();
    final supported = await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!mounted) return;
    setState(() => _deviceHasBiometric = supported);
  }

  Future<void> _complete() async {
    final pin = _pinController.text.trim();
    final canUseBiometric = AppReleaseConfig.loginByBiometricEnabled;
    final canUsePin = AppReleaseConfig.loginByPinEnabled;
    final wantsBiometric = canUseBiometric && _biometric && _deviceHasBiometric;
    final hasPin = canUsePin && pin.isNotEmpty;
    if (canUsePin && pin.isNotEmpty && (pin.length < 4 || pin.length > 6)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 4-6 digits')));
      return;
    }

    if (!canUseBiometric && !canUsePin) {
      await _skip();
      return;
    }

    if (!wantsBiometric && !hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable biometric or set a PIN to use quick unlock.')),
      );
      return;
    }

    if (canUsePin && pin.isNotEmpty) {
      await AuthSessionStore.setPin(pin);
    } else if (!canUsePin && AuthSessionStore.hasPin) {
      await AuthSessionStore.removePin();
    }
    await AuthSessionStore.setBiometricEnabled(wantsBiometric);
    await AuthSessionStore.setQuickUnlockEnabled(AuthSessionStore.hasUnlockMethod);
    await AuthSessionStore.setSecuritySetupDone(true);
    await AuthSessionStore.setLocked(false);

    if (!mounted) return;
    widget.onDone?.call();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.homeRoute, (_) => false);
  }

  Future<void> _skip() async {
    await AuthSessionStore.setQuickUnlockEnabled(false);
    await AuthSessionStore.setBiometricEnabled(false);
    await AuthSessionStore.removePin();
    await AuthSessionStore.setSecuritySetupDone(true);
    if (!mounted) return;
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
            if (AppReleaseConfig.loginByBiometricEnabled)
              SwitchListTile(
                title: const Text('Enable Biometric'),
                subtitle: Text(_deviceHasBiometric ? 'Use Face ID / Touch ID to unlock.' : 'Biometric not available.'),
                value: _biometric,
                onChanged: _deviceHasBiometric ? (v) => setState(() => _biometric = v) : null,
              ),
            if (AppReleaseConfig.loginByPinEnabled)
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Set PIN (4-6 digits)'),
              ),
            if (!AppReleaseConfig.loginByBiometricEnabled && !AppReleaseConfig.loginByPinEnabled)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Quick unlock is disabled by admin configuration.'),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _skip,
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
