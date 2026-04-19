import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    show WalletTransactionEntity;
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_holding_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';

class WalletItemsPage extends StatefulWidget {
  final List<WalletTransactionEntity> transactions;

  const WalletItemsPage({
    super.key,
    required this.transactions,
  });

  @override
  State<WalletItemsPage> createState() => _WalletItemsPageState();
}

class _WalletItemsPageState extends State<WalletItemsPage> {
  late List<WalletTransactionEntity> _transactions;
  bool _isRefreshing = false;
  StreamSubscription<void>? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _transactions = List<WalletTransactionEntity>.from(
      widget.transactions,
    );
    _startRealtimeRefresh();
  }

  Future<void> _startRealtimeRefresh() async {
    await InjectionContainer.realtimeRefreshService().ensureStarted();
    _realtimeSubscription =
        InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      if (!mounted) return;
      _reloadTransactions();
    });
  }

  Future<void> _reloadTransactions() async {
    if (_transactions.isEmpty) return;

    setState(() => _isRefreshing = true);

    try {
      final wallets =
          await InjectionContainer.loadWalletsUseCase().call();

      if (wallets.isEmpty) return;

      final targetCategory =
          _transactions.first.category;

      final refreshedWallet = wallets.firstWhere(
        (wallet) =>
            wallet.category == targetCategory,
        orElse: () => wallets.first,
      );

      if (!mounted) return;

      setState(() {
        _transactions =
            List<WalletTransactionEntity>.from(
          refreshedWallet.transactions,
        );
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _navigateAndRefresh(
    String route,
    dynamic arguments,
  ) async {
    await Navigator.pushNamed(
      context,
      route,
      arguments: arguments,
    );

    await _reloadTransactions();
  }

  Future<void> _cancelPendingRequest(WalletTransactionEntity item) async {
    final userId = AuthSessionStore.userId;
    if (userId == null) return;

    await InjectionContainer.dio().post(
      '/wallet/actions/cancel-request',
      data: {
        'userId': userId,
        'walletAssetId': item.id,
      },
    );
    await _reloadTransactions();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Wallet Items',
          style:
              Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w600,
                    color: palette.primary,
                  ),
        ),
      ),
      floatingActionButton: _isRefreshing
          ? const SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(),
            )
          : null,
      body: _transactions.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.diamond_outlined,
              title: 'No Items in Wallet',
              message:
                  'Your wallet is empty. Start by adding your first gold item to view it here.',
            )
          : ListView.builder(
              itemCount:
                  _transactions.length,
              itemBuilder:
                  (context, index) {
                final item =
                    _transactions[index];

                return WalletHoldingItemWidget(
                  item: item,
                  onSell: () {
                    final summary =
                        WalletActionSummary(
                      asset: item,
                      actionType:
                          WalletActionType
                              .sell,
                      title:
                          'Sell Gold',
                      primaryValue:
                          '${item.quantity} Units',
                      feeValue:
                          '\$25',
                      totalValue:
                          item.marketValue,
                      destinationLabel:
                          'Payout',
                      destinationValue:
                          'Wallet Cash',
                      note: '',
                      referenceNumber:
                          '',
                      createdAt:
                          DateTime.now(),
                    );

                    _navigateAndRefresh(
                      AppRoutes
                          .walletAssetSellRoute,
                      summary,
                    );
                  },
                  onGiftTransfer: () {
                    _navigateAndRefresh(
                      AppRoutes
                          .walletAssetTransferRoute,
                      item,
                    );
                  },
                  onGenerateTaxInvoice:
                      () {
                    _navigateAndRefresh(
                      AppRoutes
                          .walletTaxInvoiceRoute,
                      item,
                    );
                  },
                  onPickup: () {
                    _navigateAndRefresh(
                      AppRoutes
                          .walletPickupRoute,
                      item,
                    );
                  },
                  onCancelRequest: () => _cancelPendingRequest(item),
                );
              },
            ),
    );
  }
}
