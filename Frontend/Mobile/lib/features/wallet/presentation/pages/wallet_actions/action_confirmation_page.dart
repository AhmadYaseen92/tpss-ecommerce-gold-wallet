import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/otp_input_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/readonly_info_row.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

class ActionConfirmationPage extends StatefulWidget {
  final WalletActionSummary summary;

  const ActionConfirmationPage({super.key, required this.summary});

  @override
  State<ActionConfirmationPage> createState() => _ActionConfirmationPageState();
}

class _ActionConfirmationPageState extends State<ActionConfirmationPage> {
  static const int _lockSeconds = 30;
  final IWalletActionRepository _walletActionRepository = InjectionContainer.walletActionRepository();

  int _secondsLeft = _lockSeconds;
  Timer? _timer;
  String _otp = '';
  bool _isCompleted = false;
  bool _isSubmitting = false;
  String? _backendReference;
  bool _resultPendingApproval = false;
  String? _invoiceUrl;
  SellExecutionMode _sellExecutionMode = SellExecutionMode.locked30Seconds;

  bool get _isSellFlow => widget.summary.actionType == WalletActionType.sell;
  bool get _isExpired => _secondsLeft == 0 && !_isCompleted;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isCompleted ? (_resultPendingApproval ? 'Submitted' : 'Completed') : 'Submitted';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : _isSellFlow
                        ? (_isExpired || _isCompleted ? null : _completeSellWithOtp)
                        : (_isCompleted ? null : _completeNonSellAction),
                child: Text(_isCompleted ? (_resultPendingApproval ? 'Submitted' : 'Completed') : 'Confirm & Complete'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.settings.name == AppRoutes.walletItemsRoute || route.isFirst,
                  );
                },
                child: const Text('Back to Wallet'),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 34,
                child: Icon(
                  _isCompleted ? Icons.check : Icons.lock_clock_outlined,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$statusText Successfully',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(widget.summary.title),
              const SizedBox(height: 20),

              ActionSectionCard(
                title: 'Transaction Summary',
                child: Column(
                  children: [
                    ReadonlyInfoRow(label: 'Asset', value: widget.summary.asset.name),
                    ReadonlyInfoRow(label: 'Action', value: widget.summary.title),
                    ReadonlyInfoRow(label: 'Amount', value: widget.summary.primaryValue),
                    ReadonlyInfoRow(label: 'Fee', value: widget.summary.feeValue),
                    ReadonlyInfoRow(label: 'Total', value: widget.summary.totalValue),
                    ReadonlyInfoRow(label: widget.summary.destinationLabel, value: widget.summary.destinationValue),
                    if (widget.summary.note != null && widget.summary.note!.isNotEmpty)
                      ReadonlyInfoRow(label: 'Note', value: widget.summary.note!),
                    ReadonlyInfoRow(label: 'Reference', value: _backendReference ?? widget.summary.referenceNumber),
                    ReadonlyInfoRow(label: 'Date', value: DateFormat('dd MMM yyyy, hh:mm a').format(widget.summary.createdAt)),
                  ],
                ),
              ),
              if (_isSellFlow && !_isCompleted && _sellExecutionMode == SellExecutionMode.locked30Seconds) ...[
                const SizedBox(height: 12),
                ActionSectionCard(
                  title: 'Locked Quote & OTP',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadonlyInfoRow(label: 'Locked Price', value: widget.summary.totalValue),
                      ReadonlyInfoRow(label: 'Timer', value: _formatSeconds(_secondsLeft)),
                      const SizedBox(height: 8),
                      const Text('This price is locked for 30 seconds. Enter OTP and tap Confirm & Complete.'),
                      const SizedBox(height: 12),
                      OtpInputWidget(
                        value: _otp,
                        onChanged: (value) => setState(() => _otp = value),
                        onCompleted: (value) => setState(() => _otp = value),
                      ),
                    ],
                  ),
                ),
              ],
              if (_isCompleted)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(_resultPendingApproval
                      ? 'Transaction submitted successfully and is pending seller approval.'
                      : 'Transaction completed successfully and wallet data will refresh automatically.'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadConfig() async {
    if (!_isSellFlow) return;
    try {
      _sellExecutionMode = await _walletActionRepository.getSellExecutionMode();
      if (_sellExecutionMode == SellExecutionMode.locked30Seconds) {
        _startLockTimer();
      }
      if (mounted) setState(() {});
    } catch (_) {
      _startLockTimer();
    }
  }

  void _startLockTimer() {
    _timer?.cancel();
    _secondsLeft = _lockSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isCompleted) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        setState(() => _secondsLeft = 0);
        timer.cancel();
        _onQuoteExpired();
      }
    });
  }

  String _formatSeconds(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _completeSellWithOtp() async {
    if (_isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds && _isExpired) return;
    if (_sellExecutionMode == SellExecutionMode.locked30Seconds && _otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 6-digit OTP before timer ends.')),
      );
      return;
    }

    await _submitAction();
  }

  Future<void> _completeNonSellAction() async {
    await _submitAction();
  }

  Future<void> _submitAction() async {
    setState(() => _isSubmitting = true);
    try {
      final requestedQuantity = int.tryParse(widget.summary.primaryValue.split(' ').first) ?? 1;
      final safeQuantity = requestedQuantity.clamp(1, widget.summary.asset.quantity).toInt();
      final perUnitWeight = widget.summary.asset.quantity == 0
          ? 0.0
          : widget.summary.asset.weightInGrams / widget.summary.asset.quantity;
      final requestedWeight = perUnitWeight * safeQuantity.toDouble();
      final unitPricePerGram = widget.summary.asset.marketPricePerGram;
      final requestedAmount = unitPricePerGram * requestedWeight;

      final result = await _walletActionRepository.executeWalletAction(
        WalletActionExecutionRequest(
          walletAssetId: widget.summary.asset.id,
          actionType: widget.summary.actionType,
          quantity: safeQuantity,
          unitPrice: unitPricePerGram,
          weight: requestedWeight,
          amount: requestedAmount,
          recipientInvestorUserId: widget.summary.recipientInvestorUserId,
          notes: widget.summary.note,
        ),
      );

      _timer?.cancel();
      setState(() {
        _isCompleted = true;
        _backendReference = result.referenceId;
        _resultPendingApproval = result.status.toLowerCase() == 'pending';
        _invoiceUrl = result.invoiceUrl;
      });

      if (!mounted) return;
      final isPending = result.status.toLowerCase() == 'pending';
      AppModalAlert.show(
        context,
        title: isPending ? 'Request Submitted' : 'Action Completed',
        message: isPending
            ? '${widget.summary.title} request submitted and pending seller approval.'
            : _invoiceUrl == null
            ? '${widget.summary.title} completed successfully.'
            : '${widget.summary.title} completed. Invoice: $_invoiceUrl',
        variant: AppModalAlertVariant.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppModalAlert.show(
        context,
        title: 'Action Failed',
        message: 'Failed: $e',
        variant: AppModalAlertVariant.failed,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onQuoteExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Locked quote expired. Sell was cancelled. Please retry with latest live price.')),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }
}
