import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/dio_factory.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';

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
        data: {'userId': userId, 'pageNumber': 1, 'pageSize': 4},
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final items = (data?['items'] as List<dynamic>? ?? []);
      final transactions = items
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .take(4)
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
    final palette = context.appPalette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: palette.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Transaction',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.all(0.0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: widget.onViewAllHistory,
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          if (_loading)
            const Center(child: CircularProgressIndicator.adaptive())
          else if (_transactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your recent transactions will appear here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._buildRows(context),
        ],
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    final widgets = <Widget>[];
    for (var i = 0; i < _transactions.length; i++) {
      final tx = _transactions[i];
      widgets.add(
        _buildTransactionItem(
          context,
          '${tx.transactionType} ${tx.category}',
          '${tx.transactionType.toLowerCase() == 'buy' ? '-' : '+'} \$${tx.amount.toStringAsFixed(2)}',
        ),
      );
      if (i != _transactions.length - 1) {
        widgets.add(Divider(height: 20.0, thickness: 1.0, color: context.appPalette.border));
      }
    }
    return widgets;
  }

  Widget _buildTransactionItem(BuildContext context, String title, String amount) {
    return Row(
      children: [
        Icon(
          amount.startsWith('-') ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
          color: amount.startsWith('-') ? AppColors.red : AppColors.green,
        ),
        const SizedBox(width: 8.0),
        Expanded(child: Text(title, style: TextStyle(color: context.appPalette.textSecondary))),
        Text(
          amount,
          style: TextStyle(
            color: amount.startsWith('-') ? AppColors.red : AppColors.green,
          ),
        ),
      ],
    );
  }
}
