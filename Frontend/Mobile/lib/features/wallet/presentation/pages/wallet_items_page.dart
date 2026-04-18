import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    show WalletTransactionEntity;
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_holding_item_widget.dart';

class WalletItemsPage extends StatefulWidget {
  final List<WalletTransactionEntity> transactions;
  const WalletItemsPage({super.key, required this.transactions});

  @override
  State<WalletItemsPage> createState() => _WalletItemsPageState();
}

class _WalletItemsPageState extends State<WalletItemsPage> {
  late List<WalletTransactionEntity> _transactions;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _transactions = List<WalletTransactionEntity>.from(widget.transactions);
  }

  Future<void> _reloadTransactions() async {
    if (_transactions.isEmpty) return;
    setState(() => _isRefreshing = true);
    try {
      final wallets = await InjectionContainer.loadWalletsUseCase().call();
      if (wallets.isEmpty) return;
      final targetCategory = _transactions.first.category;
      final refreshedWallet = wallets.firstWhere(
        (wallet) => wallet.category == targetCategory,
        orElse: () => wallets.first,
      );
      if (!mounted) return;
      setState(() {
        _transactions = List<WalletTransactionEntity>.from(refreshedWallet.transactions);
      });
    } catch (_) {
      // Keep existing list if refresh fails.
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Items')),
      body: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final item = _transactions[index];
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
              ).then((_) => _reloadTransactions());
            },
            onGiftTransfer: () {
              Navigator.pushNamed(
                context,
                AppRoutes.walletAssetTransferRoute,
                arguments: item,
              ).then((_) => _reloadTransactions());
            },
            onGenerateTaxInvoice: () {
              Navigator.pushNamed(
                context,
                AppRoutes.walletTaxInvoiceRoute,
                arguments: item,
              ).then((_) => _reloadTransactions());
            },
            onPickup: () {
              Navigator.pushNamed(
                context,
                AppRoutes.walletPickupRoute,
                arguments: item,
              ).then((_) => _reloadTransactions());
            },
          );
        },
      ),
      floatingActionButton: _isRefreshing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : null,
    );
  }
}
