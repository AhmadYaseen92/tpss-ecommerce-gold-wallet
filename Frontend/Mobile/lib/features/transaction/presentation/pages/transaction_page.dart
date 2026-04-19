import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_filter_chip.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/empty_state_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/product_category_filter.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/transaction_excel_export_service.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_filter_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/presentation/widgets/transaction_item_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final IWalletActionRepository _walletActionRepository = InjectionContainer.walletActionRepository();

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
                      onChanged: context
                          .read<TransactionCubit>()
                          .filterBySearch,
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
                              onTap: () =>
                                  cubit.filterByCategory(category.categoryId),
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
                          icon: const Icon(
                            Icons.table_chart_outlined,
                            size: 18,
                          ),
                          label: const Text('Export to Excel'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.transactions.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.receipt_long_outlined,
                            title: 'No Transactions',
                            message:
                                'Your transaction history will appear here when you make a purchase or add items.',
                          )
                        : RefreshIndicator(
                            onRefresh: () => context
                                .read<TransactionCubit>()
                                .loadTransactions(
                                  seller: context
                                      .read<TransactionCubit>()
                                      .activeSeller,
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
                                  DataCell(
                                    Text(
                                      '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${transaction.weight.toStringAsFixed(3)} ${transaction.unit}',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _dateFormat.format(
                                        transaction.displayDate.toLocal(),
                                      ),
                                    ),
                                  ),
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

                await _downloadExport(context, bytes: bytes);

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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final updatedText = _dateFormat.format(
          transaction.displayDate.toLocal(),
        );
        final createdText = _dateFormat.format(
          transaction.createdAtUtc.toLocal(),
        );

        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  /// Handle bar
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Transaction Details',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// Hero Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Color(0xffD4AF37), Color(0xffB8860B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.transactionType.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    if (transaction.productImageUrl
                                        .trim()
                                        .isNotEmpty)
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: Colors.white,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.network(
                                          transaction.productImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.image_not_supported,
                                              ),
                                        ),
                                      ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        transaction.category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// Chips
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _modernChip(
                                Icons.sync_alt,
                                transaction.transactionType,
                              ),

                              _modernChip(
                                Icons.verified_outlined,
                                transaction.status,
                                backgroundColor: _statusColor(
                                  transaction.status,
                                ).withOpacity(.12),
                                textColor: _statusColor(transaction.status),
                                iconColor: _statusColor(transaction.status),
                              ),

                              _modernChip(
                                Icons.inventory_2_outlined,
                                'Qty ${transaction.quantity}',
                              ),

                              _modernChip(
                                Icons.scale_outlined,
                                '${transaction.weight.toStringAsFixed(3)} ${transaction.unit}',
                              ),

                              if (transaction.isGiftReceived)
                                _modernChip(Icons.card_giftcard, 'Gift'),
                            ],
                          ),

                          const SizedBox(height: 22),

                          _sectionTitle('Information'),

                          _modernDetailTile(
                            Icons.tag,
                            'Transaction ID',
                            '${transaction.id}',
                          ),
                          _modernDetailTile(
                            Icons.person_outline,
                            'User ID',
                            '${transaction.userId}',
                          ),
                          _modernDetailTile(
                            Icons.storefront_outlined,
                            'Seller ID',
                            '${transaction.sellerId ?? '-'}',
                          ),
                          _modernDetailTile(
                            Icons.attach_money,
                            'Unit Price',
                            transaction.unitPrice.toStringAsFixed(2),
                          ),
                          _modernDetailTile(
                            Icons.workspace_premium_outlined,
                            'Purity',
                            transaction.purity.toStringAsFixed(2),
                          ),

                          if (transaction.isTransferOrGift) ...[
                            _modernDetailTile(
                              Icons.call_received,
                              'Transfer From',
                              transaction.transferFromLabel,
                            ),
                            _modernDetailTile(
                              Icons.call_made,
                              'Transfer To',
                              transaction.transferToLabel,
                            ),
                          ],

                          const SizedBox(height: 20),

                          _sectionTitle('Timeline'),

                          _modernDetailTile(
                            Icons.calendar_today_outlined,
                            'Created',
                            createdText,
                          ),
                          _modernDetailTile(
                            Icons.update_outlined,
                            'Updated',
                            updatedText,
                          ),

                          const SizedBox(height: 20),

                          _sectionTitle('Notes'),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              transaction.notes.isEmpty
                                  ? 'No notes available'
                                  : transaction.notes,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ),

                          const SizedBox(height: 24),
                          if (transaction.status.toLowerCase() == 'pending') ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _cancelTransactionRequest(context, transaction);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                label: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelTransactionRequest(BuildContext context, TransactionModel transaction) async {
    final walletAssetId = transaction.walletItemId ?? transaction.walletAssetIdFromNotes;
    if (walletAssetId == null) return;

    await _walletActionRepository.cancelWalletRequest(walletAssetId: walletAssetId);

    if (context.mounted) {
      context.read<TransactionCubit>().loadTransactions(
            seller: context.read<TransactionCubit>().activeSeller,
          );
    }
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade900,
        ),
      ),
    );
  }

  /// MODERN DETAIL TILE
  Widget _modernDetailTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase().trim();

    if (value == 'approved' || value == 'completed' || value == 'success') {
      return Colors.green;
    } else if (value == 'pending' || value == 'in_progress' || value == 'processing') {
      return Colors.orange;
    } else if (value == 'declined' || value == 'rejected' || value == 'failed') {
      return Colors.red;
    }

    return Colors.grey;
  }

  /// CHIP
  Widget _modernChip(
    IconData icon,
    String label, {
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: textColor ?? Colors.black87,
            ),
          ),
        ],
      ),
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
