import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountSummaryConfirmationPage extends StatelessWidget {
  final AccountConversionRequest request;
  final double totalPortfolio;

  const AccountSummaryConfirmationPage({
    super.key,
    required this.request,
    required this.totalPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Conversion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ActionSectionCard(
            title: 'Summary',
            child: Column(
              children: [
                _row('Method', _methodLabel(request.method)),
                if (request.method == ConvertMethod.cashSettlement) ...[
                  _row('Bank Account', request.bankAccount ?? '-'),
                  _row('Amount to Bank', '\$${request.bankAmount.toStringAsFixed(2)}'),
                  _row('Payment Method', request.paymentMethod ?? '-'),
                  _row('Amount to Card', '\$${request.cardAmount.toStringAsFixed(2)}'),
                ] else ...[
                  _row('Target Account', request.targetWallet ?? '-'),
                  _row('Convert Amount', '\$${request.convertAmount.toStringAsFixed(2)}'),
                ],
                _row('Note', request.note.isEmpty ? 'No note' : request.note),
                const Divider(),
                _row('Total', '\$${request.total.toStringAsFixed(2)}', bold: true),
                _row('Portfolio Limit', '\$${totalPortfolio.toStringAsFixed(2)}'),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OTP sent to WhatsApp. Confirm to complete operation.')),
              );
            },
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Confirm with OTP'),
          ),
        ],
      ),
    );
  }

  String _methodLabel(ConvertMethod method) {
    switch (method) {
      case ConvertMethod.cashSettlement:
        return 'Cash to Bank/Card';
      case ConvertMethod.toUsdt:
        return 'Cash to USDT';
      case ConvertMethod.toEDirham:
        return 'Cash to EDirham';
    }
  }

  Widget _row(String key, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [Expanded(child: Text(key, style: style)), Text(value, style: style)],
      ),
    );
  }
}
