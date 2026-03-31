import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transfer_cubit/transfer_cubit.dart';

class AmountField extends StatelessWidget {
  final TransferCubit cubit;
  const AmountField({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.scale_rounded,
                color: palette.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cubit.amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: palette.textSecondary, fontSize: 22),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 22),
                  onChanged: cubit.updateUnits,
                ),
              ),
              Text(
                'gram',
                style: TextStyle(color: palette.textSecondary, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Available: ${cubit.selectedAsset.availableUnits.toStringAsFixed(0)} gram',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
