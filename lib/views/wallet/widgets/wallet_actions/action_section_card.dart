import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class ActionSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ActionSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack15,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
