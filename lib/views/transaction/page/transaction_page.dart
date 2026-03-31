import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/services/transaction_excel_export_service.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/app_cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transaction_cubit/transaction_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/widget/transaction_filter_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transaction/widget/transaction_item_widget.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    final seller = context.watch<AppCubit>().state.selectedSeller;
    return BlocProvider(
      create: (context) {
        final cubit = TransactionCubit();
        cubit.loadTransactions(seller: seller);
        return cubit;
      },
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) =>
            previous.selectedSeller != current.selectedSeller,
        listener: (context, state) {
          context.read<TransactionCubit>().onGlobalSellerChanged(
            state.selectedSeller,
          );
        },
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state is TransactionInitial || state is TransactionLoading) {
              return const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              );
            } else if (state is TransactionLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TransactionFilterBar(
                    transactionCubit: BlocProvider.of<TransactionCubit>(
                      context,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'RECENT ACTIVITY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.grey,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: state.transactions.isEmpty
                              ? null
                              : () {
                                  _showExportPreview(
                                    context,
                                    transactions: state.transactions,
                                    cubit: context.read<TransactionCubit>(),
                                  );
                                },
                          icon: const Icon(Icons.table_chart_outlined, size: 18),
                          label: const Text('Export to Excel'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions found.',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.transactions.length,
                            itemBuilder: (context, index) {
                              return TransactionItemWidget(
                                transaction: state.transactions[index],
                              );
                            },
                          ),
                  ),
                ],
              );
            } else if (state is TransactionError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<void> _showExportPreview(
    BuildContext context, {
    required List<TransactionModel> transactions,
    required TransactionCubit cubit,
  }) async {
    final excelService = TransactionExcelExportService();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Filtered Export Preview'),
          content: SizedBox(
            width: 900,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rows to export: ${transactions.length}'),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Title')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Secondary')),
                          DataColumn(label: Text('Seller')),
                        ],
                        rows: transactions
                            .map(
                              (transaction) => DataRow(
                                cells: [
                                  DataCell(Text(transaction.id)),
                                  DataCell(Text(transaction.title)),
                                  DataCell(Text(transaction.type)),
                                  DataCell(Text(transaction.status)),
                                  DataCell(
                                    Text(_dateFormat.format(transaction.date)),
                                  ),
                                  DataCell(Text(transaction.amount)),
                                  DataCell(Text(transaction.secondaryAmount ?? '-')),
                                  DataCell(Text(transaction.sellerName)),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final bytes = await excelService.buildExcelBytes(
                  transactions: transactions,
                  selectedPeriod: cubit.selectedPeriod,
                  selectedType: cubit.selectedType,
                  selectedStatus: cubit.selectedStatus,
                  selectedSeller: cubit.activeSeller,
                );

                await _downloadExport(
                  context,
                  bytes: bytes,
                );

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Excel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadExport(
    BuildContext context, {
    required Uint8List bytes,
  }) async {
    try {
      final fileName =
          'transactions_export_${DateTime.now().millisecondsSinceEpoch}';

      await TransactionExcelExportService().downloadExcel(
        bytes: bytes,
        fileName: fileName,
      );

      if (context.mounted) {
        AppModalAlert.show(
          context,
          title: 'Export Complete',
          message: 'Filtered transaction history was exported successfully.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppModalAlert.show(
          context,
          title: 'Export Failed',
          message: 'Could not export transactions: $e',
        );
      }
    }
  }
}
