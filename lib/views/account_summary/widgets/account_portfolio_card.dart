import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountPortfolioCard extends StatelessWidget {
  final AccountSummaryModel summary;
  final double totalPortfolio;

  const AccountPortfolioCard({
    super.key,
    required this.summary,
    required this.totalPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return ActionSectionCard(
      title: 'Current Hold Account (Market Value)',
      child: Column(
        children: [
          _row('Total Portfolio (Cash Value)', '\$${totalPortfolio.toStringAsFixed(2)}', bold: true),
          _row('Gold', summary.goldValue),
          _row('Silver', summary.silverValue),
          _row('Jewellery', summary.jewelleryValue),
        ],
      ),
    );
  }

  Widget _row(String key, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(key, style: style)), Text(value, style: style)]),
    );
  }
}
