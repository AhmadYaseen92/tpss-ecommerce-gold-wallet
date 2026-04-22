import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';

class PickupRequestPage extends StatefulWidget {
  final WalletTransactionEntity asset;
  const PickupRequestPage({super.key, required this.asset});

  @override
  State<PickupRequestPage> createState() => _PickupRequestPageState();
}

class _PickupRequestPageState extends State<PickupRequestPage> {
  final Dio _dio = InjectionContainer.dio();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  WalletActionPreviewResult? _preview;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final quantity = 1;
      final unitPrice = widget.asset.marketPricePerGram;
      final amount = unitPrice * widget.asset.weightInGrams;
      final response = await _dio.post(
        '/wallet/actions/preview',
        data: {
          'userId': AuthSessionStore.userId,
          'walletAssetId': widget.asset.id,
          'actionType': 'pickup',
          'quantity': quantity,
          'unitPrice': unitPrice,
          'weight': widget.asset.weightInGrams,
          'amount': amount,
        },
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final feeBreakdowns = (data['feeBreakdowns'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((line) => WalletActionPreviewFeeLine(
                feeName: (line['feeName'] ?? '').toString(),
                appliedValue: (line['appliedValue'] as num?)?.toDouble() ?? 0,
                isDiscount: (line['isDiscount'] as bool?) ?? false,
              ))
          .toList();

      if (!mounted) return;
      setState(() {
        _preview = WalletActionPreviewResult(
          subTotalAmount: (data['subTotalAmount'] as num?)?.toDouble() ?? 0,
          totalFeesAmount: (data['totalFeesAmount'] as num?)?.toDouble() ?? 0,
          discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0,
          finalAmount: (data['finalAmount'] as num?)?.toDouble() ?? 0,
          currency: (data['currency'] ?? 'USD').toString(),
          feeBreakdowns: feeBreakdowns,
        );
      });
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (result != null) {
      setState(() => selectedTime = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null ? 'Select date' : DateFormat('EEE, dd MMM yyyy').format(selectedDate!);
    final timeText = selectedTime == null ? 'Select time' : selectedTime!.format(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Pickup Request',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.appPalette.primary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ActionSectionCard(
            title: 'Fees Summary',
            child: Column(
              children: [
                ...?_preview?.feeBreakdowns.map((line) => _FeeRow(line.feeName, '${line.isDiscount ? '-' : ''}\$${line.appliedValue.toStringAsFixed(2)}')),
                const Divider(height: 20),
                _FeeRow('Total Fees', '\$${((_preview?.totalFeesAmount ?? 0) - (_preview?.discountAmount ?? 0)).toStringAsFixed(2)}', bold: true),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Amount Summary',
            child: Column(
              children: [
                _FeeRow('Subtotal', '\$${(_preview?.subTotalAmount ?? 0).toStringAsFixed(2)}'),
                _FeeRow('Discount', '-\$${(_preview?.discountAmount ?? 0).toStringAsFixed(2)}'),
                _FeeRow('Final Amount', '\$${(_preview?.finalAmount ?? 0).toStringAsFixed(2)}', bold: true),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Pickup Schedule',
            child: Column(
              children: [
                _PickerTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Pickup Date',
                  value: dateText,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 10),
                _PickerTile(
                  icon: Icons.access_time_outlined,
                  title: 'Pickup Time',
                  value: timeText,
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              if (selectedDate == null || selectedTime == null) {
                AppModalAlert.show(
                  context,
                  title: 'Missing Details',
                  message: 'Please select pickup date and time.',
                );
                return;
              }

              _goToReview(dateText, timeText);
            },
            child: const Text('Review Pickup'),
          ),
        ],
      ),
    );
  }

  void _goToReview(String dateText, String timeText) {
    final schedule = '$dateText $timeText';
    final summary = WalletActionSummary(
      asset: widget.asset,
      actionType: WalletActionType.pickup,
      title: 'Pickup Asset',
      primaryValue: '1 Units',
      feeValue: '\$${(((_preview?.totalFeesAmount ?? 0) - (_preview?.discountAmount ?? 0))).toStringAsFixed(2)}',
      totalValue: '\$${(_preview?.finalAmount ?? 0).toStringAsFixed(2)}',
      preview: _preview,
      destinationLabel: 'Pickup Schedule',
      destinationValue: schedule,
      note: 'pickup_schedule=$schedule',
      referenceNumber: '',
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ActionReviewPage(summary: summary)),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({required this.icon, required this.title, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greysShade2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(value, style: const TextStyle(color: AppColors.greyShade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _FeeRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [Expanded(child: Text(label, style: style)), Text(value, style: style)],
      ),
    );
  }
}
