import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';

class PickupRequestPage extends StatefulWidget {
  final WalletTransactionEntity asset;
  const PickupRequestPage({super.key, required this.asset});

  @override
  State<PickupRequestPage> createState() => _PickupRequestPageState();
}

class _PickupRequestPageState extends State<PickupRequestPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final IWalletActionRepository _walletActionRepository = InjectionContainer.walletActionRepository();
  bool _isSubmitting = false;

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
        title: const Text('Pickup Request'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ActionSectionCard(
            title: 'Fees Summary',
            child: Column(
              children: const [
                _FeeRow('Delivery', '\$20.00'),
                _FeeRow('Storage', '\$10.00'),
                _FeeRow('Service Charge', '\$5.00'),
                _FeeRow('Premium/Discount', '-\$2.50'),
                Divider(height: 20),
                _FeeRow('Total Fees', '\$32.50', bold: true),
              ],
            ),
          ),
          ActionSectionCard(
            title: 'Amount Summary',
            child: Column(
              children: [
                _FeeRow('Amount', widget.asset.marketValue),
                const _FeeRow('Fees', '\$32.50'),
                const _FeeRow('Total Amount', '\$1,232.50', bold: true),
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
            onPressed: _isSubmitting ? null : () {
              if (selectedDate == null || selectedTime == null) {
                AppModalAlert.show(
                  context,
                  title: 'Missing Details',
                  message: 'Please select pickup date and time.',
                );
                return;
              }

              _submitPickupRequest(dateText, timeText);
            },
            child: _isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Confirm Pickup'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPickupRequest(String dateText, String timeText) async {
    setState(() => _isSubmitting = true);
    try {
      final quantity = widget.asset.quantity > 0 ? 1 : 0;
      final perUnitWeight = widget.asset.quantity == 0 ? 0.0 : widget.asset.weightInGrams / widget.asset.quantity;
      final unitPrice = widget.asset.marketPricePerGram;

      await _walletActionRepository.executeWalletAction(
        WalletActionExecutionRequest(
          walletAssetId: widget.asset.id,
          actionType: WalletActionType.pickup,
          quantity: quantity <= 0 ? 1 : quantity,
          unitPrice: unitPrice,
          weight: perUnitWeight <= 0 ? widget.asset.weightInGrams : perUnitWeight,
          amount: unitPrice * (perUnitWeight <= 0 ? widget.asset.weightInGrams : perUnitWeight),
          notes: 'pickup_schedule=$dateText $timeText',
        ),
      );

      if (!mounted) return;
      await AppModalAlert.show(
        context,
        title: 'Pickup Submitted',
        message: 'Pickup request submitted successfully.',
        variant: AppModalAlertVariant.success,
      );
      if (!mounted) return;
      Navigator.popUntil(
        context,
        (route) => route.settings.name == AppRoutes.walletItemsRoute || route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      await AppModalAlert.show(
        context,
        title: 'Pickup Failed',
        message: 'Failed: $e',
        variant: AppModalAlertVariant.failed,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
