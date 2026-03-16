import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/amount_mode_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class SellAssetPage extends StatefulWidget {
  final WalletActionSummary asset;

  const SellAssetPage({super.key, required this.asset});

  @override
  State<SellAssetPage> createState() => _SellAssetPageState();
}

class _SellAssetPageState extends State<SellAssetPage> {
  AmountInputMode selectedMode = AmountInputMode.quantity;
  final quantityController = TextEditingController();
  final weightController = TextEditingController();
  final noteController = TextEditingController();
  String payoutMethod = 'Wallet Cash';

  @override
  void dispose() {
    quantityController.dispose();
    weightController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String get _amountLabel {
    switch (selectedMode) {
      case AmountInputMode.quantity:
        return '${quantityController.text.trim().isEmpty ? widget.asset.asset.quantity : quantityController.text.trim()} Units';
      case AmountInputMode.weight:
        return '${weightController.text.trim().isEmpty ? widget.asset.asset.weightInGrams.toStringAsFixed(2) : weightController.text.trim()} g';
      case AmountInputMode.all:
        return 'All Holdings';
    }
  }

  void _reviewSell() {
    final summary = WalletActionSummary(
      asset: widget.asset.asset,
      actionType: WalletActionType.sell,
      title: 'Sell Asset',
      primaryValue: _amountLabel,
      feeValue: '\$50.00',
      totalValue: '\$6,250.00',
      destinationLabel: 'Payout Method',
      destinationValue: payoutMethod,
      note: noteController.text.trim(),
      referenceNumber: 'SELL-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      isPending: true,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActionReviewPage(summary: summary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Asset')),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: 'Estimated Receive',
        summaryValue: '\$6,250.00',
        buttonText: 'Review Sell',
        onPressed: _reviewSell,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            WalletAssetSummaryCard(asset: widget.asset.asset),
            ActionSectionCard(
              title: 'Sell Details',
              child: Column(
                children: [
                  AmountModeSelector(
                    selectedMode: selectedMode,
                    onChanged: (value) {
                      setState(() => selectedMode = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedMode == AmountInputMode.quantity)
                    ActionTextField(
                      label: 'Quantity to Sell',
                      hintText: 'Enter quantity',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  if (selectedMode == AmountInputMode.weight)
                    ActionTextField(
                      label: 'Weight to Sell (g)',
                      hintText: 'Enter weight in grams',
                      controller: weightController,
                      keyboardType: TextInputType.number,
                    ),
                  if (selectedMode == AmountInputMode.all)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('All available holdings will be sold.'),
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: payoutMethod,
                    items: const [
                      DropdownMenuItem(
                        value: 'Wallet Cash',
                        child: Text('Wallet Cash'),
                      ),
                      DropdownMenuItem(
                        value: 'Bank Account',
                        child: Text('Bank Account'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => payoutMethod = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payout Method',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ActionTextField(
                    label: 'Note',
                    hintText: 'Optional note',
                    controller: noteController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const FeeSummaryCard(
              grossAmount: '\$6,300.00',
              feeAmount: '\$50.00',
              totalAmount: '\$6,250.00',
            ),
          ],
        ),
      ),
    );
  }
}
