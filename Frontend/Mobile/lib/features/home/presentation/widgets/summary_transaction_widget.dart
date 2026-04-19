import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/dio_factory.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/recent_transactions_common_widget.dart';

class SummaryTransactionWidget extends StatefulWidget {
  const SummaryTransactionWidget({super.key, required this.onViewAllHistory});

  final VoidCallback onViewAllHistory;

  @override
  State<SummaryTransactionWidget> createState() => _SummaryTransactionWidgetState();
}

class _SummaryTransactionWidgetState extends State<SummaryTransactionWidget> {
  final Dio _dio = DioFactory.create();
  List<TransactionModel> _transactions = const <TransactionModel>[];
  bool _loading = true;
  StreamSubscription<String>? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRecentTransactions());
    unawaited(_bindRealtimeRefresh());
  }

  Future<void> _bindRealtimeRefresh() async {
    await InjectionContainer.realtimeRefreshService().ensureStarted();
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      unawaited(_loadRecentTransactions(silent: true));
    });
  }

  Future<void> _loadRecentTransactions({bool silent = false}) async {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      if (!silent && mounted) {
        setState(() {
          _transactions = const <TransactionModel>[];
          _loading = false;
        });
      }
      return;
    }

    if (!silent && mounted) {
      setState(() => _loading = true);
    }

    try {
      final response = await _dio.post(
        '/transaction-history/filter',
        data: {'userId': userId, 'pageNumber': 1, 'pageSize': 3},
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final items = (data?['items'] as List<dynamic>? ?? []);
      final transactions = items
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .take(3)
          .toList();

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final items = _transactions
        .map(
          (tx) => RecentTransactionViewModel(
            title: tx.productName.trim().isEmpty ? tx.category : tx.productName,
            subtitle: '${tx.transactionType} • ${tx.status}',
            amountText:
                '${tx.transactionType.toLowerCase() == 'buy' ? '-' : '+'} \$${tx.amount.toStringAsFixed(2)}',
            isPositive: tx.transactionType.toLowerCase() != 'buy',
            imageUrl: tx.productImageUrl,
            secondaryText: tx.isTransferOrGift ? '${tx.transferFromLabel} → ${tx.transferToLabel}' : null,
          ),
        )
        .toList();

    return RecentTransactionsCommonWidget(
      title: 'Recent Transactions',
      transactions: items,
      onViewAllHistory: widget.onViewAllHistory,
      maxItems: 3,
    );
  }
}
