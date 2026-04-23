import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

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
      }
    } catch (_) {
      setState(() => _error = 'Biometric failed. Try PIN.');
    }
  }

  Future<void> _unlockWithPin() async {
    final ok = await AuthSessionStore.verifyPin(_pinController.text);
    if (!ok) {
      setState(() => _error = 'Invalid PIN, try again.');
      return;
    }
    await AuthSessionStore.setLocked(false);
    widget.onUnlocked();
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
            ElevatedButton(onPressed: _unlockWithBiometric, child: const Text('Unlock with biometrics')),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            ElevatedButton(onPressed: _unlockWithPin, child: const Text('Unlock with PIN')),
            TextButton(onPressed: widget.onLoginFallback, child: const Text('Login instead')),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}
