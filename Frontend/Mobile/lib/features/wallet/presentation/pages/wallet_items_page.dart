import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    show WalletTransactionEntity;
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_holding_item_widget.dart';

class WalletItemsPage extends StatelessWidget {
  final List<WalletTransactionEntity> transactions;
  const WalletItemsPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Wallet Items',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.primary,
          ),
        ),
      ),
      body: transactions.isEmpty
          ? EmptyStateWidget(
              icon: Icons.diamond_outlined,
              title: 'No Items in Wallet',
              message: 'Your wallet is empty. Start by adding your first gold item to view it here.',
            )
          : ListView.builder(
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
