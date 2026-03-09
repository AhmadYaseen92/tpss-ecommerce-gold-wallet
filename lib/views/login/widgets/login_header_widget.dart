import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Securely access your gold portfolio.',
          style: TextStyle(fontSize: 14, color: AppColors.greyShade600),
        ),
      ],
    );
  }
}