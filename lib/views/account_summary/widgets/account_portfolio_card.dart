import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountPortfolioCard extends StatelessWidget {
  final AccountSummaryModel summary;
  final double totalPortfolio;
  final ConvertMethod selectedMethod;

  const AccountPortfolioCard({
    super.key,
    required this.summary,
    required this.totalPortfolio,
    required this.selectedMethod,
  });

  static const double _usdToAed = 3.6725;

  @override
  Widget build(BuildContext context) {
    final bool showUsdt = selectedMethod == ConvertMethod.transferToUsdt;
    final bool showEDirham = selectedMethod == ConvertMethod.transferToEDirham;

    return ActionSectionCard(
      title: 'Current Hold Account (Market Value)',
      child: Column(
        children: [
          _row(
            'Total Portfolio (Cash Value)',
            _formatAmount(totalPortfolio, showUsdt: showUsdt, showEDirham: showEDirham),
            bold: true,
          ),
          _row('Gold', _formatAmount(summary.goldValue, showUsdt: showUsdt, showEDirham: showEDirham)),
          _row('Silver', _formatAmount(summary.silverValue, showUsdt: showUsdt, showEDirham: showEDirham)),
          _row('Jewellery', _formatAmount(summary.jewelleryValue, showUsdt: showUsdt, showEDirham: showEDirham)),
        ],
      ),
    );
  }

  String _formatAmount(double amount, {required bool showUsdt, required bool showEDirham}) {
    if (showUsdt) {
      return '${NumberFormat.decimalPattern().format(amount)} USDT';
    }
    if (showEDirham) {
      return 'AED ${NumberFormat('#,##0.00').format(amount * _usdToAed)}';
    }
    return '\$${NumberFormat('#,##0.00').format(amount)}';
  }

  Widget _row(String key, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(key, style: style)), Text(value, style: style)]),
    );
  }
}
