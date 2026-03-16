import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class PortfolioCardWidget extends StatelessWidget {
  const PortfolioCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.availableCash,
  });

  final String title;
  final String value;
  final String change;
  final String? availableCash;

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
            color: AppColors.shadowBlack,
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title + ": ",
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
                  fontSize: 20,
                ),
              ),
            ],
          ),
          if (availableCash != null && availableCash!.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Cash:'),
                Text(
                  availableCash!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Gold Investment: "),
              Text(
                change,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: change.startsWith('+')
                      ? AppColors.green
                      : AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Silver Investment: "),
              Text(
                change,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
