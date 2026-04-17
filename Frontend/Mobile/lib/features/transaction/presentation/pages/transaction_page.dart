import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/transaction_excel_export_service.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_filter_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_item_widget.dart';

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
            previous.selectedSeller != current.selectedSeller ||
            previous.checkoutRefreshTick != current.checkoutRefreshTick,
        listener: (context, state) {
          context.read<TransactionCubit>().loadTransactions(
            seller: state.selectedSeller,
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
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by product, category, type, notes...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: context.read<TransactionCubit>().filterBySearch,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ProductCategoryFilter.options.map((category) {
                          final cubit = context.read<TransactionCubit>();
                          final isSelected =
                              cubit.selectedCategoryId == category.categoryId;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AppFilterChip(
                              label: category.label,
                              selected: isSelected,
                              onTap: () => cubit.filterByCategory(
                                category.categoryId,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
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
                        : RefreshIndicator(
                            onRefresh: () => context.read<TransactionCubit>().loadTransactions(
                              seller: context.read<TransactionCubit>().activeSeller,
                            ),
                            child: ListView.builder(
                              itemCount: state.transactions.length,
                              itemBuilder: (context, index) {
                                return TransactionItemWidget(
                                  transaction: state.transactions[index],
                                  onTap: () => _showTransactionDetails(
                                    context,
                                    state.transactions[index],
                                  ),
                                );
                              },
                            ),
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
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Type')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Amount/Currency')),
                          DataColumn(label: Text('Weight/Unit')),
                          DataColumn(label: Text('UpdatedAtUtc')),
                        ],
                        rows: transactions
                            .map(
                              (transaction) => DataRow(
                                cells: [
                                  DataCell(Text('${transaction.id}')),
                                  DataCell(Text(transaction.category)),
                                  DataCell(Text(transaction.transactionType)),
                                  DataCell(Text(transaction.status)),
                                  DataCell(Text('${transaction.quantity}')),
                                  DataCell(Text('${transaction.amount.toStringAsFixed(2)} ${transaction.currency}')),
                                  DataCell(Text('${transaction.weight.toStringAsFixed(3)} ${transaction.unit}')),
                                  DataCell(Text(_dateFormat.format(transaction.displayDate.toLocal()))),
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

      final savedPath = await TransactionExcelExportService().saveExcel(
        bytes: bytes,
        fileName: fileName,
      );

      if (!kIsWeb && savedPath != null) {
        await OpenFilex.open(savedPath);
      }

      if (context.mounted) {
        AppModalAlert.show(
          context,
          title: 'Export Complete',
          message: kIsWeb
              ? 'File downloaded in browser downloads folder.'
              : 'Saved to simulator files at:\n$savedPath',
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

  Future<void> _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final updatedText = _dateFormat.format(transaction.displayDate.toLocal());
        final createdText = _dateFormat.format(transaction.createdAtUtc.toLocal());

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transaction Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _detailChip('Type', transaction.transactionType),
                            if (transaction.isGiftReceived)
                              _detailChip('Gift', 'Received'),
                            _detailChip('Status', transaction.status),
                            _detailChip('Category', transaction.category),
                            _detailChip('Qty', '${transaction.quantity}'),
                            _detailChip('Weight', '${transaction.weight.toStringAsFixed(3)} ${transaction.unit}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _detailRow('Id', '${transaction.id}'),
                        _detailRow('UserId', '${transaction.userId}'),
                        _detailRow('SellerId', '${transaction.sellerId ?? '-'}'),
                        if (transaction.isTransferOrGift) ...[
                          _detailRow('Transfer From', transaction.transferFromLabel),
                          _detailRow('Transfer To', transaction.transferToLabel),
                        ],
                        _detailRow('Unit Price', transaction.unitPrice.toStringAsFixed(2)),
                        _detailRow('Purity', transaction.purity.toStringAsFixed(2)),
                        _detailRow('Created', createdText),
                        _detailRow('Updated', updatedText),
                        _detailRow('Notes', transaction.notes.isEmpty ? '-' : transaction.notes),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _detailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.06),
      ),
      child: Text('$label: $value'),
    );
  }
}
