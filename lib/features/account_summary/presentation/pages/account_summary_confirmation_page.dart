import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/features/convert/data/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';

class AccountSummaryConfirmationPage extends StatelessWidget {
  static const double _usdToEDirhamRate = 3.6725;

  final AccountConversionRequest request;
  final double totalPortfolio;

  const AccountSummaryConfirmationPage({
    super.key,
    required this.request,
    required this.totalPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    final convertedAmount = _convertedAmountLabel(request.method, request.amount);

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
                _row('Target Account', request.targetAccount),
                _row('Amount', '\$${request.amount.toStringAsFixed(2)}'),
                if (convertedAmount != null)
                  _row('Converted Amount', convertedAmount),
                _row('Note', request.note.isEmpty ? 'No note' : request.note),
                const Divider(),
                _row('Portfolio Limit', '\$${totalPortfolio.toStringAsFixed(2)}'),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              AppModalAlert.show(
                context,
                title: 'OTP Sent',
                message: 'OTP sent to WhatsApp. Confirm to complete operation.',
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
      case ConvertMethod.transferToBank:
        return 'Transfer To Bank Account';
      case ConvertMethod.transferToCard:
        return 'Transfer To Card Account';
      case ConvertMethod.transferToUsdt:
        return 'Transfer To USDT Account';
      case ConvertMethod.transferToEDirham:
        return 'Transfer To E-Dirham Account';
    }
  }

  String? _convertedAmountLabel(ConvertMethod method, double amount) {
    switch (method) {
      case ConvertMethod.transferToUsdt:
        return '${NumberFormat('#,##0.##').format(amount)} USDT';
      case ConvertMethod.transferToEDirham:
        return 'AED ${NumberFormat('#,##0.00').format(amount * _usdToEDirhamRate)}';
      case ConvertMethod.transferToBank:
      case ConvertMethod.transferToCard:
        return null;
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
