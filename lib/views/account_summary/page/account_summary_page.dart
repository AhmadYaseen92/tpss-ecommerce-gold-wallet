import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/summary_action_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountSummaryPage extends StatefulWidget {
  const AccountSummaryPage({super.key});

  @override
  State<AccountSummaryPage> createState() => _AccountSummaryPageState();
}

class _AccountSummaryPageState extends State<AccountSummaryPage> {
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;

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
      appBar: AppBar(title: const Text('My Account Summary'), centerTitle: true),
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
            title: 'Transfer to Bank Account',
            child: Column(
              children: [
                PredefinedAccountSelector(
                  label: 'Select Linked Bank Account',
                  accounts: PredefinedAccountsData.bankAccounts,
                  selectedIndex: selectedBankIndex,
                  icon: Icons.account_balance_outlined,
                  onChanged: (index) {
                    if (index == null) return;
                    setState(() => selectedBankIndex = index);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SummaryActionButton(
                      title: 'Review',
                      subtitle: PredefinedAccountsData.bankAccounts[selectedBankIndex].name,
                      icon: Icons.visibility_outlined,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    SummaryActionButton(
                      title: 'Confirm OTP',
                      subtitle: 'WhatsApp OTP',
                      icon: Icons.verified_user_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Transfer to Payment Method',
            child: Column(
              children: [
                PredefinedAccountSelector(
                  label: 'Select Predefined Payment Method',
                  accounts: PredefinedAccountsData.paymentMethods,
                  selectedIndex: selectedPaymentIndex,
                  icon: Icons.credit_card_outlined,
                  onChanged: (index) {
                    if (index == null) return;
                    setState(() => selectedPaymentIndex = index);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SummaryActionButton(
                      title: 'Review',
                      subtitle: PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name,
                      icon: Icons.rule_folder_outlined,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    SummaryActionButton(
                      title: 'Confirm OTP',
                      subtitle: 'WhatsApp OTP',
                      icon: Icons.shield_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
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
