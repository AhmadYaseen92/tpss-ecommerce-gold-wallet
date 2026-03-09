import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;
  final String strengthLabel;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.strengthLabel,
  });

  Color get _color {
    if (strength <= 0.25) return AppColors.red;
    if (strength <= 0.5) return AppColors.primaryColor;
    if (strength <= 0.75) return AppColors.orange;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0.0) return const SizedBox.shrink();
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            final filled = strength >= (index + 1) * 0.25;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: filled
                      ? _color
                      : AppColors.greyShade400.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            strengthLabel,
            style: TextStyle(
              fontSize: 12,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
