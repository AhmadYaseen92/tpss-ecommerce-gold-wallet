import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

class PickupRequestPage extends StatelessWidget {
  final WalletTransaction asset;
  const PickupRequestPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Request')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pickup for ${asset.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          const Text('Summary'),
          const SizedBox(height: 8),
          const _FeeRow('Delivery', '\$20.00'),
          const _FeeRow('Storage', '\$10.00'),
          const _FeeRow('Service Charge', '\$5.00'),
          const _FeeRow('Premium/Discount', '-\$2.50'),
          const Divider(height: 20),
          const _FeeRow('Total Fees', '\$32.50', bold: true),
          const SizedBox(height: 16),
          const Text('Amount Summary'),
          const SizedBox(height: 8),
          _FeeRow('Amount', asset.marketValue),
          const _FeeRow('Fees', '\$32.50'),
          const _FeeRow('Total Amount', '\$1,232.50', bold: true),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Schedule time',
              hintText: 'e.g. 2026-03-30 14:00',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pickup scheduled and item will hide after delivery.')),
              );
            },
            child: const Text('Confirm Pickup'),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _FeeRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [Expanded(child: Text(label, style: style)), Text(value, style: style)],
      ),
    );
  }
}
