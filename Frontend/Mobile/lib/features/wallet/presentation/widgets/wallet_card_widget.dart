import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

class WalletCardWidget extends StatelessWidget {
  final String walletName;
  final bool isVerified;
  final double totalWeightInGrams;
  final double totalWeightInKg;
  final double totalWeightInOz;
  final String totalMarketValue;
  final int totalHoldings;
  final String change;
  final IconData icon;
  final List transactions;
  final WalletCategory category;
  final String? note;

  const WalletCardWidget({
    super.key,
    required this.walletName,
    required this.isVerified,
    required this.totalWeightInGrams,
    required this.totalWeightInKg,
    required this.totalWeightInOz,
    required this.totalMarketValue,
    required this.totalHoldings,
    required this.change,
    required this.icon,
    required this.transactions,
    required this.category,
    this.note,
  });

  bool get _isPositive => change.startsWith('+');

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceMuted, palette.surface],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: palette.primary, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: palette.primary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: palette.surface, size: 20.0),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(walletName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: palette.textPrimary)),
                    if (isVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Verified',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.green, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    AppRoutes.walletItemsRoute,
                    arguments: {
                      'transactions': transactions,
                      'category': category,
                    },
                  );
                },
                child: Text('View Details', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text('Total Weight', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textSecondary)),
          const SizedBox(height: 6),
          Text(
            '${totalWeightInGrams.toStringAsFixed(2)} g',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: palette.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _unitBox(context, 'g', totalWeightInGrams.toStringAsFixed(2)),
              const SizedBox(width: 10),
              _unitBox(context, 'kg', totalWeightInKg.toStringAsFixed(2)),
              const SizedBox(width: 10),
              _unitBox(context, 'oz', totalWeightInOz.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(context, 'Total Market Value', totalMarketValue),
          const SizedBox(height: 10),
          _infoRow(context, 'Total Holdings', '$totalHoldings Assets'),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('24h Change', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textSecondary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: (_isPositive ? AppColors.green : AppColors.red).withAlpha(20),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: (_isPositive ? AppColors.green : AppColors.red).withAlpha(70)),
                ),
                child: Text(
                  change,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _isPositive ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(height: 14.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: palette.primary.withAlpha(40)),
              ),
              child: Text(note!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textSecondary, height: 1.4)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _unitBox(BuildContext context, String unit, String value) {
    final palette = context.appPalette;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.primary.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: palette.textPrimary)),
            Text(unit, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: palette.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String title, String value) {
    final palette = context.appPalette;

    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: palette.textSecondary)),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: palette.textPrimary)),
      ],
    );
  }
}
