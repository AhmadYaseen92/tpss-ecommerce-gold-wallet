import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
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
            FutureBuilder(
              future: InjectionContainer.loadWalletsUseCase().call(),
              builder: (context, snapshot) {
                final wallets = snapshot.data ?? const [];
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
              },
            ),
            const SizedBox(height: 20),
            SummaryTransactionWidget(onViewAllHistory: onViewAllHistory),

            // const SizedBox(height: 20),

            //HomeQuickActionsWidget(),
          ],
        ),
      ),
    );
  }
}
