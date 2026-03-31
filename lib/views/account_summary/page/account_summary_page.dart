import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_conversion_request_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/account_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/account_summary_cubit/account_summary_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/account_summary/page/account_summary_confirmation_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/account_summary/widgets/account_method_form.dart';
import 'package:tpss_ecommerce_gold_wallet/views/account_summary/widgets/account_portfolio_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';

class AccountSummaryPage extends StatelessWidget {
  const AccountSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = AccountSummaryModel(
      holdMarketValue: 12450.0,
      goldValue: 8700.0,
      silverValue: 2100.0,
      jewelleryValue: 1650.0,
      availableCash: 12450.0,
      usdtBalance: 12450.0,
      eDirhamBalance: 45727.95,
    );

    return BlocProvider(
      create: (_) => AccountSummaryCubit(),
      child: BlocConsumer<AccountSummaryCubit, AccountSummaryState>(
        listener: (context, state) {
          if (state is AccountSummaryFormState &&
              state.errorMessage != null &&
              state.errorMessage!.isNotEmpty) {
            AppModalAlert.show(
              context,
              title: 'Validation',
              message: state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AccountSummaryCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('My Account Summary'), centerTitle: true),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AccountPortfolioCard(
                  summary: summary,
                  totalPortfolio: AccountSummaryCubit.totalPortfolio,
                  selectedMethod: state is AccountSummaryFormState
                      ? state.selectedMethod
                      : ConvertMethod.transferToBank,
                ),
                const AccountMethodForm(),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Review Summary',
                  icon: Icons.summarize_outlined,
                  onPressed: () {
                    final request = cubit.buildRequest();
                    if (request == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountSummaryConfirmationPage(
                          request: request,
                          totalPortfolio: AccountSummaryCubit.totalPortfolio,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
