import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/action_confirmation_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/readonly_info_row.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/wallet_asset_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';

class ActionReviewPage extends StatefulWidget {
  final WalletActionSummary summary;

  const ActionReviewPage({super.key, required this.summary});

  @override
  State<ActionReviewPage> createState() => _ActionReviewPageState();
}

class _ActionReviewPageState extends State<ActionReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Review Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: 'Total',
        summaryValue: widget.summary.totalValue,
        buttonText: widget.summary.actionType == WalletActionType.sell ? 'Confirm Sell' : 'Confirm',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ActionConfirmationPage(summary: widget.summary),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            WalletAssetSummaryCard(asset: widget.summary.asset),
            ActionSectionCard(
              title: 'Action Details',
              child: Column(
                children: [
                  ReadonlyInfoRow(label: 'Action Type', value: widget.summary.title),
                  ReadonlyInfoRow(label: 'Amount', value: widget.summary.primaryValue),
                ],
              ),
            ),
            ActionSectionCard(
              title: 'Destination',
              child: Column(
                children: [
                  ReadonlyInfoRow(
                    label: widget.summary.destinationLabel,
                    value: widget.summary.destinationValue,
                  ),
                ],
              ),
            ),
            ActionSectionCard(
              title: 'Fees',
              child: Column(
                children: [
                  ReadonlyInfoRow(
                    label: 'Subtotal',
                    value: widget.summary.preview == null
                        ? '-'
                        : '\$${widget.summary.preview!.subTotalAmount.toStringAsFixed(2)}',
                  ),
                  ...?widget.summary.preview?.feeBreakdowns.map(
                    (line) => ReadonlyInfoRow(
                      label: line.feeName,
                      value: '${line.isDiscount ? '-' : ''}\$${line.appliedValue.toStringAsFixed(2)}',
                    ),
                  ),
                  ReadonlyInfoRow(
                    label: 'Discount',
                    value: widget.summary.preview == null
                        ? '\$0.00'
                        : '-\$${widget.summary.preview!.discountAmount.toStringAsFixed(2)}',
                  ),
                  ReadonlyInfoRow(label: 'Final Amount', value: widget.summary.totalValue),
                ],
              ),
            ),
            if (widget.summary.note != null && widget.summary.note!.isNotEmpty)
              ActionSectionCard(
                title: 'Note',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.summary.note!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
