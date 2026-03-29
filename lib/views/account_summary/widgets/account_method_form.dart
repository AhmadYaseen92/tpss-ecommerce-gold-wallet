import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/account_summary_cubit/account_summary_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';

class AccountMethodForm extends StatelessWidget {
  const AccountMethodForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSummaryCubit, AccountSummaryState>(
      builder: (context, state) {
        final cubit = context.read<AccountSummaryCubit>();
        return ActionSectionCard(
          title: 'Transfer / Convert Method',
          child: Column(
            children: [
              DropdownButtonFormField<ConvertMethod>(
                value: state.selectedMethod,
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
                  if (value != null) cubit.setMethod(value);
                },
              ),
              const SizedBox(height: 12),
              _selectorByMethod(cubit, state),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: state.amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                onChanged: cubit.setAmount,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: state.note,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: cubit.setNote,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _selectorByMethod(AccountSummaryCubit cubit, AccountSummaryState state) {
    switch (state.selectedMethod) {
      case ConvertMethod.transferToBank:
        return PredefinedAccountSelector(
          label: 'Bank Account',
          accounts: PredefinedAccountsData.bankAccounts,
          selectedIndex: state.selectedBankIndex,
          icon: Icons.account_balance_outlined,
          onChanged: (index) {
            if (index != null) cubit.setBankIndex(index);
          },
        );
      case ConvertMethod.transferToCard:
        return PredefinedAccountSelector(
          label: 'Card Account',
          accounts: PredefinedAccountsData.paymentMethods,
          selectedIndex: state.selectedPaymentIndex,
          icon: Icons.credit_card_outlined,
          onChanged: (index) {
            if (index != null) cubit.setPaymentIndex(index);
          },
        );
      case ConvertMethod.transferToUsdt:
        return PredefinedAccountSelector(
          label: 'USDT Account',
          accounts: PredefinedAccountsData.usdtAccounts,
          selectedIndex: state.selectedUsdtIndex,
          icon: Icons.currency_bitcoin,
          onChanged: (index) {
            if (index != null) cubit.setUsdtIndex(index);
          },
        );
      case ConvertMethod.transferToEDirham:
        return PredefinedAccountSelector(
          label: 'E-Dirham Account',
          accounts: PredefinedAccountsData.eDirhamAccounts,
          selectedIndex: state.selectedEDirhamIndex,
          icon: Icons.account_balance_wallet_outlined,
          onChanged: (index) {
            if (index != null) cubit.setEDirhamIndex(index);
          },
        );
    }
  }
}
