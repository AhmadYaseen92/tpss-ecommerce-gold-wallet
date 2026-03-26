import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountSummaryPage extends StatefulWidget {
  const AccountSummaryPage({super.key});

  @override
  State<AccountSummaryPage> createState() => _AccountSummaryPageState();
}

class _AccountSummaryPageState extends State<AccountSummaryPage> {
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;

  final bankAmountController = TextEditingController();
  final cardAmountController = TextEditingController();

  static const double availableCash = 2000.0;

  double get bankAmount => double.tryParse(bankAmountController.text.trim()) ?? 0;
  double get cardAmount => double.tryParse(cardAmountController.text.trim()) ?? 0;
  double get allocatedTotal => bankAmount + cardAmount;
  double get remaining => availableCash - allocatedTotal;

  @override
  void dispose() {
    bankAmountController.dispose();
    cardAmountController.dispose();
    super.dispose();
  }

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
            title: 'Allocate Available Cash (Bank + Card)',
            child: Column(
              children: [
                PredefinedAccountSelector(
                  label: 'Bank Account',
                  accounts: PredefinedAccountsData.bankAccounts,
                  selectedIndex: selectedBankIndex,
                  icon: Icons.account_balance_outlined,
                  onChanged: (index) {
                    if (index == null) return;
                    setState(() => selectedBankIndex = index);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Amount to transfer to Bank',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                PredefinedAccountSelector(
                  label: 'Payment Method / Card',
                  accounts: PredefinedAccountsData.paymentMethods,
                  selectedIndex: selectedPaymentIndex,
                  icon: Icons.credit_card_outlined,
                  onChanged: (index) {
                    if (index == null) return;
                    setState(() => selectedPaymentIndex = index);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cardAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Amount to transfer to Card',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: remaining >= 0 ? AppColors.luxuryIvory : AppColors.lightRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: remaining >= 0 ? AppColors.primaryColor.withAlpha(40) : AppColors.red,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Allocated', '\$${allocatedTotal.toStringAsFixed(2)}'),
                      _row('Remaining from available', '\$${remaining.toStringAsFixed(2)}', bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (allocatedTotal <= 0) {
                        _showMsg('Please enter allocation amounts.');
                        return;
                      }
                      if (remaining < 0) {
                        _showMsg('Allocated amount exceeds available cash balance.');
                        return;
                      }
                      _showMsg('Allocation confirmed with OTP via WhatsApp.');
                    },
                    icon: const Icon(Icons.verified_user_outlined),
                    label: const Text('Confirm with OTP'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
