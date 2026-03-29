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

  ConvertMethod selectedMethod = ConvertMethod.cashSettlement;
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;
  int selectedUsdtIndex = 0;
  int selectedEDirhamIndex = 0;

  final amountController = TextEditingController();
  final bankAmountController = TextEditingController();
  final cardAmountController = TextEditingController();
  final noteController = TextEditingController();

  static const double totalPortfolio = 12450.0;

  double get amount => double.tryParse(amountController.text.trim()) ?? 0;
  double get bankAmount => double.tryParse(bankAmountController.text.trim()) ?? 0;
  double get cardAmount => double.tryParse(cardAmountController.text.trim()) ?? 0;

  bool get isCashSettlement => selectedMethod == ConvertMethod.cashSettlement;
  bool get isToUsdt => selectedMethod == ConvertMethod.toUsdt;
  bool get isToEDirham => selectedMethod == ConvertMethod.toEDirham;

  @override
  void dispose() {
    amountController.dispose();
    bankAmountController.dispose();
    cardAmountController.dispose();
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
              title: 'Convert / Settle',
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
                      DropdownMenuItem(
                        value: ConvertMethod.cashSettlement,
                        child: Text('Cash to Bank/Card'),
                      ),
                      DropdownMenuItem(
                        value: ConvertMethod.toUsdt,
                        child: Text('Cash to USDT'),
                      ),
                      DropdownMenuItem(
                        value: ConvertMethod.toEDirham,
                        child: Text('Cash to EDirham'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedMethod = value;
                        bankAmountController.clear();
                        cardAmountController.clear();
                      });
                    },
                  ),
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

                  if (isCashSettlement) ...[
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
                    TextFormField(
                      controller: bankAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount to Bank',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (!isCashSettlement) return null;
                        final bank = double.tryParse((v ?? '').trim()) ?? 0;
                        if (bank < 0) return 'Amount cannot be negative.';
                        if ((bank + cardAmount) > amount) {
                          return 'Bank + Card must be <= amount.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    PredefinedAccountSelector(
                      label: 'Card / Payment Method',
                      accounts: PredefinedAccountsData.paymentMethods,
                      selectedIndex: selectedPaymentIndex,
                      icon: Icons.credit_card_outlined,
                      onChanged: (index) {
                        if (index == null) return;
                        setState(() => selectedPaymentIndex = index);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: cardAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount to Card',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (!isCashSettlement) return null;
                        final card = double.tryParse((v ?? '').trim()) ?? 0;
                        if (card < 0) return 'Amount cannot be negative.';
                        if ((card + bankAmount) <= 0) return 'Enter bank/card amount.';
                        if ((card + bankAmount) > amount) {
                          return 'Bank + Card must be <= amount.';
                        }
                        return null;
                      },
                    ),
                  ],

                  if (isToUsdt)
                    PredefinedAccountSelector(
                      label: 'USDT Account (from Profile)',
                      accounts: PredefinedAccountsData.usdtAccounts,
                      selectedIndex: selectedUsdtIndex,
                      icon: Icons.currency_bitcoin,
                      onChanged: (index) {
                        if (index == null) return;
                        setState(() => selectedUsdtIndex = index);
                      },
                    ),
                  if (isToEDirham)
                    PredefinedAccountSelector(
                      label: 'eDirham Account (from Profile)',
                      accounts: PredefinedAccountsData.eDirhamAccounts,
                      selectedIndex: selectedEDirhamIndex,
                      icon: Icons.account_balance_wallet_outlined,
                      onChanged: (index) {
                        if (index == null) return;
                        setState(() => selectedEDirhamIndex = index);
                      },
                    ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      hintText: 'Any notes for this conversion/settlement',
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

  void _onReview() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = AccountConversionRequest(
      method: selectedMethod,
      bankAccount: isCashSettlement ? PredefinedAccountsData.bankAccounts[selectedBankIndex].name : null,
      paymentMethod: isCashSettlement ? PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name : null,
      targetWallet: isToUsdt
          ? PredefinedAccountsData.usdtAccounts[selectedUsdtIndex].name
          : isToEDirham
              ? PredefinedAccountsData.eDirhamAccounts[selectedEDirhamIndex].name
              : null,
      bankAmount: bankAmount,
      cardAmount: cardAmount,
      convertAmount: amount,
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
