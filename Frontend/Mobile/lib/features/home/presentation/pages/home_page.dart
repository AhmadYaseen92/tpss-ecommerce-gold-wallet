import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/PortfolioCardWidget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/home_carousel_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/summary_transaction_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onViewAllHistory});

  final VoidCallback onViewAllHistory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            HomeCarouselWidget(),
            SizedBox(height: 20),
            BlocBuilder<WalletCubit, WalletState>(
              builder: (context, state) {
                if (state is WalletLoaded) {
                  final wallets = state.wallets;
                  final totalMarket = wallets.fold<double>(
                    0,
                    (sum, wallet) =>
                        sum +
                        (double.tryParse(
                          wallet.totalMarketValue.replaceAll(RegExp(r'[^0-9.]'), ''),
                        ) ?? 0),
                  );
                  final avgChange = wallets.isEmpty
                      ? 0.0
                      : wallets
                              .map((wallet) => double.tryParse(wallet.change.replaceAll('%', '').replaceAll('+', '')) ?? 0)
                              .reduce((a, b) => a + b) /
                          wallets.length;
                  final totalCash = wallets.isNotEmpty ? wallets.first.cashBalance : '\$0.00';

                  return PortfolioCardWidget(
                    title: 'Total Portfolio Value',
                    value: '\$ ${totalMarket.toStringAsFixed(2)}',
                    change: '${avgChange >= 0 ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                    availableCash: totalCash,
                  );
                } else if (state is WalletLoading) {
                  return const CircularProgressIndicator();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoaded) {
                  // Show only the most recent 4 transactions
                  final recent = state.transactions.take(4).toList();
                  return SummaryTransactionWidget(
                    onViewAllHistory: onViewAllHistory,
                    transactions: recent,
                  );
                } else if (state is TransactionLoading) {
                  return const CircularProgressIndicator();
                } else {
                  return SummaryTransactionWidget(
                    onViewAllHistory: onViewAllHistory,
                    transactions: const [],
                  );
                }
              },
            ),

            // const SizedBox(height: 20),

            //HomeQuickActionsWidget(),
          ],
        ),
      ),
    );
  }
}
