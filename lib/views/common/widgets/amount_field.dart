import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transfer_cubit/transfer_cubit.dart';

class AmountField extends StatelessWidget {
  final TransferCubit cubit;
  const AmountField({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greysShade2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.scale_rounded,
                color: AppColors.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cubit.amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: AppColors.grey, fontSize: 22),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 22),
                  onChanged: cubit.updateUnits,
                ),
              ),
              Text(
                'gram',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 16),
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
              ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
