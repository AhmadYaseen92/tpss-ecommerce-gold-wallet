import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_date_formats.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transaction/data/models/transaction_model.dart';

class TransactionDetailsBottomSheet {
  static Future<void> show(BuildContext context, TransactionModel transaction) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final palette = ctx.appPalette;
        final updatedText = AppDateFormats.transactionDateTime.format(transaction.displayDate.toLocal());
        final createdText = AppDateFormats.transactionDateTime.format(transaction.createdAtUtc.toLocal());

        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: palette.border,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Transaction Details',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: palette.textPrimary),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(ctx),
                                icon: Icon(Icons.close_rounded, color: palette.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
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
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(transaction.transactionType.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
                                const SizedBox(height: 10),
                                Text('${transaction.amount.toStringAsFixed(2)} ${transaction.currency}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    if (transaction.productImageUrl.trim().isNotEmpty)
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.network(
                                          transaction.productImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(transaction.category, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _modernChip(ctx, Icons.sync_alt, transaction.transactionType),
                              _modernChip(
                                ctx,
                                Icons.verified_outlined,
                                transaction.status,
                                backgroundColor: _statusColor(transaction.status).withOpacity(.12),
                                textColor: _statusColor(transaction.status),
                                iconColor: _statusColor(transaction.status),
                              ),
                              _modernChip(ctx, Icons.inventory_2_outlined, 'Qty ${transaction.quantity}'),
                              _modernChip(ctx, Icons.scale_outlined, '${transaction.weight.toStringAsFixed(3)} ${transaction.unit}'),
                              if (transaction.isGiftReceived) _modernChip(ctx, Icons.card_giftcard, 'Gift'),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle(ctx, 'Information'),
                          _modernDetailTile(ctx, Icons.tag, 'Transaction ID', '${transaction.id}'),
                          _modernDetailTile(ctx, Icons.person_outline, 'User ID', '${transaction.userId}'),
                          _modernDetailTile(ctx, Icons.storefront_outlined, 'Seller ID', '${transaction.sellerId ?? '-'}'),
                          _modernDetailTile(ctx, Icons.attach_money, 'Unit Price', transaction.unitPrice.toStringAsFixed(2)),
                          _modernDetailTile(ctx, Icons.workspace_premium_outlined, 'Purity', transaction.purity.toStringAsFixed(2)),
                          if (transaction.isTransferOrGift) ...[
                            _modernDetailTile(ctx, Icons.call_received, 'Transfer From', transaction.transferFromLabel),
                            _modernDetailTile(ctx, Icons.call_made, 'Transfer To', transaction.transferToLabel),
                          ],
                          const SizedBox(height: 20),
                          _sectionTitle(ctx, 'Timeline'),
                          _modernDetailTile(ctx, Icons.calendar_today_outlined, 'Created', createdText),
                          _modernDetailTile(ctx, Icons.update_outlined, 'Updated', updatedText),
                          const SizedBox(height: 20),
                          _sectionTitle(ctx, 'Notes'),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: palette.surfaceMuted, borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              transaction.notes.isEmpty ? 'No notes available' : transaction.notes,
                              style: TextStyle(fontSize: 14, height: 1.4, color: palette.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Back', style: TextStyle(fontWeight: FontWeight.w700, color: palette.primary)),
                            ),
                          ),
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

  static Widget _sectionTitle(BuildContext context, String title) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: palette.textPrimary)),
    );
  }

  static Widget _modernDetailTile(BuildContext context, IconData icon, String title, String value) {
    final palette = context.appPalette;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.textPrimary.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: palette.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                const SizedBox(height: 3),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    final value = status.toLowerCase().trim();
    if (value == 'approved' || value == 'completed' || value == 'success') return Colors.green;
    if (value == 'pending' || value == 'in_progress' || value == 'processing') return Colors.orange;
    if (value == 'declined' || value == 'rejected' || value == 'failed') return Colors.red;
    return Colors.grey;
  }

  static Widget _modernChip(
    BuildContext context,
    IconData icon,
    String label, {
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? palette.textPrimary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor ?? palette.textPrimary)),
        ],
      ),
    );
  }
}
