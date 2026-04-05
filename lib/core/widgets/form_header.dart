import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';

class FormHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const FormHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: palette.textSecondary),
        ),
      ],
    );
  }
}

class FormSectionLabel extends StatelessWidget {
  final String label;

  const FormSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
