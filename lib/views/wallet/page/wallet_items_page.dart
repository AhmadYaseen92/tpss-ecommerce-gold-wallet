import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart'
    show WalletTransaction;
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_holding_item_widget.dart';

class WalletItemsPage extends StatelessWidget {
  final List<WalletTransaction> transactions;
  const WalletItemsPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Items')),
      body: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final item = transactions[index];

          return WalletHoldingItemWidget(
            item: item,
            onSell: () {
              final summary = WalletActionSummary(
                asset: item,
                actionType: WalletActionType.sell,
                title: "Sell Gold",
                primaryValue: "2 Units",
                feeValue: "\$25",
                totalValue: "\$6,250",
                destinationLabel: "Payout",
                destinationValue: "",
                note: "",
                referenceNumber: "",
                createdAt: DateTime.now(),
              );
              Navigator.pushNamed(
                context,
                AppRoutes.walletAssetSellRoute,
                arguments: summary,
              );
            },
            onGiftTransfer: () {
              // navigate to gift / transfer page
            },
            onConvert: () {
              // navigate to convert page
            },
          );
        },
      ),
    );
  }
}
