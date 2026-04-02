import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_symbol_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/market_order_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/notification_model.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/grams_hint_label.dart';

class MarketOrderRepository {
  static int _nextOrderId = 1005;
  static bool _seeded = false;
  static final List<MarketOrderModel> _orders = <MarketOrderModel>[];
  static final Map<String, Timer> _settlementTimers = <String, Timer>{};
  static final Map<String, double> _accountBalances = {
    PredefinedAccountsData.bankAccounts[0].name: 12000,
    PredefinedAccountsData.bankAccounts[1].name: 250,
    PredefinedAccountsData.paymentMethods[0].name: 5000,
    PredefinedAccountsData.paymentMethods[1].name: 800,
    PredefinedAccountsData.paymentMethods[2].name: 300,
  };

  static List<MarketOrderModel> get orders {
    _ensureSeedData();
    return List.unmodifiable(_orders.reversed);
  }

  static MarketOrderModel placeOrder({
    required String symbol,
    required String seller,
    required int quantity,
    required double unitPrice,
    required String paymentMethod,
    required String paymentAccount,
  }) {
    _ensureSeedData();
    final order = MarketOrderModel(
      id: 'MO-${_nextOrderId++}',
      symbol: symbol,
      seller: seller,
      quantity: quantity,
      unitPrice: unitPrice,
      paymentMethod: paymentMethod,
      paymentAccount: paymentAccount,
      status: MarketOrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.add(order);
    _scheduleAutoSettlement(order.id);
    todayNotifications.insert(
      0,
      NotificationModel(
        title: 'Market Order Pending',
        description: 'Order ${order.id} submitted and now pending settlement.',
        dateTime: DateTime.now(),
        icon: const Icon(Icons.hourglass_top_rounded, color: AppColors.amber),
      ),
    );
    return order;
  }

  static MarketOrderModel? settleOrder(String orderId) {
    _ensureSeedData();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;
    final order = _orders[index];
    if (order.status != MarketOrderStatus.pending) return order;

    _settlementTimers.remove(orderId)?.cancel();
    final accountBalance = getAccountBalance(order.paymentAccount);
    if (accountBalance < order.total) {
      final rejected = order.copyWith(status: MarketOrderStatus.rejected);
      _orders[index] = rejected;
      todayNotifications.insert(
        0,
        NotificationModel(
          title: 'Pending Order Rejected',
          description: 'Insufficient account balance for ${order.symbol}.',
          dateTime: DateTime.now(),
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.red),
        ),
      );
      return rejected;
    }

    _accountBalances[order.paymentAccount] = accountBalance - order.total;
    final filled = order.copyWith(status: MarketOrderStatus.filled);
    _orders[index] = filled;
    _addToWallet(filled);

    todayNotifications.insert(
      0,
      NotificationModel(
        title: 'Order Completed',
        description: 'Order ${order.id} completed and added to Spot MR wallet.',
        dateTime: DateTime.now(),
        icon: const Icon(Icons.check_circle, color: AppColors.green),
      ),
    );

    return filled;
  }

  static MarketOrderModel? reopenOrderAsPending({
    required String orderId,
    required double liveUnitPrice,
    required int quantity,
    required String paymentMethod,
    required String paymentAccount,
  }) {
    _ensureSeedData();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return null;
    final order = _orders[index];
    if (order.status != MarketOrderStatus.rejected) return order;

    final reopened = order.copyWith(
      status: MarketOrderStatus.pending,
      unitPrice: liveUnitPrice,
      quantity: quantity,
      paymentMethod: paymentMethod,
      paymentAccount: paymentAccount,
    );
    _orders[index] = reopened;
    _scheduleAutoSettlement(orderId);
    return reopened;
  }

  static void cancelOrder(String orderId) {
    _ensureSeedData();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    _orders[index] = _orders[index].copyWith(status: MarketOrderStatus.cancelled);
    _settlementTimers.remove(orderId)?.cancel();
  }

  static double livePriceForSymbol(String symbol, {double fallback = 0}) {
    final match = initialMarketSymbols.where((item) => item.symbol == symbol);
    if (match.isEmpty) return fallback;
    return match.first.price;
  }

