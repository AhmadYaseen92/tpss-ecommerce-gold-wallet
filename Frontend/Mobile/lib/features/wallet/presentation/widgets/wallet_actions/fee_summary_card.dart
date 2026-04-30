import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/readonly_info_row.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';

class FeeSummaryLine {
  const FeeSummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class FeeSummaryCard extends StatelessWidget {
  final String grossAmount;
  final String feeAmount;
  final String? extraFeeLabel;
  final String? extraFeeAmount;
  final List<FeeSummaryLine> detailedFeeLines;
  final String totalAmount;
  final String totalLabel;

  const FeeSummaryCard({
    super.key,
    required this.grossAmount,
    required this.feeAmount,
    this.extraFeeLabel,
    this.extraFeeAmount,
    this.detailedFeeLines = const <FeeSummaryLine>[],
    required this.totalAmount,
    this.totalLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    return ActionSectionCard(
      title: AppLocalizations.of(context).summary,
      child: Column(
        children: [
          ReadonlyInfoRow(label: AppLocalizations.of(context).grossAmount, value: grossAmount),
          ...detailedFeeLines.map(
            (line) => ReadonlyInfoRow(label: line.label, value: line.value),
          ),
          if (detailedFeeLines.isEmpty)
            ReadonlyInfoRow(label: AppLocalizations.of(context).fee, value: feeAmount),
          if (extraFeeLabel != null && extraFeeAmount != null)
            ReadonlyInfoRow(label: extraFeeLabel!, value: extraFeeAmount!),
          const Divider(),
          ReadonlyInfoRow(label: totalLabel.isEmpty ? AppLocalizations.of(context).youReceive : totalLabel, value: totalAmount),
        ],
      ),
    );
  }
}
