import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/amount_mode_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class ConvertAssetPage extends StatefulWidget {
  final WalletTransaction asset;

  const ConvertAssetPage({super.key, required this.asset});

  @override
  State<ConvertAssetPage> createState() => _ConvertAssetPageState();
}

class _ConvertAssetPageState extends State<ConvertAssetPage> {
  ConvertTargetType targetType = ConvertTargetType.cash;
  AmountInputMode selectedMode = AmountInputMode.quantity;

  final quantityController = TextEditingController();
  final weightController = TextEditingController();
  final walletAddressController = TextEditingController();

  String cashDestination = 'Wallet Cash';
  String cryptoType = 'USDT';

  @override
  Widget build(BuildContext context) {
    final isCrypto = targetType == ConvertTargetType.crypto;

    return Scaffold(
      appBar: AppBar(title: const Text('Convert Asset')),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: isCrypto ? 'Estimated Crypto' : 'Estimated Cash',
        summaryValue: isCrypto ? '0.091 BTC' : '\$6,250.00',
        buttonText: 'Review Conversion',
        onPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            WalletAssetSummaryCard(asset: widget.asset),
            ActionSectionCard(
              title: 'Convert To',
              child: SegmentedButton<ConvertTargetType>(
                segments: const [
                  ButtonSegment(
                    value: ConvertTargetType.cash,
                    label: Text('Cash'),
                  ),
                  ButtonSegment(
                    value: ConvertTargetType.crypto,
                    label: Text('Crypto'),
                  ),
                ],
                selected: {targetType},
                onSelectionChanged: (values) {
                  setState(() => targetType = values.first);
                },
              ),
            ),
            ActionSectionCard(
              title: 'Conversion Details',
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
                      child: Text('All available holdings will be converted.'),
                    ),
                  const SizedBox(height: 12),
                  if (!isCrypto)
                    DropdownButtonFormField<String>(
                      value: cashDestination,
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
                          setState(() => cashDestination = value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cash Destination',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (isCrypto) ...[
                    DropdownButtonFormField<String>(
                      value: cryptoType,
                      items: const [
                        DropdownMenuItem(value: 'USDT', child: Text('USDT')),
                        DropdownMenuItem(value: 'BTC', child: Text('BTC')),
                        DropdownMenuItem(value: 'ETH', child: Text('ETH')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => cryptoType = value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Crypto Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ActionTextField(
                      label: 'Wallet Address',
                      hintText: 'Enter crypto wallet address',
                      controller: walletAddressController,
                    ),
                  ],
                ],
              ),
            ),
            FeeSummaryCard(
              grossAmount: '\$6,300.00',
              feeAmount: '\$35.00',
              extraFeeLabel: isCrypto ? 'Network Fee' : null,
              extraFeeAmount: isCrypto ? '\$12.00' : null,
              totalAmount: isCrypto ? '0.091 BTC' : '\$6,253.00',
              totalLabel: isCrypto ? 'You Receive' : 'Cash Received',
            ),
          ],
        ),
      ),
    );
  }
}
