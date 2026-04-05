import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart'
    show WalletTransaction;
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_holding_item_widget.dart';

class WalletItemsPage extends StatelessWidget {
  final List<WalletTransaction> transactions;
  const WalletItemsPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Items')),
      body: ListView.builder(
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
                primaryValue: '${item.quantity} Units',
                feeValue: "\$25",
                totalValue: item.marketValue,
                destinationLabel: "Payout",
                destinationValue: 'Wallet Cash',
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
              Navigator.pushNamed(
                context,
                AppRoutes.walletAssetTransferRoute,
                arguments: item,
              );
            },
            onGenerateTaxInvoice: () {
              Navigator.pushNamed(
                context,
                AppRoutes.walletTaxInvoiceRoute,
                arguments: item,
              );
            },
            onPickup: () {
              Navigator.pushNamed(
                context,
                AppRoutes.walletPickupRoute,
                arguments: item,
              );
            },
          );
        },
      ),
    );
  }
}
