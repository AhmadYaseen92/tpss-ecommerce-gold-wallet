import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/readonly_info_row.dart';

class ActionConfirmationPage extends StatelessWidget {
  final WalletActionSummary summary;

  const ActionConfirmationPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final statusText = summary.isPending ? 'Submitted' : 'Completed';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 34,
              child: Icon(
                summary.isPending ? Icons.schedule : Icons.check,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$statusText Successfully',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(summary.title),
            const SizedBox(height: 20),
            ActionSectionCard(
              title: 'Transaction Summary',
              child: Column(
                children: [
                  ReadonlyInfoRow(label: 'Asset', value: summary.asset.name),
                  ReadonlyInfoRow(label: 'Action', value: summary.title),
                  ReadonlyInfoRow(label: 'Amount', value: summary.primaryValue),
                  ReadonlyInfoRow(label: 'Fee', value: summary.feeValue),
                  ReadonlyInfoRow(label: 'Total', value: summary.totalValue),
                  ReadonlyInfoRow(
                    label: summary.destinationLabel,
                    value: summary.destinationValue,
                  ),
                  if (summary.note != null && summary.note!.isNotEmpty)
                    ReadonlyInfoRow(label: 'Note', value: summary.note!),
                  ReadonlyInfoRow(
                    label: 'Reference',
                    value: summary.referenceNumber,
                  ),
                  ReadonlyInfoRow(
                    label: 'Date',
                    value: DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(summary.createdAt),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
