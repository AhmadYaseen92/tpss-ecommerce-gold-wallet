import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class GenerateTaxInvoicePage extends StatelessWidget {
  final WalletTransaction asset;
  const GenerateTaxInvoicePage({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final reference = 'INV-${asset.id}-${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Generate Tax Invoice'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ActionSectionCard(
              title: 'Invoice Details',
              child: Column(
                children: [
                  _row('Item', asset.name),
                  _row('Amount', asset.marketValue),
                  _row('Invoice Type', 'Seller ↔ Client'),
                  _row('Reference', reference),
                ],
              ),
            ),
            ActionSectionCard(
              title: 'Actions',
              child: Column(
                children: [
                  _actionBtn(
                    context,
                    icon: Icons.remove_red_eye_outlined,
                    label: 'View Invoice',
                    message: 'Invoice preview opened.',
                  ),
                  const SizedBox(height: 10),
                  _actionBtn(
                    context,
                    icon: Icons.download_outlined,
                    label: 'Download PDF',
                    message: 'Invoice PDF downloaded.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String message,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))],
      ),
    );
  }
}
