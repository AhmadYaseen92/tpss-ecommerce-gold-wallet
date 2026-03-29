import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/account_summary/page/account_summary_confirmation_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountSummaryPage extends StatefulWidget {
  const AccountSummaryPage({super.key});

  @override
  State<AccountSummaryPage> createState() => _AccountSummaryPageState();
}

class _AccountSummaryPageState extends State<AccountSummaryPage> {
  final _formKey = GlobalKey<FormState>();

  ConvertMethod selectedMethod = ConvertMethod.transferToBank;
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;
  int selectedUsdtIndex = 0;
  int selectedEDirhamIndex = 0;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  static const double totalPortfolio = 12450.0;

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const summary = AccountSummaryModel(
      holdMarketValue: '\$12,450.00',
      goldValue: '\$8,700.00',
      silverValue: '\$2,100.00',
      jewelleryValue: '\$1,650.00',
      availableCash: '\$12,450.00',
      usdtBalance: '1,250 USDT',
      eDirhamBalance: 'AED 4,300.00',
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('My Account Summary'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ActionSectionCard(
              title: 'Current Hold Account (Market Value)',
              child: Column(
                children: [
                  _row('Total Portfolio (Cash Value)', '\$${totalPortfolio.toStringAsFixed(2)}', bold: true),
                  _row('Gold', summary.goldValue),
                  _row('Silver', summary.silverValue),
                  _row('Jewellery', summary.jewelleryValue),
                ],
              ),
            ),
            ActionSectionCard(
              title: 'Transfer / Convert Method',
              child: Column(
                children: [
                  DropdownButtonFormField<ConvertMethod>(
                    value: selectedMethod,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: ConvertMethod.transferToBank, child: Text('Transfer To Bank Account')),
                      DropdownMenuItem(value: ConvertMethod.transferToCard, child: Text('Transfer To Card Account')),
                      DropdownMenuItem(value: ConvertMethod.transferToUsdt, child: Text('Transfer To USDT Account')),
                      DropdownMenuItem(value: ConvertMethod.transferToEDirham, child: Text('Transfer To E-Dirham Account')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedMethod = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  _methodSelector(),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = double.tryParse((v ?? '').trim());
                      if (value == null || value <= 0) return 'Enter a valid amount.';
                      if (value > totalPortfolio) return 'Amount must be <= total portfolio.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _onReview,
                      icon: const Icon(Icons.summarize_outlined),
                      label: const Text('Review Summary'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodSelector() {
    switch (selectedMethod) {
      case ConvertMethod.transferToBank:
        return PredefinedAccountSelector(
          label: 'Bank Account',
          accounts: PredefinedAccountsData.bankAccounts,
          selectedIndex: selectedBankIndex,
          icon: Icons.account_balance_outlined,
          onChanged: (index) {
            if (index == null) return;
            setState(() => selectedBankIndex = index);
          },
        );
      case ConvertMethod.transferToCard:
        return PredefinedAccountSelector(
          label: 'Card Account',
          accounts: PredefinedAccountsData.paymentMethods,
          selectedIndex: selectedPaymentIndex,
          icon: Icons.credit_card_outlined,
          onChanged: (index) {
            if (index == null) return;
            setState(() => selectedPaymentIndex = index);
          },
        );
      case ConvertMethod.transferToUsdt:
        return PredefinedAccountSelector(
          label: 'USDT Account',
          accounts: PredefinedAccountsData.usdtAccounts,
          selectedIndex: selectedUsdtIndex,
          icon: Icons.currency_bitcoin,
          onChanged: (index) {
            if (index == null) return;
            setState(() => selectedUsdtIndex = index);
          },
        );
      case ConvertMethod.transferToEDirham:
        return PredefinedAccountSelector(
          label: 'E-Dirham Account',
          accounts: PredefinedAccountsData.eDirhamAccounts,
          selectedIndex: selectedEDirhamIndex,
          icon: Icons.account_balance_wallet_outlined,
          onChanged: (index) {
            if (index == null) return;
            setState(() => selectedEDirhamIndex = index);
          },
        );
    }
  }

  void _onReview() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final request = AccountConversionRequest(
      method: selectedMethod,
      targetAccount: _targetAccountName(),
      amount: amount,
      note: noteController.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountSummaryConfirmationPage(
          request: request,
          totalPortfolio: totalPortfolio,
        ),
      ),
    );
  }

  String _targetAccountName() {
    switch (selectedMethod) {
      case ConvertMethod.transferToBank:
        return PredefinedAccountsData.bankAccounts[selectedBankIndex].name;
      case ConvertMethod.transferToCard:
        return PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name;
      case ConvertMethod.transferToUsdt:
        return PredefinedAccountsData.usdtAccounts[selectedUsdtIndex].name;
      case ConvertMethod.transferToEDirham:
        return PredefinedAccountsData.eDirhamAccounts[selectedEDirhamIndex].name;
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
