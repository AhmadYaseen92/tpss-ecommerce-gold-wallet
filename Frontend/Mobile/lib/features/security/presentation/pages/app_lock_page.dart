import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key, required this.onUnlocked, required this.onLoginFallback});

  final VoidCallback onUnlocked;
  final VoidCallback onLoginFallback;

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  final _pinController = TextEditingController();
  String? _error;
  bool _showPin = false;
  int _failedAttempts = 0;

  bool get _canUseBiometric => AuthSessionStore.quickUnlockEnabled && AuthSessionStore.biometricEnabled;
  bool get _canUsePin => AuthSessionStore.quickUnlockEnabled && AuthSessionStore.hasPin;

  @override
  void initState() {
    super.initState();
    if (_canUseBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlockWithBiometric());
    } else if (_canUsePin) {
      _showPin = true;
    }
  }

  Future<void> _unlockWithBiometric() async {
    final auth = LocalAuthentication();
    try {
      final ok = await auth.authenticate(
        localizedReason: 'Unlock Gold Wallet',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (ok) {
        await AuthSessionStore.setLocked(false);
        widget.onUnlocked();
      } else if (_canUsePin) {
        _registerFailure();
        setState(() {
          _showPin = true;
          _error = 'Biometric cancelled. Use PIN.';
        });
      } else {
        _registerFailure();
      }
    } catch (_) {
      _registerFailure();
      setState(() {
        _showPin = _canUsePin;
        _error = _canUsePin ? 'Biometric failed. Try PIN.' : 'Biometric failed.';
      });
    }
  }

  Future<void> _unlockWithPin() async {
    final ok = await AuthSessionStore.verifyPin(_pinController.text.trim());
    if (!ok) {
      _registerFailure();
      setState(() => _error = 'Invalid PIN, try again.');
      return;
    }
    await AuthSessionStore.setLocked(false);
    widget.onUnlocked();
  }

  void _registerFailure() {
    _failedAttempts++;
    if (_failedAttempts < 3) return;
    AppModalAlert.show(
      context,
      title: 'Too many attempts',
      message:
          'You have exceeded 3 unlock attempts. For security, please login again. '
          'Your PIN has been reset and you can set a new one from Security Settings.',
      variant: AppModalAlertVariant.failed,
    ).then((_) => widget.onLoginFallback());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('App Locked', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_canUseBiometric)
              ElevatedButton(onPressed: _unlockWithBiometric, child: const Text('Unlock with biometrics')),
            if (_showPin || (!_canUseBiometric && _canUsePin)) ...[
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'PIN'),
              ),
              ElevatedButton(onPressed: _unlockWithPin, child: const Text('Unlock with PIN')),
            ],
            TextButton(
              onPressed: widget.onLoginFallback,
              child: const Text('Login Via Username and Password'),
            ),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}
