import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

enum ConvertMethod {
  cashToUsdt,
  usdtToCash,
  cashToEDirham,
  eDirhamToCash,
}

class AccountSummaryPage extends StatefulWidget {
  const AccountSummaryPage({super.key});

  @override
  State<AccountSummaryPage> createState() => _AccountSummaryPageState();
}

class _AccountSummaryPageState extends State<AccountSummaryPage> {
  ConvertMethod selectedMethod = ConvertMethod.cashToUsdt;

  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;
  int selectedUsdtIndex = 0;
  int selectedEDirhamIndex = 0;

  final amountController = TextEditingController();
  final bankAmountController = TextEditingController();
  final cardAmountController = TextEditingController();

  static const double totalPortfolio = 12450.0;

  double get convertAmount => double.tryParse(amountController.text.trim()) ?? 0;
  double get bankAmount => double.tryParse(bankAmountController.text.trim()) ?? 0;
  double get cardAmount => double.tryParse(cardAmountController.text.trim()) ?? 0;
  double get splitTotal => bankAmount + cardAmount;

  bool get isCashToUsdt => selectedMethod == ConvertMethod.cashToUsdt;
  bool get isUsdtToCash => selectedMethod == ConvertMethod.usdtToCash;
  bool get isCashToEDirham => selectedMethod == ConvertMethod.cashToEDirham;
  bool get isEDirhamToCash => selectedMethod == ConvertMethod.eDirhamToCash;

  @override
  void dispose() {
    amountController.dispose();
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
      availableCash: '\$0.00',
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
                _row('Total Portfolio', '\$${totalPortfolio.toStringAsFixed(2)}', bold: true),
                _row('Gold', summary.goldValue),
                _row('Silver', summary.silverValue),
                _row('Jewellery', summary.jewelleryValue),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Balances',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('USDT Balance', summary.usdtBalance),
                _row('EDirham Balance', summary.eDirhamBalance),
                const SizedBox(height: 6),
                const Text(
                  'Cash is not held in-app. Cash settlement is to linked bank/card only.',
                  style: TextStyle(fontSize: 12, color: AppColors.greyShade600),
                ),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Convert / Transfer Action',
            child: Column(
              children: [
                DropdownButtonFormField<ConvertMethod>(
                  value: selectedMethod,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Convert Method',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: ConvertMethod.cashToUsdt, child: Text('Cash to USDT')),
                    DropdownMenuItem(value: ConvertMethod.usdtToCash, child: Text('USDT to Cash')),
                    DropdownMenuItem(value: ConvertMethod.cashToEDirham, child: Text('Cash to EDirham')),
                    DropdownMenuItem(value: ConvertMethod.eDirhamToCash, child: Text('EDirham to Cash')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedMethod = value;
                      amountController.clear();
                      bankAmountController.clear();
                      cardAmountController.clear();
                    });
                  },
                ),
                const SizedBox(height: 12),

                if (isCashToUsdt || isCashToEDirham) ...[
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  if (isCashToUsdt)
                    PredefinedAccountSelector(
                      label: 'USDT Profile Account',
                      accounts: PredefinedAccountsData.usdtAccounts,
                      selectedIndex: selectedUsdtIndex,
                      icon: Icons.currency_bitcoin,
                      onChanged: (index) {
                        if (index == null) return;
                        setState(() => selectedUsdtIndex = index);
                      },
                    ),
                  if (isCashToEDirham)
                    PredefinedAccountSelector(
                      label: 'eDirham Profile Account',
                      accounts: PredefinedAccountsData.eDirhamAccounts,
                      selectedIndex: selectedEDirhamIndex,
                      icon: Icons.account_balance_wallet_outlined,
                      onChanged: (index) {
                        if (index == null) return;
                        setState(() => selectedEDirhamIndex = index);
                      },
                    ),
                ],

                if (isUsdtToCash || isEDirhamToCash) ...[
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
                    decoration: const InputDecoration(
                      labelText: 'Amount to Bank',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
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
                  TextField(
                    controller: cardAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount to Card',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _row('Total to cash settlement', '\$${splitTotal.toStringAsFixed(2)}', bold: true),
                ],

                const SizedBox(height: 8),
                _row('Limit (<= Total Portfolio)', '\$${totalPortfolio.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirmOtp,
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

  void _confirmOtp() {
    final total = (isCashToUsdt || isCashToEDirham) ? convertAmount : splitTotal;
    if (total <= 0) {
      _showMsg('Please enter a valid amount.');
      return;
    }
    if (total > totalPortfolio) {
      _showMsg('Total transfer/convert must be <= total portfolio.');
      return;
    }
    _showMsg('Conversion confirmed with OTP via WhatsApp.');
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
