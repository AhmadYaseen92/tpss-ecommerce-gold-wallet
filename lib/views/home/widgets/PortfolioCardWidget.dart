import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class PortfolioCardWidget extends StatelessWidget {
  const PortfolioCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.change,
  });

  final String title;
  final String value;
  final String change;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.luxuryIvory, AppColors.white],
        ),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.primaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            change,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: change.startsWith('+') ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
