import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';

class MarketOrderCheckoutPage extends StatefulWidget {
  const MarketOrderCheckoutPage({super.key});

  @override
  State<MarketOrderCheckoutPage> createState() => _MarketOrderCheckoutPageState();
}

enum MarketExecutionType { instant, limit, stop }

class _MarketOrderCheckoutPageState extends State<MarketOrderCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  MarketExecutionType executionType = MarketExecutionType.instant;
  final TextEditingController quantityController = TextEditingController(text: '1');

  final TextEditingController triggerPriceController = TextEditingController();
  final TextEditingController tpController = TextEditingController();
  final TextEditingController slController = TextEditingController();

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {};
  }

  double get _unitPrice => (_args['amount'] as num?)?.toDouble() ?? 0;
  int get _quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    return parsed < 1 ? 1 : parsed;
  }

  double get _total => _unitPrice * _quantity;

  @override
  void dispose() {
    quantityController.dispose();
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
        onPressed: () async {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          await AppModalAlert.show(
            context,
            title: 'Order Placed',
            message: 'Order placed: $symbol x$_quantity (${_label(executionType)})',
          );
          if (!context.mounted) return;
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Execution Type',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: MarketExecutionType.values.map((type) {
                        final selected = type == executionType;
                        return ChoiceChip(
                          label: Text(_label(type)),
                          selected: selected,
                          selectedColor: AppColors.primaryColor.withAlpha(25),
                          labelStyle: TextStyle(
                            color: selected ? AppColors.primaryColor : AppColors.darkBrown,
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: selected ? AppColors.primaryColor : AppColors.greyBorder,
                          ),
                          onSelected: (_) => setState(() => executionType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ActionTextField(
                            label: 'Quantity',
                            hintText: 'Enter quantity',
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final parsed = int.tryParse((value ?? '').trim());
                              if (parsed == null || parsed < 1) {
                                return 'Quantity must be at least 1';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _quantity > 1
                              ? () {
                                  quantityController.text = (_quantity - 1).toString();
                                  setState(() {});
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        IconButton(
                          onPressed: () {
                            quantityController.text = (_quantity + 1).toString();
                            setState(() {});
                          },
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
                      label: 'Take Profite',
                      hintText: 'Optional',
                      controller: tpController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _optionalNumberValidator,
                    ),
                    const SizedBox(height: 12),
                    ActionTextField(
                      label: 'Stope Loss',
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
