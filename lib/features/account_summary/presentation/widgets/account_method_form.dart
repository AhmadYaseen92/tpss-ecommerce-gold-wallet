import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/features/convert/data/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/account_summary/presentation/cubit/account_summary_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_form_dropdown.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';

class AccountMethodForm extends StatelessWidget {
  const AccountMethodForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSummaryCubit, AccountSummaryState>(
      builder: (context, state) {
        final cubit = context.read<AccountSummaryCubit>();
        final formState = state is AccountSummaryFormState
            ? state
            : AccountSummaryFormState.initial();

        return ActionSectionCard(
          title: 'Transfer / Convert Method',
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                AppFormDropdown<ConvertMethod>(
                  label: 'Method',
                  value: formState.selectedMethod,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  items: const [
                    DropdownMenuItem(
                      value: ConvertMethod.transferToBank,
                      child: Text('Transfer To Bank Account'),
                    ),
                    DropdownMenuItem(
                      value: ConvertMethod.transferToCard,
                      child: Text('Transfer To Card Account'),
                    ),
                    DropdownMenuItem(
                      value: ConvertMethod.transferToUsdt,
                      child: Text('Transfer To USDT Account'),
                    ),
                    DropdownMenuItem(
                      value: ConvertMethod.transferToEDirham,
                      child: Text('Transfer To E-Dirham Account'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) cubit.setMethod(value);
                  },
                ),
                const SizedBox(height: 12),
                _selectorByMethod(cubit, formState),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Amount',
                  hint: 'Amount',
                  initialValue: formState.amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: cubit.setAmount,
                  validator: (value) {
                    final amountText = (value ?? '').trim();
                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) return 'Enter a valid amount.';
                    if (amount > AccountSummaryCubit.totalPortfolio) {
                      return 'Amount must be <= total portfolio.';
                    }
                    return null;
                  },
                ),
                if (formState.selectedMethod == ConvertMethod.transferToUsdt ||
                    formState.selectedMethod == ConvertMethod.transferToEDirham) ...[
                  const SizedBox(height: 12),
                  Builder(
                    builder: (_) {
                      final convertedAmount =
                          cubit.convertedAmountLabel(formState) ?? '';
                      return AppTextField(
                        key: ValueKey(convertedAmount),
                        label:
                            formState.selectedMethod == ConvertMethod.transferToUsdt
                            ? 'Converted Amount (USDT)'
                            : 'Converted Amount (E-Dirham)',
                        hint: 'Calculated amount',
                        initialValue: convertedAmount,
                        enabled: false,
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Note',
                  hint: 'Note (Optional)',
                  initialValue: formState.note,
                  onChanged: cubit.setNote,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _selectorByMethod(AccountSummaryCubit cubit, AccountSummaryFormState state) {
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
