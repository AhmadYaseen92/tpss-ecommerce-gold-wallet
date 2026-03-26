import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';

class AccountSummaryPage extends StatelessWidget {
  const AccountSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = AccountSummaryModel(
      holdMarketValue: '\$12,450.00',
      goldValue: '\$8,700.00',
      silverValue: '\$2,100.00',
      jewelleryValue: '\$1,650.00',
      availableCash: '\$2,000.00',
      usdtBalance: '1,250 USDT',
      eDirhamBalance: 'AED 4,300.00',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Account Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card('Current Hold Account (Market Value)', [
            _row('Total Hold Market Value', summary.holdMarketValue),
            _row('Gold', summary.goldValue),
            _row('Silver', summary.silverValue),
            _row('Jewellery', summary.jewelleryValue),
          ]),
          _card('Available Balances', [
            _row('Cash Balance', summary.availableCash),
            _row('USDT Available Balance', summary.usdtBalance),
            _row('EDirham Available Balance', summary.eDirhamBalance),
          ]),
          _card('Transfers', const [
            Text('1) Transfer to bank account (predefined account + OTP).'),
            SizedBox(height: 6),
            Text('2) Transfer to credit card (predefined card + OTP).'),
          ]),
          _card('Convert', const [
            Text('• Cash to USDT'),
            Text('• USDT to Cash'),
            Text('• Cash to EDirham'),
            Text('• EDirham to Cash'),
          ]),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...children,
        ]),
      ),
    );
  }

  Widget _row(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(key)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
