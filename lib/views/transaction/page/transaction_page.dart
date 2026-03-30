import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transaction_cubit/transaction_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/widget/transaction_filter_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/widget/transaction_item_widget.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AppCubit>().state.selectedSeller;
    return BlocProvider(
      create: (context) {
        final cubit = TransactionCubit();
        cubit.loadTransactions(seller: seller);
        return cubit;
      },
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.selectedSeller != current.selectedSeller,
        listener: (context, state) {
          context.read<TransactionCubit>().onGlobalSellerChanged(state.selectedSeller);
        },
        child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionInitial || state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                backgroundColor: AppColors.darkGold,
              ),
            );
          } else if (state is TransactionLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (AppReleaseConfig.showSellerUi)
                  Container(
                    width: double.infinity,
                    color: AppColors.luxuryIvory,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      seller == AppReleaseConfig.allSellersLabel
                          ? 'Transactions scope: all sellers'
                          : 'Transactions scope: $seller',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History exported to Excel sheet.')),
                        );
                      },
                      icon: const Icon(Icons.table_chart_outlined),
                      label: const Text('Export to Excel'),
                    ),
                  ),
                ),
                TransactionFilterBar(
                  transactionCubit: BlocProvider.of<TransactionCubit>(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    'RECENT ACTIVITY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: state.transactions.isEmpty
                      ? const Center(child: Text('No transactions found.', style: TextStyle(color: AppColors.grey)))
                      : ListView.builder(
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            return TransactionItemWidget(transaction: state.transactions[index]);
                          },
                        ),
                ),
              ],
            );
          } else if (state is TransactionError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
        ),
      ),
    );
  }
}
