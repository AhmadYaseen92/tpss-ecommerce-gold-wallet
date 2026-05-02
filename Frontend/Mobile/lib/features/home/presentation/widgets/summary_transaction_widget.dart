import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/dio_factory.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/home/presentation/widgets/recent_transactions_common_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';

class SummaryTransactionWidget extends StatefulWidget {
  const SummaryTransactionWidget({
    super.key,
    required this.onViewAllHistory,
    this.title = 'Recent Transactions',
    this.maxItems = 3,
  });

  final VoidCallback onViewAllHistory;
  final String title;
  final int maxItems;

  @override
  State<SummaryTransactionWidget> createState() =>
      _SummaryTransactionWidgetState();
}

class _SummaryTransactionWidgetState
    extends State<SummaryTransactionWidget> {
  final Dio _dio = DioFactory.create();

  List<TransactionModel> _transactions = [];
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

    _realtimeSubscription =
        InjectionContainer.realtimeRefreshService().refreshes.listen((_) {
      unawaited(_loadRecentTransactions(silent: true));
    });
  }

  Future<void> _loadRecentTransactions({
    bool silent = false,
  }) async {
    final userId = AuthSessionStore.userId;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        _transactions = [];
        _loading = false;
      });
      return;
    }

    if (!silent && mounted) {
      setState(() => _loading = true);
    }

    try {
      final response = await _dio.post(
        '/transaction-history/filter',
        data: {
          'userId': userId,
          'pageNumber': 1,
          'pageSize': 3,
        },
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final items = data?['items'] as List<dynamic>? ?? [];

      final result = items
          .map(
            (e) => TransactionModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .take(widget.maxItems)
          .toList();

      if (!mounted) return;

      setState(() {
        _transactions = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final palette = context.appPalette;

    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textSecondary,
                ),
          ),
        ),
      );
    }

    final items = _transactions.map((tx) {
      final signedAmount = tx.signedAmount;
      final isPositive = signedAmount >= 0;
      final absAmount = signedAmount.abs();

      return RecentTransactionViewModel(
        title: tx.productName.trim().isEmpty
            ? tx.category
            : tx.productName,
        subtitle:
            '${tx.transactionType} • ${tx.status}',
        amountText:
            '${isPositive ? '+' : '-'} ${_normalizeCurrencyCode(tx.currency)} ${absAmount.toStringAsFixed(2)}',
        isPositive: isPositive,
        imageUrl: tx.productImageUrl,
        secondaryText: tx.isTransferOrGift
            ? '${tx.transferFromLabel} → ${tx.transferToLabel}'
            : null,
      );
    }).toList();

    return RecentTransactionsCommonWidget(
      title: widget.title,
      transactions: items,
      onViewAllHistory: widget.onViewAllHistory,
      maxItems: widget.maxItems,
    );
  }

  String _normalizeCurrencyCode(String raw) {
    final normalized = raw.trim().toUpperCase();
    return normalized.isEmpty ? 'USD' : normalized;
  }
}
