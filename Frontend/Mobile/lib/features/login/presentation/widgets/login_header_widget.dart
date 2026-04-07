import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Securely access your gold portfolio.',
          style: TextStyle(fontSize: 14, color: palette.textSecondary),
        ),
      ],
    );
  }
}
