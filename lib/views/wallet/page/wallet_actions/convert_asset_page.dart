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

class ConvertAssetPage extends StatefulWidget {
  final WalletTransaction asset;

  const ConvertAssetPage({super.key, required this.asset});

  @override
  State<ConvertAssetPage> createState() => _ConvertAssetPageState();
}

class _ConvertAssetPageState extends State<ConvertAssetPage> {
  final _formKey = GlobalKey<FormState>();
  ConvertTargetType targetType = ConvertTargetType.cash;

  final quantityController = TextEditingController(text: '1');
  final walletAddressController = TextEditingController();

  String cashDestination = 'Wallet Cash';
  String cryptoType = 'USDT';

  int get _maxQuantity => widget.asset.quantity;
  double get _unitPrice => _parseCurrency(widget.asset.marketValue) / _maxQuantity;

  int get _quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > _maxQuantity) return _maxQuantity;
    return parsed;
  }

  double get _grossAmount => _unitPrice * _quantity;
  double get _serviceFee => _grossAmount * 0.005;
  double get _networkFee => targetType == ConvertTargetType.crypto ? 12 : 0;
  double get _totalFee => _serviceFee + _networkFee;

  double get _cashReceived => _grossAmount - _totalFee;

  double get _cryptoReceived {
    final usd = _cashReceived;
    final rate = _cryptoRate[cryptoType] ?? 1;
    return usd / rate;
  }

  Map<String, double> get _cryptoRate => {
    'USDT': 1,
    'BTC': 69000,
    'ETH': 3500,
  };

  String _formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  @override
  void dispose() {
    quantityController.dispose();
    walletAddressController.dispose();
    super.dispose();
  }

  void _reviewConversion() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final isCrypto = targetType == ConvertTargetType.crypto;
    final summary = WalletActionSummary(
      asset: widget.asset,
      actionType: isCrypto
          ? WalletActionType.convertToCrypto
          : WalletActionType.convertToCash,
      title: isCrypto ? 'Convert to Crypto' : 'Convert to Cash',
      primaryValue: '$_quantity Units',
      feeValue: _formatCurrency(_totalFee),
      totalValue: isCrypto
          ? '${_cryptoReceived.toStringAsFixed(6)} $cryptoType'
          : _formatCurrency(_cashReceived),
      destinationLabel: isCrypto ? 'Wallet Address' : 'Cash Destination',
      destinationValue: isCrypto
          ? walletAddressController.text.trim()
          : cashDestination,
      note: isCrypto ? '$cryptoType conversion' : null,
      referenceNumber: 'CNV-${DateTime.now().millisecondsSinceEpoch}',
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
    final isCrypto = targetType == ConvertTargetType.crypto;

    return Scaffold(
      appBar: AppBar(title: const Text('Convert Asset')),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: isCrypto ? 'Estimated Crypto' : 'Estimated Cash',
        summaryValue: isCrypto
            ? '${_cryptoReceived.toStringAsFixed(6)} $cryptoType'
            : _formatCurrency(_cashReceived),
        buttonText: 'Review Conversion',
        onPressed: _reviewConversion,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                        validator: (value) {
                          if (isCrypto && (value ?? '').trim().isEmpty) {
                            return 'Wallet address is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              FeeSummaryCard(
                grossAmount: _formatCurrency(_grossAmount),
                feeAmount: _formatCurrency(_serviceFee),
                extraFeeLabel: isCrypto ? 'Network Fee' : null,
                extraFeeAmount: isCrypto ? _formatCurrency(_networkFee) : null,
                totalAmount: isCrypto
                    ? '${_cryptoReceived.toStringAsFixed(6)} $cryptoType'
                    : _formatCurrency(_cashReceived),
                totalLabel: isCrypto ? 'You Receive' : 'Cash Received',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
