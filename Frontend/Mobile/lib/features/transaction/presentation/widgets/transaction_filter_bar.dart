import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_filter_dropdown.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionCubit transactionCubit;

  const TransactionFilterBar({super.key, required this.transactionCubit});

  static const List<String> periods = [
    'All Periods',
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
  ];
  static const List<String> types = [
    'All Types',
    'Buy',
    'Sell',
    'Transfer',
    'Gift',
    'Pickup',
  ];
  static const List<String> statuses = [
    'All Statuses',
    'Approved',
    'Pending',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: BlocBuilder<TransactionCubit, TransactionState>(
        bloc: transactionCubit,
        builder: (context, state) {
          return Row(
            children: [
              FilterDropdown(
                value: transactionCubit.selectedPeriod,
                items: periods,
                isActive: transactionCubit.selectedPeriod != 'All Periods',
                onChanged: (val) {
                  if (val != null) transactionCubit.filterByPeriod(val);
                },
              ),
              const SizedBox(width: 8),
              FilterDropdown(
                value: transactionCubit.selectedType,
                items: types,
                isActive: transactionCubit.selectedType != 'All Types',
                onChanged: (val) {
                  if (val != null) transactionCubit.filterByType(val);
                },
              ),
              const SizedBox(width: 8),
              FilterDropdown(
                value: transactionCubit.selectedStatus,
                items: statuses,
                isActive: transactionCubit.selectedStatus != 'All Statuses',
                onChanged: (val) {
                  if (val != null) transactionCubit.filterByStatus(val);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
