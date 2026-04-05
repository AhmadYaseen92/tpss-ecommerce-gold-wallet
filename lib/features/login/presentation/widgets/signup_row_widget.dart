import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';

class SignUpRow extends StatelessWidget {
  const SignUpRow({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 14, color: palette.textSecondary),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.signupRoute);
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
        ),
      ],
    );
  }
}
