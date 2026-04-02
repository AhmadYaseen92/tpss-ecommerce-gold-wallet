import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/action_confirmation_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/readonly_info_row.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class ActionReviewPage extends StatelessWidget {
  final WalletActionSummary summary;

  const ActionReviewPage({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Transaction")),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: "Total",
        summaryValue: summary.totalValue,
        buttonText: summary.actionType == WalletActionType.sell ? "Confirm & Lock Price" : "Confirm",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActionConfirmationPage(summary: summary),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Asset
            WalletAssetSummaryCard(asset: summary.asset),

            /// Action Details
            ActionSectionCard(
              title: "Action Details",
              child: Column(
                children: [
                  ReadonlyInfoRow(label: "Action Type", value: summary.title),
                  ReadonlyInfoRow(label: "Amount", value: summary.primaryValue),
                ],
              ),
            ),

            /// Destination
            ActionSectionCard(
              title: "Destination",
              child: Column(
                children: [
                  ReadonlyInfoRow(
                    label: summary.destinationLabel,
                    value: summary.destinationValue,
                  ),
                ],
              ),
            ),

            /// Fees
            ActionSectionCard(
              title: "Fees",
              child: Column(
                children: [
                  ReadonlyInfoRow(label: "Fee", value: summary.feeValue),
                  ReadonlyInfoRow(label: "Total", value: summary.totalValue),
                ],
              ),
            ),

            /// Note
            if (summary.note != null && summary.note!.isNotEmpty)
              ActionSectionCard(
                title: "Note",
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(summary.note!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
