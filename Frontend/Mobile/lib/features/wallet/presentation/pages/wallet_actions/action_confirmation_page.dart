import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/otp_input_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/readonly_info_row.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
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
  final Dio _dio = InjectionContainer.dio();

  int _secondsLeft = _lockSeconds;
  Timer? _timer;
  String _otp = '';
  bool _isCompleted = false;
  bool _isSubmitting = false;
  bool _isLoadingOtp = false;
  String? _backendReference;
  bool _resultPendingApproval = false;
  String? _invoiceUrl;
  String? _otpRequestId;
  SellExecutionMode _sellExecutionMode = SellExecutionMode.locked30Seconds;

  bool get _isSellFlow => widget.summary.actionType == WalletActionType.sell;
  bool get _isExpired => _secondsLeft == 0 && !_isCompleted;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadConfig();
    await _requestOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusTitle = _isCompleted ? (_resultPendingApproval ? 'Submitted Successfully' : 'Completed Successfully') : 'OTP Verification Required';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Confirmation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting || _isLoadingOtp || _isCompleted ? null : _completeWithOtp,
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
                statusTitle,
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
              if (!_isCompleted) ...[
                const SizedBox(height: 12),
                ActionSectionCard(
                  title: _isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds ? 'Locked Quote & OTP' : 'OTP Verification',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds) ...[
                        ReadonlyInfoRow(label: 'Locked Price', value: widget.summary.totalValue),
                        ReadonlyInfoRow(label: 'Timer', value: _formatSeconds(_secondsLeft)),
                        const SizedBox(height: 8),
                        const Text('This price is locked for 30 seconds. Enter OTP and tap Confirm & Complete.'),
                        const SizedBox(height: 12),
                      ],
                      OtpInputWidget(
                        value: _otp,
                        onChanged: (value) => setState(() => _otp = value),
                        onCompleted: (value) => setState(() => _otp = value),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoadingOtp || _isSubmitting ? null : _requestOtp,
                          child: const Text('Resend OTP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Future<void> _requestOtp() async {
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      _showSnack('No logged-in user. Please login first.');
      return;
    }

    setState(() => _isLoadingOtp = true);
    try {
      final actionRef = widget.summary.asset.id.toString();
      final response = _otpRequestId == null
          ? await _dio.post(
              '/otp/request',
              data: {
                'userId': userId,
                'actionType': _mapOtpAction(widget.summary.actionType),
                'actionReferenceId': actionRef,
              },
            )
          : await _dio.post(
              '/otp/resend',
              data: {
                'userId': userId,
                'otpRequestId': _otpRequestId,
              },
            );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      final requestId = (data?['otpRequestId'] ?? '').toString();
      if (requestId.isNotEmpty) {
        setState(() {
          _otpRequestId = requestId;
          _otp = '';
        });
        _showSnack('OTP sent successfully');
      }
    } catch (e) {
      _showErrorModal('OTP Failed', _extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoadingOtp = false);
    }
  }

  Future<void> _completeWithOtp() async {
    if (_isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds && _isExpired) return;
    if (_otp.length < 6) {
      _showSnack('Enter the full 6-digit OTP.');
      return;
    }
    if ((_otpRequestId ?? '').isEmpty) {
      _showSnack('OTP session not found. Please resend OTP.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final userId = AuthSessionStore.userId;
      if (userId == null) {
        throw Exception('No logged-in user. Please login first.');
      }

      final verifyResp = await _dio.post(
        '/otp/verify',
        data: {
          'userId': userId,
          'otpRequestId': _otpRequestId,
          'otpCode': _otp,
        },
      );
      final verifyData = (verifyResp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final verificationToken = (verifyData['verificationToken'] ?? '').toString();
      final actionReferenceId = (verifyData['actionReferenceId'] ?? '').toString();
      if (verificationToken.isEmpty) {
        throw Exception('OTP verified but no verification token was returned.');
      }

      await _submitAction(verificationToken: verificationToken, actionReferenceId: actionReferenceId);
    } catch (e) {
      _showErrorModal('Action Failed', _extractErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitAction({
    required String verificationToken,
    required String actionReferenceId,
  }) async {
    final requestedQuantity = int.tryParse(widget.summary.primaryValue.split(' ').first) ?? 1;
    final safeQuantity = requestedQuantity.clamp(1, widget.summary.asset.quantity).toInt();
    final perUnitWeight = widget.summary.asset.quantity == 0 ? 0.0 : widget.summary.asset.weightInGrams / widget.summary.asset.quantity;
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
        otpVerificationToken: verificationToken,
        otpActionReferenceId: actionReferenceId.isEmpty ? widget.summary.asset.id.toString() : actionReferenceId,
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
    await AppModalAlert.show(
      context,
      title: isPending ? 'Request Submitted' : 'Action Completed',
      message: isPending
          ? '${widget.summary.title} submitted and pending seller approval.'
          : _invoiceUrl == null
              ? '${widget.summary.title} completed successfully.'
              : '${widget.summary.title} completed. Invoice: $_invoiceUrl',
      variant: AppModalAlertVariant.success,
    );
  }

  void _onQuoteExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Locked quote expired. Sell was cancelled. Please retry with latest live price.')),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.popUntil(
        context,
        (route) => route.settings.name == AppRoutes.walletItemsRoute || route.isFirst,
      );
    });
  }

  String _mapOtpAction(WalletActionType type) => switch (type) {
        WalletActionType.sell => 'sell',
        WalletActionType.transfer => 'transfer',
        WalletActionType.gift => 'gift',
        WalletActionType.pickup => 'pickup',
        _ => 'sell',
      };

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = (data['message'] ?? data['errors'] ?? '').toString().trim();
        if (message.isNotEmpty) return message;
      }
      return error.message ?? 'Server error occurred.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _showErrorModal(String title, String message) {
    if (!mounted) return;
    unawaited(
      AppModalAlert.show(
        context,
        title: title,
        message: message,
        variant: AppModalAlertVariant.failed,
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
