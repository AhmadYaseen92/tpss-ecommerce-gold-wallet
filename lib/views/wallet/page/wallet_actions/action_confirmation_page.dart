import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/views/forgot_password/widgets/otp_input_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/readonly_info_row.dart';

class ActionConfirmationPage extends StatefulWidget {
  final WalletActionSummary summary;

  const ActionConfirmationPage({super.key, required this.summary});

  @override
  State<ActionConfirmationPage> createState() => _ActionConfirmationPageState();
}

class _ActionConfirmationPageState extends State<ActionConfirmationPage> {
  static const int _lockSeconds = 30;
  int _secondsLeft = _lockSeconds;
  Timer? _timer;
  String _otp = '';
  bool _isCompleted = false;

  bool get _isSellFlow => widget.summary.actionType == WalletActionType.sell;
  bool get _isExpired => _secondsLeft == 0 && !_isCompleted;

  @override
  void initState() {
    super.initState();
    if (_isSellFlow) {
      _startLockTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _isCompleted ? 'Completed' : 'Submitted';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(_isCompleted ? 'Done' : 'Back to Wallet'),
          ),
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

              if (_isSellFlow && !_isCompleted) ...[
                ActionSectionCard(
                  title: 'Sell Quote Lock',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadonlyInfoRow(label: 'Locked Price', value: widget.summary.totalValue),
                      ReadonlyInfoRow(label: 'Timer', value: _formatSeconds(_secondsLeft)),
                      const SizedBox(height: 8),
                      const Text(
                        'This price is locked for 30 seconds. Complete OTP to finish the sale. If the timer expires, the quote will be cancelled and you can retry with the latest market price.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OtpInputWidget(
                  value: _otp,
                  onChanged: (value) => setState(() => _otp = value),
                  onCompleted: (value) => setState(() => _otp = value),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _isExpired ? null : _completeSellWithOtp,
                  child: const Text('Verify OTP & Complete Sell'),
                ),
                const SizedBox(height: 6),
              ],

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
                    ReadonlyInfoRow(label: 'Reference', value: widget.summary.referenceNumber),
                    ReadonlyInfoRow(label: 'Date', value: DateFormat('dd MMM yyyy, hh:mm a').format(widget.summary.createdAt)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _completeSellWithOtp() {
    if (_isExpired) return;
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 6-digit OTP before timer ends.')),
      );
      return;
    }
    _timer?.cancel();
    setState(() => _isCompleted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sell request completed at locked price.')),
    );
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
