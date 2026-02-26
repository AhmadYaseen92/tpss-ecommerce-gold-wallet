import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';

class BadgeRatingRow extends StatelessWidget {
  final Color colorText;
  final Color textMuted;

  const BadgeRatingRow({required this.colorText, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: colorText.withOpacity(0.15),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: colorText.withOpacity(0.35)),
          ),
          child: Text(
            'BEST SELLER',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: colorText,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.star_rounded, color: colorText, size: 16),
        const SizedBox(width: 2),
        const Text(
          '4.9',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 4),
        Text('(128 reviews)', style: TextStyle(fontSize: 12, color: textMuted)),
      ],
    );
  }
}