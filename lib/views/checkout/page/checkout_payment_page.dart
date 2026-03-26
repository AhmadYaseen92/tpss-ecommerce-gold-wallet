import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/checkout_cubit/checkout_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutCubit()..load(),
      child: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment confirmed with WhatsApp OTP.')),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CheckoutCubit>();
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(title: const Text('Process Checkout'), centerTitle: true),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ActionSectionCard(
                    title: 'Select Payment Method',
                    child: Column(
                      children: CheckoutPaymentType.values.map((type) {
                        return _PaymentTile(
                          title: _label(type),
                          subtitle: _subtitle(type),
                          icon: _icon(type),
                          selected: cubit.selectedPaymentType == type,
                          onTap: () => cubit.selectPaymentType(type),
                        );
                      }).toList(),
                    ),
                  ),
                  if (cubit.selectedPaymentType == CheckoutPaymentType.bank)
                    ActionSectionCard(
                      title: 'Select Linked Bank Account',
                      child: PredefinedAccountSelector(
                        label: 'Bank Account',
                        accounts: PredefinedAccountsData.bankAccounts,
                        selectedIndex: selectedBankIndex,
                        icon: Icons.account_balance_outlined,
                        onChanged: (index) {
                          if (index == null) return;
                          setState(() => selectedBankIndex = index);
                        },
                      ),
                    ),
                  if (cubit.selectedPaymentType == CheckoutPaymentType.card)
                    ActionSectionCard(
                      title: 'Select Predefined Payment Method',
                      child: PredefinedAccountSelector(
                        label: 'Payment Method',
                        accounts: PredefinedAccountsData.paymentMethods,
                        selectedIndex: selectedPaymentIndex,
                        icon: Icons.credit_card_outlined,
                        onChanged: (index) {
                          if (index == null) return;
                          setState(() => selectedPaymentIndex = index);
                        },
                      ),
                    ),
                  ActionSectionCard(
                    title: 'Review Summary',
                    child: Column(
                      children: [
                        _row('Payment', _label(cubit.selectedPaymentType)),
                        if (cubit.selectedPaymentType == CheckoutPaymentType.bank)
                          _row('Account', PredefinedAccountsData.bankAccounts[selectedBankIndex].name),
                        if (cubit.selectedPaymentType == CheckoutPaymentType.card)
                          _row('Method', PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name),
                        _row('Amount', '\$1,250.00'),
                        _row('Fee', '\$0.00'),
                        const Divider(),
                        _row('Total', '\$1,250.00', bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: state is CheckoutLoading ? null : cubit.confirmOtp,
                    icon: state is CheckoutLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.lock_open_outlined),
                    label: const Text('Confirm Checkout'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _icon(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return Icons.account_balance_outlined;
      case CheckoutPaymentType.card:
        return Icons.credit_card_outlined;
      case CheckoutPaymentType.cash:
        return Icons.wallet_outlined;
    }
  }

  String _label(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Bank Account';
      case CheckoutPaymentType.card:
        return 'Credit Card';
      case CheckoutPaymentType.cash:
        return 'Cash Balance';
    }
  }

  String _subtitle(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Pay from linked bank account';
      case CheckoutPaymentType.card:
        return 'Pay using predefined payment method';
      case CheckoutPaymentType.cash:
        return 'Use wallet cash balance';
    }
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [Expanded(child: Text(label, style: style)), Text(value, style: style)],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.luxuryIvory : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primaryColor : AppColors.greysShade2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
