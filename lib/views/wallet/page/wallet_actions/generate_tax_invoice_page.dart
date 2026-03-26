import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';

class GenerateTaxInvoicePage extends StatelessWidget {
  final WalletTransaction asset;
  const GenerateTaxInvoicePage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Tax Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${asset.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Amount: ${asset.marketValue}'),
            Text('Client: Seller to Client'),
            Text('Reference: INV-${asset.id}-${DateTime.now().millisecondsSinceEpoch}'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invoice preview opened.')),
                      );
                    },
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invoice PDF downloaded.')),
                      );
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
