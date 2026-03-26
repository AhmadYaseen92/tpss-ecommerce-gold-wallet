import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

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
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('My Account Summary'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ActionSectionCard(
            title: 'Current Hold Account (Market Value)',
            child: Column(
              children: [
                _row('Total Hold Value', summary.holdMarketValue, bold: true),
                _row('Gold', summary.goldValue),
                _row('Silver', summary.silverValue),
                _row('Jewellery', summary.jewelleryValue),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Available Balances',
            child: Column(
              children: [
                _row('Cash Balance', summary.availableCash),
                _row('USDT Balance', summary.usdtBalance),
                _row('EDirham Balance', summary.eDirhamBalance),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Transfer Actions',
            child: Column(
              children: const [
                _ActionLine('Transfer to bank account', 'Select predefined account → amount → review → OTP'),
                SizedBox(height: 8),
                _ActionLine('Transfer to credit card', 'Select predefined card → amount → review → OTP'),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Convert',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _ConvertChip('Cash → USDT'),
                _ConvertChip('USDT → Cash'),
                _ConvertChip('Cash → EDirham'),
                _ConvertChip('EDirham → Cash'),
              ],
            ),
          ),
        ],
      ),
    );
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

class _ConvertChip extends StatelessWidget {
  final String label;
  const _ConvertChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.luxuryIvory,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryColor.withAlpha(50)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionLine extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ActionLine(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.greyShade600)),
            ],
          ),
        ),
      ],
    );
  }
}
