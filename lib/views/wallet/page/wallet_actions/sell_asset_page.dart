import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class SellAssetPage extends StatefulWidget {
  final WalletActionSummary asset;

  const SellAssetPage({super.key, required this.asset});

  @override
  State<SellAssetPage> createState() => _SellAssetPageState();
}

class _SellAssetPageState extends State<SellAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController(text: '1');
  final noteController = TextEditingController();
  String payoutMethod = 'Wallet Cash';

  int get _maxQuantity => widget.asset.asset.quantity;

  double get _unitPrice => _parseCurrency(widget.asset.asset.marketValue) / _maxQuantity;

  int get _quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > _maxQuantity) return _maxQuantity;
    return parsed;
  }

  double get _grossAmount => _unitPrice * _quantity;

  double get _feeAmount => _grossAmount * 0.008;

  double get _receivedAmount => _grossAmount - _feeAmount;

  String _formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  @override
  void dispose() {
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _reviewSell() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final summary = WalletActionSummary(
      asset: widget.asset.asset,
      actionType: WalletActionType.sell,
      title: 'Sell Asset',
      primaryValue: '$_quantity Units',
      feeValue: _formatCurrency(_feeAmount),
      totalValue: _formatCurrency(_receivedAmount),
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
        summaryValue: _formatCurrency(_receivedAmount),
        buttonText: 'Review Sell',
        onPressed: _reviewSell,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              WalletAssetSummaryCard(asset: widget.asset.asset),
              ActionSectionCard(
                title: 'Sell Details',
                child: Column(
                  children: [
                    ActionTextField(
                      label: 'Quantity to Sell (Max $_maxQuantity)',
                      hintText: 'Enter quantity',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final qty = int.tryParse((value ?? '').trim());
                        if (qty == null) return 'Please enter a valid number';
                        if (qty < 1) return 'Quantity must be at least 1';
                        if (qty > _maxQuantity) {
                          return 'Quantity cannot exceed $_maxQuantity';
                        }
                        return null;
                      },
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
                    ),
                  ],
                ),
              ),
              FeeSummaryCard(
                grossAmount: _formatCurrency(_grossAmount),
                feeAmount: _formatCurrency(_feeAmount),
                totalAmount: _formatCurrency(_receivedAmount),
                totalLabel: 'You Receive',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
