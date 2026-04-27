import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart'
    show AssetType, WalletCategory, WalletTransactionEntity;
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_holding_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class WalletItemsPage extends StatefulWidget {
  final List<WalletTransactionEntity> transactions;
  final WalletCategory? initialCategory;

  const WalletItemsPage({
    super.key,
    required this.transactions,
    this.initialCategory,
  });

  @override
  State<WalletItemsPage> createState() => _WalletItemsPageState();
}

class _WalletItemsPageState extends State<WalletItemsPage> {
  late List<WalletTransactionEntity> _transactions;
  String _selectedFormFilter = 'All';
  bool _isRefreshing = false;
  StreamSubscription<void>? _realtimeSubscription;
  final IWalletActionRepository _walletActionRepository = InjectionContainer.walletActionRepository();
  WalletCategory? get _targetCategory =>
      _transactions.isNotEmpty ? _transactions.first.category : widget.initialCategory;

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
    setState(() => _isRefreshing = true);

    try {
      final wallets =
          await InjectionContainer.loadWalletsUseCase().call();

      if (wallets.isEmpty) return;

      final targetCategory = _targetCategory;

      final refreshedWallet = wallets.firstWhere(
        (wallet) => wallet.category == targetCategory,
        orElse: () => wallets.first,
      );

      if (!mounted) return;

      setState(() {
        _transactions =
            List<WalletTransactionEntity>.from(
          refreshedWallet.transactions,
        );
        _selectedFormFilter = 'All';
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
    await _walletActionRepository.cancelWalletRequest(walletAssetId: item.id);
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
    final formOptions = _buildFormOptions(_transactions);
    final filteredTransactions = _applyFormFilter(_transactions, _selectedFormFilter);

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
          : Column(
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: formOptions
                        .map((formLabel) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: AppFilterChip(
                                label: formLabel,
                                selected: _selectedFormFilter == formLabel,
                                onTap: () => setState(() => _selectedFormFilter = formLabel),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.inventory_2_outlined,
                          title: 'No Items for Selected Form',
                          message: 'Try changing the product form filter to see wallet items.',
                        )
                      : ListView.builder(
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final item = filteredTransactions[index];

                            return WalletHoldingItemWidget(
                              item: item,
                              onSell: () {
                                final summary = WalletActionSummary(
                                  asset: item,
                                  actionType: WalletActionType.sell,
                                  title: 'Sell Gold',
                                  primaryValue: '${item.quantity} Units',
                                  summary: ActionSummaryBuilder.fromBackendData({
                                    'subTotalAmount': 0,
                                    'totalFeesAmount': 0,
                                    'discountAmount': 0,
                                    'finalAmount': 0,
                                    'currency': 'USD',
                                    'feeBreakdowns': const [],
                                  }),
                                  destinationLabel: 'Payout',
                                  destinationValue: 'Wallet Cash',
                                  note: '',
                                  referenceNumber: '',
                                  createdAt: DateTime.now(),
                                );

                                _navigateAndRefresh(AppRoutes.walletAssetSellRoute, summary);
                              },
                              onGiftTransfer: () {
                                _navigateAndRefresh(AppRoutes.walletAssetTransferRoute, item);
                              },
                              onGenerateTaxInvoice: () {
                                _navigateAndRefresh(AppRoutes.walletTaxInvoiceRoute, item);
                              },
                              onPickup: () {
                                _navigateAndRefresh(AppRoutes.walletPickupRoute, item);
                              },
                              onCancelRequest: () => _cancelPendingRequest(item),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  List<String> _buildFormOptions(List<WalletTransactionEntity> items) {
    final forms = items.map(_resolveFormLabel).toSet().toList()..sort();
    return ['All', ...forms];
  }

  List<WalletTransactionEntity> _applyFormFilter(List<WalletTransactionEntity> items, String selectedForm) {
    if (selectedForm == 'All') return items;
    return items.where((item) => _resolveFormLabel(item) == selectedForm).toList();
  }

  String _resolveFormLabel(WalletTransactionEntity item) {
    return switch (item.assetType) {
      AssetType.coin => 'Coin',
      AssetType.necklace || AssetType.ring || AssetType.bracelet => 'Jewelry',
      _ => 'Bar',
    };
  }
}
