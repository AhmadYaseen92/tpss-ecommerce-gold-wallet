import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/amount_mode_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class TransferAssetPage extends StatefulWidget {
  final WalletTransaction asset;

  const TransferAssetPage({super.key, required this.asset});

  @override
  State<TransferAssetPage> createState() => _TransferAssetPageState();
}

class _TransferAssetPageState extends State<TransferAssetPage> {
  WalletActionType transferType = WalletActionType.transfer;
  AmountInputMode selectedMode = AmountInputMode.quantity;

  final recipientNameController = TextEditingController();
  final recipientContactController = TextEditingController();
  final quantityController = TextEditingController();
  final weightController = TextEditingController();
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isGift = transferType == WalletActionType.gift;

    return Scaffold(
      appBar: AppBar(title: Text(isGift ? 'Gift Asset' : 'Transfer Asset')),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: 'Transfer Amount',
        summaryValue: '5 Units',
        buttonText: isGift ? 'Review Gift' : 'Review Transfer',
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            WalletAssetSummaryCard(asset: widget.asset),
            ActionSectionCard(
              title: 'Transfer Type',
              child: SegmentedButton<WalletActionType>(
                segments: const [
                  ButtonSegment(
                    value: WalletActionType.transfer,
                    label: Text('Transfer'),
                  ),
                  ButtonSegment(
                    value: WalletActionType.gift,
                    label: Text('Gift'),
                  ),
                ],
                selected: {transferType},
                onSelectionChanged: (values) {
                  setState(() => transferType = values.first);
                },
              ),
            ),
            ActionSectionCard(
              title: 'Recipient Details',
              child: Column(
                children: [
                  ActionTextField(
                    label: 'Recipient Name',
                    hintText: 'Enter recipient name',
                    controller: recipientNameController,
                  ),
                  const SizedBox(height: 12),
                  ActionTextField(
                    label: isGift
                        ? 'Recipient Email / Mobile'
                        : 'Wallet ID / Email / Mobile',
                    hintText: 'Enter recipient contact',
                    controller: recipientContactController,
                  ),
                ],
              ),
            ),
            ActionSectionCard(
              title: 'Transfer Details',
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
                      label: 'Quantity',
                      hintText: 'Enter quantity',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                    ),
                  if (selectedMode == AmountInputMode.weight)
                    ActionTextField(
                      label: 'Weight (g)',
                      hintText: 'Enter weight',
                      controller: weightController,
                      keyboardType: TextInputType.number,
                    ),
                  if (selectedMode == AmountInputMode.all)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'All available holdings will be transferred.',
                      ),
                    ),
                  const SizedBox(height: 12),
                  ActionTextField(
                    label: isGift ? 'Gift Message' : 'Transfer Note',
                    hintText: isGift
                        ? 'Write a gift message'
                        : 'Optional transfer note',
                    controller: messageController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const FeeSummaryCard(
              grossAmount: '\$6,500.00',
              feeAmount: '\$10.00',
              totalAmount: '\$6,490.00',
              totalLabel: 'Estimated Value',
            ),
          ],
        ),
      ),
    );
  }
}
