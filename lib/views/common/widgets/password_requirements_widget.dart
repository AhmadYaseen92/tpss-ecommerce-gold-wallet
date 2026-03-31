import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final bool hasMinChars;
  final bool hasNumber;
  final bool hasSpecialChar;
  final bool hasUppercase;

  const PasswordRequirementsWidget({
    super.key,
    required this.hasMinChars,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.hasUppercase,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RequirementItem(
                label: 'Min 8 chars',
                isMet: hasMinChars,
                palette: palette,
              ),
            ),
            Expanded(
              child: RequirementItem(
                label: '1 Number',
                isMet: hasNumber,
                palette: palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RequirementItem(
                label: '1 Special char',
                isMet: hasSpecialChar,
                palette: palette,
              ),
            ),
            Expanded(
              child: RequirementItem(
                label: 'Uppercase',
                isMet: hasUppercase,
                palette: palette,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RequirementItem extends StatelessWidget {
  final String label;
  final bool isMet;
  final AppPalette palette;

  const RequirementItem({
    super.key,
    required this.label,
    required this.isMet,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 18,
          color: isMet ? palette.primary : palette.border,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? palette.textPrimary : palette.textSecondary,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
