import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/readonly_info_row.dart';

class FeeSummaryCard extends StatelessWidget {
  final String grossAmount;
  final String feeAmount;
  final String? extraFeeLabel;
  final String? extraFeeAmount;
  final String totalAmount;
  final String totalLabel;

  const FeeSummaryCard({
    super.key,
    required this.grossAmount,
    required this.feeAmount,
    this.extraFeeLabel,
    this.extraFeeAmount,
    required this.totalAmount,
    this.totalLabel = 'You Receive',
  });

  @override
  Widget build(BuildContext context) {
    return ActionSectionCard(
      title: 'Summary',
      child: Column(
        children: [
          ReadonlyInfoRow(label: 'Gross Amount', value: grossAmount),
          ReadonlyInfoRow(label: 'Fee', value: feeAmount),
          if (extraFeeLabel != null && extraFeeAmount != null)
            ReadonlyInfoRow(label: extraFeeLabel!, value: extraFeeAmount!),
          const Divider(),
          ReadonlyInfoRow(label: totalLabel, value: totalAmount),
        ],
      ),
    );
  }
}
