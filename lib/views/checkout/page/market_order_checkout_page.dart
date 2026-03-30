import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_form_dropdown.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';

class MarketOrderCheckoutPage extends StatefulWidget {
  const MarketOrderCheckoutPage({super.key});

  @override
  State<MarketOrderCheckoutPage> createState() => _MarketOrderCheckoutPageState();
}

enum MarketExecutionType { instant, limit, stop }

class _MarketOrderCheckoutPageState extends State<MarketOrderCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  MarketExecutionType executionType = MarketExecutionType.instant;
  int quantity = 1;

  final TextEditingController triggerPriceController = TextEditingController();
  final TextEditingController tpController = TextEditingController();
  final TextEditingController slController = TextEditingController();

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {};
  }

  double get _unitPrice => (_args['amount'] as num?)?.toDouble() ?? 0;
  double get _total => _unitPrice * quantity;

  @override
  void dispose() {
    triggerPriceController.dispose();
    tpController.dispose();
    slController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = (_args['title'] ?? 'XAUUSD').toString();
    final seller = (_args['seller'] ?? AppReleaseConfig.defaultSeller).toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Market Order Checkout'), centerTitle: true),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: 'Estimated Total',
        summaryValue: '\$${_total.toStringAsFixed(2)}',
        buttonText: 'Place Order',
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order placed: $symbol x$quantity (${_label(executionType)})',
              ),
            ),
          );
          Navigator.pop(context);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ActionSectionCard(
                title: 'Order Details',
                child: Column(
                  children: [
                    _readonlyRow('Symbol/Unit', symbol),
                    if (AppReleaseConfig.showSellerUi) _readonlyRow('Seller', seller),
                    _readonlyRow('Live Price', '\$${_unitPrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              ActionSectionCard(
                title: 'Order Type & Quantity',
                child: Column(
                  children: [
                    AppFormDropdown<MarketExecutionType>(
                      label: 'Buy Type',
                      value: executionType,
                      items: MarketExecutionType.values
                          .map(
                            (type) => DropdownMenuItem<MarketExecutionType>(
                              value: type,
                              child: Text(_label(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (type) {
                        if (type == null) return;
                        setState(() => executionType = type);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        IconButton(
                          onPressed: () => setState(() => quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ActionSectionCard(
                title: 'Risk Management',
                child: Column(
                  children: [
                    if (executionType != MarketExecutionType.instant) ...[
                      ActionTextField(
                        label: executionType == MarketExecutionType.limit
                            ? 'Limit Price'
                            : 'Stop Price',
                        hintText: 'Enter trigger price',
                        controller: triggerPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (executionType == MarketExecutionType.instant) return null;
                          if (value == null || value.trim().isEmpty) {
                            return 'Required for ${_label(executionType)} orders';
                          }
                          if (double.tryParse(value) == null) return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    ActionTextField(
                      label: 'Take Profit (TP)',
                      hintText: 'Optional',
                      controller: tpController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _optionalNumberValidator,
                    ),
                    const SizedBox(height: 12),
                    ActionTextField(
                      label: 'Stop Loss (SL)',
                      hintText: 'Optional',
                      controller: slController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _optionalNumberValidator,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _optionalNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  Widget _readonlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _label(MarketExecutionType type) {
    switch (type) {
      case MarketExecutionType.instant:
        return 'Instant';
      case MarketExecutionType.limit:
        return 'Limit';
      case MarketExecutionType.stop:
        return 'Stop';
    }
  }
}
