import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

enum ConvertMethod {
  cashSettlement,
  cashToUsdt,
  cashToEDirham,
}

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

  final portfolioToCashController = TextEditingController();
  final bankAmountController = TextEditingController();
  final cardAmountController = TextEditingController();
  final convertAmountController = TextEditingController();

  static const double totalPortfolio = 12450.0;

  double get portfolioToCash => double.tryParse(portfolioToCashController.text.trim()) ?? 0;
  double get bankAmount => double.tryParse(bankAmountController.text.trim()) ?? 0;
  double get cardAmount => double.tryParse(cardAmountController.text.trim()) ?? 0;
  double get convertAmount => double.tryParse(convertAmountController.text.trim()) ?? 0;

  bool get isCashSettlement => selectedMethod == ConvertMethod.cashSettlement;
  bool get isCashToUsdt => selectedMethod == ConvertMethod.cashToUsdt;
  bool get isCashToEDirham => selectedMethod == ConvertMethod.cashToEDirham;

  @override
  void dispose() {
    portfolioToCashController.dispose();
    bankAmountController.dispose();
    cardAmountController.dispose();
    convertAmountController.dispose();
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
      body: Form(
        key: _formKey,
        child: ListView(
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
              title: 'Step 1: Convert Portfolio to Cash',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: portfolioToCashController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Cash amount from portfolio',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = double.tryParse((v ?? '').trim());
                      if (value == null || value <= 0) {
                        return 'Enter a valid amount.';
                      }
                      if (value > totalPortfolio) {
                        return 'Amount must be <= total portfolio.';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cash is used only as conversion stage, then settled to bank/card or converted to USDT/eDirham.',
                    style: TextStyle(fontSize: 12, color: AppColors.greyShade600),
                  ),
                ],
              ),
            ),
            ActionSectionCard(
              title: 'Step 2: Complete Conversion',
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
                      DropdownMenuItem(
                        value: ConvertMethod.cashSettlement,
                        child: Text('Cash Settlement (Bank/Card/Both)'),
                      ),
                      DropdownMenuItem(
                        value: ConvertMethod.cashToUsdt,
                        child: Text('Cash to USDT'),
                      ),
                      DropdownMenuItem(
                        value: ConvertMethod.cashToEDirham,
                        child: Text('Cash to EDirham'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedMethod = value;
                        bankAmountController.clear();
                        cardAmountController.clear();
                        convertAmountController.clear();
                      });
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
                        final value = double.tryParse((v ?? '').trim()) ?? 0;
                        if (value < 0) return 'Amount cannot be negative.';
                        final total = value + cardAmount;
                        if (total > portfolioToCash) {
                          return 'Bank + Card must be <= cash amount.';
                        }
                        return null;
                      },
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
                        final value = double.tryParse((v ?? '').trim()) ?? 0;
                        if (value < 0) return 'Amount cannot be negative.';
                        final total = value + bankAmount;
                        if (total <= 0) return 'Enter bank/card amount.';
                        if (total > portfolioToCash) {
                          return 'Bank + Card must be <= cash amount.';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ],

                  if (isCashToUsdt || isCashToEDirham) ...[
                    TextFormField(
                      controller: convertAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount to Convert',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (!(isCashToUsdt || isCashToEDirham)) return null;
                        final value = double.tryParse((v ?? '').trim());
                        if (value == null || value <= 0) return 'Enter a valid amount.';
                        if (value > portfolioToCash) {
                          return 'Convert amount must be <= cash amount.';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (isCashToUsdt)
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
                    if (isCashToEDirham)
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
                  ],

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _onConfirm,
                      icon: const Icon(Icons.verified_user_outlined),
                      label: const Text('Confirm with OTP'),
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

  void _onConfirm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final total = portfolioToCash;
    if (total > totalPortfolio) {
      _showMsg('Total transfer/convert must be <= total portfolio.');
      return;
    }

    _showMsg('OTP sent to WhatsApp. Confirm to complete conversion.');
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
