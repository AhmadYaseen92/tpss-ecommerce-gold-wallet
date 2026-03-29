import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class MarketOrderCheckoutPage extends StatefulWidget {
  const MarketOrderCheckoutPage({super.key});

  @override
  State<MarketOrderCheckoutPage> createState() => _MarketOrderCheckoutPageState();
}

enum MarketExecutionType { instant, limit, stop }

class _MarketOrderCheckoutPageState extends State<MarketOrderCheckoutPage> {
  MarketExecutionType executionType = MarketExecutionType.instant;
  int quantity = 1;
  final TextEditingController tpController = TextEditingController();
  final TextEditingController slController = TextEditingController();
  final TextEditingController triggerPriceController = TextEditingController();

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {};
  }

  double get _unitPrice => (_args['amount'] as num?)?.toDouble() ?? 0;
  double get _total => _unitPrice * quantity;

  @override
  void dispose() {
    tpController.dispose();
    slController.dispose();
    triggerPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final symbol = (_args['title'] ?? 'XAUUSD').toString();
    final seller = (_args['seller'] ?? 'All Sellers').toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Market Order Checkout'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Symbol/Unit', symbol),
                  _row('Seller', seller),
                  _row('Live Price', '\$${_unitPrice.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buy Type', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: MarketExecutionType.values.map((type) {
                      final selected = executionType == type;
                      return ChoiceChip(
                        label: Text(_label(type)),
                        selected: selected,
                        onSelected: (_) => setState(() => executionType = type),
                        selectedColor: AppColors.luxuryIvory,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () => setState(() => quantity++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      Text('Total: \$${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  if (executionType != MarketExecutionType.instant) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: triggerPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: executionType == MarketExecutionType.limit ? 'Limit Price' : 'Stop Price',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: tpController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Take Profit (TP)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: slController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Stop Loss (SL)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order placed: $symbol x$quantity (${_label(executionType)})')),
                );
                Navigator.pop(context);
              },
              child: const Text('Buy Now'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: child,
    );
  }

  Widget _row(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [Expanded(child: Text(key)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
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
