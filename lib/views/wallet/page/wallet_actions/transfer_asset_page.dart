import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class TransferAssetPage extends StatefulWidget {
  final WalletTransaction asset;

  const TransferAssetPage({super.key, required this.asset});

  @override
  State<TransferAssetPage> createState() => _TransferAssetPageState();
}

class _TransferAssetPageState extends State<TransferAssetPage> {
  final _formKey = GlobalKey<FormState>();
  WalletActionType transferType = WalletActionType.transfer;

  final recipientNameController = TextEditingController();
  final recipientContactController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final messageController = TextEditingController();

  int get _maxQuantity => widget.asset.quantity;
  double get _unitPrice => _parseCurrency(widget.asset.marketValue) / _maxQuantity;
  int get _quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > _maxQuantity) return _maxQuantity;
    return parsed;
  }

  double get _grossAmount => _unitPrice * _quantity;
  double get _feeAmount => 10;
  double get _estimatedValue => _grossAmount - _feeAmount;

  String _formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  @override
  void dispose() {
    recipientNameController.dispose();
    recipientContactController.dispose();
    quantityController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void _reviewTransfer() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final isGift = transferType == WalletActionType.gift;
    final summary = WalletActionSummary(
      asset: widget.asset,
      actionType: transferType,
      title: isGift ? 'Gift Asset' : 'Transfer Asset',
      primaryValue: '$_quantity Units',
      feeValue: _formatCurrency(_feeAmount),
      totalValue: _formatCurrency(_estimatedValue),
      destinationLabel: isGift ? 'Recipient Contact' : 'Wallet ID / Contact',
      destinationValue: recipientContactController.text.trim(),
      note: messageController.text.trim(),
      referenceNumber: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
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
    final isGift = transferType == WalletActionType.gift;

    return Scaffold(
      appBar: AppBar(title: Text(isGift ? 'Gift Asset' : 'Transfer Asset')),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: 'Estimated Value',
        summaryValue: _formatCurrency(_estimatedValue),
        buttonText: isGift ? 'Review Gift' : 'Review Transfer',
        onPressed: _reviewTransfer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Recipient name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ActionTextField(
                      label: isGift
                          ? 'Recipient Email / Mobile'
                          : 'Wallet ID / Email / Mobile',
                      hintText: 'Enter recipient contact',
                      controller: recipientContactController,
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Recipient contact is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              ActionSectionCard(
                title: 'Transfer Details',
                child: Column(
                  children: [
                    ActionTextField(
                      label: 'Quantity (Max $_maxQuantity)',
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
                    ActionTextField(
                      label: isGift ? 'Gift Message' : 'Transfer Note',
                      hintText: isGift
                          ? 'Write a gift message'
                          : 'Optional transfer note',
                      controller: messageController,
                    ),
                  ],
                ),
              ),
              FeeSummaryCard(
                grossAmount: _formatCurrency(_grossAmount),
                feeAmount: _formatCurrency(_feeAmount),
                totalAmount: _formatCurrency(_estimatedValue),
                totalLabel: 'Estimated Value',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
