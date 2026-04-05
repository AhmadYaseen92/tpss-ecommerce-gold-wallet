

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/cubit/transfer_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/form_header.dart';
import 'package:tpss_ecommerce_gold_wallet/core/widgets/summary_row_widget.dart';

class SummaryCard extends StatelessWidget {
  final TransferCubit cubit;
  const SummaryCard({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greysShade2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormSectionLabel(label: 'TRANSFER SUMMARY'),
          const SizedBox(height: 12),
          summaryRow(context, label: 'Asset', value: cubit.selectedAsset.name),
          const SizedBox(height: 8),
          summaryRow(
            context,
            label: 'Amount',
            value: '${cubit.units.toStringAsFixed(2)} g',
          ),
          const SizedBox(height: 8),
          summaryRow(
            context,
            label: 'Price per gram',
            value: '\$${cubit.selectedAsset.pricePerUnit.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          summaryRow(
            context,
            label: 'Subtotal',
            value: '\$${cubit.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          summaryRow(
            context,
            label: 'Transfer fee (1%)',
            value: '\$${cubit.fee.toStringAsFixed(2)}',
            valueColor: AppColors.red,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.greysShade2),
          ),
          summaryRow(
            context,
            label: 'Total deducted',
            value: '\$${cubit.totalDeducted.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
