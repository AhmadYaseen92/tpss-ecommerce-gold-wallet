import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/home_carousel_Item_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/widgets/PortfolioCardWidget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/widgets/custom_carousel_slider.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/widgets/home_carousel_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/widgets/home_quick_actions_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/home/widgets/summary_transaction_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            //HomeCarouselWidget(),
            CustomCarouselSlider(),
            SizedBox(height: 20),
            PortfolioCardWidget(
              title: 'Total Portfolio Value',
              value: '\$ 1,500,000',
              change: '+5.2%',
              availableCash: '\$ 200,000',
            ),
            const SizedBox(height: 20),
            SummaryTransactionWidget(),

            // const SizedBox(height: 20),

            //HomeQuickActionsWidget(),
          ],
        ),
      ),
    );
  }
}
