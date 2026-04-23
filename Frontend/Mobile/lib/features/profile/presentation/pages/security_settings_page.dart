import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  bool _quickUnlock = AuthSessionStore.quickUnlockEnabled;
  bool _biometric = AuthSessionStore.biometricEnabled;
  final _pinController = TextEditingController();

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4 || pin.length > 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be 4-6 digits.')));
      return;
    }

    await AuthSessionStore.setPin(pin);
    await AuthSessionStore.setQuickUnlockEnabled(true);
    if (!mounted) return;
    setState(() => _quickUnlock = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated successfully.')));
  }

  Future<void> _removePin() async {
    await AuthSessionStore.removePin();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN removed.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable quick unlock'),
            subtitle: const Text('Lock app after 5 min in background and unlock with biometric/PIN.'),
            value: _quickUnlock,
            onChanged: (value) async {
              await AuthSessionStore.setQuickUnlockEnabled(value);
              setState(() => _quickUnlock = value);
            },
          ),
          SwitchListTile(
            title: const Text('Enable biometric'),
            subtitle: const Text('Use biometric to unlock local session.'),
            value: _biometric,
            onChanged: (value) async {
              await AuthSessionStore.setBiometricEnabled(value);
              setState(() => _biometric = value);
            },
          ),
          const Divider(),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Set or change PIN (4-6 digits)'),
          ),
          ElevatedButton(onPressed: _savePin, child: const Text('Save PIN')),
          TextButton(onPressed: _removePin, child: const Text('Remove PIN')),
        ],
      ),
    );
  }
}