  static double getAccountBalance(String accountName) {
    return _accountBalances[accountName] ?? 0;
  }

  static void _ensureSeedData() {
    if (_seeded) return;
    _seeded = true;

    final sampleOrders = <MarketOrderModel>[
      MarketOrderModel(
        id: 'MO-1001',
        symbol: 'XAU-1OZ',
        seller: 'Imseeh',
        quantity: 1,
        unitPrice: 2189.40,
        paymentMethod: 'Bank Account',
        paymentAccount: PredefinedAccountsData.bankAccounts[0].name,
        status: MarketOrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MarketOrderModel(
        id: 'MO-1002',
        symbol: 'XAU-10G',
        seller: 'Imseeh',
        quantity: 2,
        unitPrice: 704.50,
        paymentMethod: 'Card',
        paymentAccount: PredefinedAccountsData.paymentMethods[0].name,
        status: MarketOrderStatus.filled,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MarketOrderModel(
        id: 'MO-1003',
        symbol: 'XAG-1KG',
        seller: 'Da’naa',
        quantity: 1,
        unitPrice: 793.15,
        paymentMethod: 'Bank Account',
        paymentAccount: PredefinedAccountsData.bankAccounts[1].name,
        status: MarketOrderStatus.rejected,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketOrderModel(
        id: 'MO-1004',
        symbol: 'GCJ26',
        seller: 'Sakkejha',
        quantity: 1,
        unitPrice: 2194.80,
        paymentMethod: 'Card',
        paymentAccount: PredefinedAccountsData.paymentMethods[1].name,
        status: MarketOrderStatus.cancelled,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _orders.addAll(sampleOrders);
    for (final order in sampleOrders.where((o) => o.status == MarketOrderStatus.pending)) {
      _scheduleAutoSettlement(order.id, delay: const Duration(seconds: 5));
    }
    for (final order in sampleOrders.where((o) => o.status == MarketOrderStatus.filled)) {
      _addToWallet(order);
    }
  }

  static void _scheduleAutoSettlement(String orderId, {Duration delay = const Duration(seconds: 4)}) {
    _settlementTimers.remove(orderId)?.cancel();
    _settlementTimers[orderId] = Timer(delay, () {
      settleOrder(orderId);
      _settlementTimers.remove(orderId)?.cancel();
    });
  }

  static void _addToWallet(MarketOrderModel order) {
    final goldWalletIndex = dummyWallets.indexWhere((wallet) => wallet.category == WalletCategory.spotMr);
    if (goldWalletIndex == -1) return;

    final wallet = dummyWallets[goldWalletIndex];
    final existing = wallet.transactions.any((tx) => tx.subtitle.contains(order.id));
    if (existing) return;
    final gramsPerUnit = GramsConverter.fromSymbol(order.symbol);
    final totalWeight = gramsPerUnit * order.quantity;
    final tx = WalletTransaction(
      name: 'Spot MR ${order.symbol}',
      category: WalletCategory.spotMr,
      assetType: AssetType.gram,
      subtitle: '${order.quantity} unit • ${totalWeight.toStringAsFixed(2)} g • Spot MR • ${order.id}',
      weightInGrams: totalWeight,
      purity: '999.9',
      quantity: order.quantity,
      marketValue: '\$${order.total.toStringAsFixed(2)}',
      change: '+0.00%',
      sellerName: order.seller,
      imageUrl: 'https://images.unsplash.com/photo-1610375461246-83df859d849d?q=80&w=800',
      isSpotMrOrder: true,
    );

    final updatedTx = [tx, ...wallet.transactions];
    final nextTotal = updatedTx.fold<double>(0, (sum, item) => sum + item.marketValueAmount);
    dummyWallets[goldWalletIndex] = wallet.copyWith(
      transactions: updatedTx,
      totalHoldings: updatedTx.length,
      totalMarketValue: '\$${nextTotal.toStringAsFixed(2)}',
      totalWeightInGrams: updatedTx.fold<double>(0, (sum, item) => sum + item.weightInGrams),
    );
  }

}
