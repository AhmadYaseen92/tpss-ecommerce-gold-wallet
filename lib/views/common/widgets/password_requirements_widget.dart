import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: RequirementItem(
                label: 'Min 8 chars',
                isMet: hasMinChars,
              ),
            ),
            Expanded(
              child: RequirementItem(
                label: '1 Number',
                isMet: hasNumber,
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
              ),
            ),
            Expanded(
              child: RequirementItem(
                label: 'Uppercase',
                isMet: hasUppercase,
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

  const RequirementItem({super.key, required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_outline : Icons.radio_button_unchecked,
          size: 18,
          color: isMet ? AppColors.primaryColor : AppColors.greyShade400,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? AppColors.textColor : AppColors.greyShade600,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
