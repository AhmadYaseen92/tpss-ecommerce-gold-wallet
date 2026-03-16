import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class ReadonlyInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ReadonlyInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.darkGrey),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
