import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class MainProfileWidget extends StatelessWidget {
  const MainProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/172558196?v=4'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Omar Khader',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  border: Border.all(color: AppColors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: AppColors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('OmarKhader@TradePSS.com', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSecondary)),
          const SizedBox(height: 4),
          Text('00962 79 123 4567', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSecondary)),
        ],
      ),
    );
  }
}
