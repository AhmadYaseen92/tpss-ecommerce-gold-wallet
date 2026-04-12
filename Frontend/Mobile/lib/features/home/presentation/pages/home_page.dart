import 'package:flutter/material.dart';
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
            PortfolioCardWidget(
              title: 'Total Portfolio Value',
              value: '\$ 1,500,000',
              change: '+5.2%',
              availableCash: '\$ 200,000',
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
