import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_date_formats.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/otp_input_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
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
  String? _otpRequestId;
  bool _isSubmitting = false;
  bool _isLoadingOtp = false;
  SellExecutionMode _sellExecutionMode = SellExecutionMode.locked30Seconds;
  bool _requiresOtpForAction = true;

  bool get _isSellFlow => widget.summary.actionType == WalletActionType.sell;
  bool get _isExpired => _secondsLeft == 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await InjectionContainer.syncReleaseConfiguration();
    await _loadConfig();
    _requiresOtpForAction = AppReleaseConfig.isOtpRequiredForAction(_mapOtpAction(widget.summary.actionType));
    if (!_requiresOtpForAction) {
      if (mounted) setState(() {});
      return;
    }
    await _requestOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Confirmation',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const CircleAvatar(
                    radius: 34,
                    child: Icon(Icons.lock_clock_outlined, size: 34),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _requiresOtpForAction ? 'OTP Verification Required' : 'Confirmation Required',
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
                        ReadonlyInfoRow(
                          label: 'Subtotal',
                          value: ActionSummaryBuilder.formatMoney(
                            widget.summary.summary.subTotalAmount,
                            currency: widget.summary.summary.currency,
                          ),
                        ),
                        ...widget.summary.summary.feeBreakdowns.map(
                          (line) => ReadonlyInfoRow(
                            label: line.feeName,
                            value:
                                '${line.isDiscount ? '-' : ''}${ActionSummaryBuilder.formatMoney(line.appliedValue, currency: widget.summary.summary.currency)}',
                          ),
                        ),
                        if (!widget.summary.summary.feeBreakdowns.any((line) => line.isDiscount))
                          ReadonlyInfoRow(
                            label: 'Discount',
                            value:
                                '-${ActionSummaryBuilder.formatMoney(widget.summary.summary.discountAmount, currency: widget.summary.summary.currency)}',
                          ),
                        ReadonlyInfoRow(
                          label: 'Final Amount',
                          value: ActionSummaryBuilder.formatMoney(
                            widget.summary.summary.finalAmount,
                            currency: widget.summary.summary.currency,
                          ),
                        ),
                        ReadonlyInfoRow(label: widget.summary.destinationLabel, value: widget.summary.destinationValue),
                        if (widget.summary.note != null && widget.summary.note!.isNotEmpty)
                          ReadonlyInfoRow(label: 'Note', value: widget.summary.note!),
                        ReadonlyInfoRow(label: 'Reference', value: widget.summary.referenceNumber),
                        ReadonlyInfoRow(
                          label: 'Date',
                          value: AppDateFormats.readableDateTime.format(widget.summary.createdAt),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ActionSectionCard(
                    title: _requiresOtpForAction
                        ? (_isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds
                            ? 'Locked Quote & OTP'
                            : 'OTP Verification')
                        : 'Confirmation',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_requiresOtpForAction && _isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds) ...[
                          ReadonlyInfoRow(
                            label: 'Locked Price',
                            value: ActionSummaryBuilder.formatMoney(
                              widget.summary.summary.finalAmount,
                              currency: widget.summary.summary.currency,
                            ),
                          ),
                          ReadonlyInfoRow(label: 'Timer', value: _formatSeconds(_secondsLeft)),
                          const SizedBox(height: 8),
                          const Text('This price is locked for 30 seconds.'),
                          const SizedBox(height: 8),
                        ],
                        if (_requiresOtpForAction) ...[
                          const Text('This action will submit automatically after entering a valid OTP.'),
                          const SizedBox(height: 12),
                          OtpInputWidget(
                            value: _otp,
                            onChanged: (value) => setState(() => _otp = value),
                            onCompleted: (value) {
                              setState(() => _otp = value);
                              if (!_isSubmitting && !_isLoadingOtp) {
                                unawaited(_completeWithOtp());
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoadingOtp || _isSubmitting ? null : _requestOtp,
                              child: const Text('Resend OTP'),
                            ),
                          ),
                        ] else ...[
                          const Text('OTP is not required for this action by current admin policy.'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _completeWithoutOtp,
                              child: Text(_isSubmitting ? 'Submitting...' : 'Confirm Action'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSubmitting || _isLoadingOtp)
            const ColoredBox(
              color: Color(0x55000000),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
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
      if (!mounted) return;
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
      _showCommonError();
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
      final requestId = (data?['otpRequestId'] ?? '').toString().trim();
      if (requestId.isEmpty) {
        _showCommonError();
        return;
      }
      setState(() {
        _otpRequestId = requestId;
        _otp = '';
      });
      _showSnack('OTP sent successfully.');
    } catch (e) {
      _showErrorModal('OTP Failed', _extractDisplayErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoadingOtp = false);
    }
  }

  Future<void> _completeWithOtp() async {
    if (_isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds && _isExpired) {
      return;
    }
    if (_otp.length < 6) {
      return;
    }
    if ((_otpRequestId ?? '').isEmpty) {
      _showErrorModal('OTP Failed', 'OTP session expired. Please resend OTP and try again.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final userId = AuthSessionStore.userId;
      if (userId == null) {
        _showCommonError();
        return;
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
      final verificationToken = (verifyData['verificationToken'] ?? '').toString().trim();
      final actionReferenceId = (verifyData['actionReferenceId'] ?? '').toString().trim();
      if (verificationToken.isEmpty) {
        _showCommonError();
        return;
      }

      await _submitAction(
        verificationToken: verificationToken,
        actionReferenceId: actionReferenceId.isEmpty ? widget.summary.asset.id.toString() : actionReferenceId,
      );

      if (!mounted) return;
      await AppModalAlert.show(
        context,
        title: 'Success',
        message: '${widget.summary.title} submitted successfully.',
        variant: AppModalAlertVariant.success,
      );
      if (!mounted) return;
      Navigator.popUntil(
        context,
        (route) => route.settings.name == AppRoutes.walletItemsRoute || route.isFirst,
      );
    } catch (e) {
      _showErrorModal('Action Failed', _extractDisplayErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitAction({
    String? verificationToken,
    String? actionReferenceId,
  }) async {
    final requestedQuantity = int.tryParse(widget.summary.primaryValue.split(' ').first) ?? 1;
    final safeQuantity = requestedQuantity.clamp(1, widget.summary.asset.quantity).toInt();
    final perUnitWeight = widget.summary.asset.quantity == 0
        ? 0.0
        : widget.summary.asset.weightInGrams / widget.summary.asset.quantity;
    final requestedWeight = perUnitWeight * safeQuantity.toDouble();
    final unitPrice = widget.summary.asset.actionUnitPrice;
    final requestedAmount = unitPrice * safeQuantity;

    await _walletActionRepository.executeWalletAction(
      WalletActionExecutionRequest(
        walletAssetId: widget.summary.asset.id,
        actionType: widget.summary.actionType,
        quantity: safeQuantity,
        unitPrice: unitPrice,
        weight: requestedWeight,
        amount: requestedAmount,
        recipientInvestorUserId: widget.summary.recipientInvestorUserId,
        notes: widget.summary.note,
        otpVerificationToken: verificationToken,
        otpActionReferenceId: actionReferenceId,
      ),
    );

    _timer?.cancel();
  }

  Future<void> _completeWithoutOtp() async {
    if (_isSellFlow && _sellExecutionMode == SellExecutionMode.locked30Seconds && _isExpired) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _submitAction();
      if (!mounted) return;
      await AppModalAlert.show(
        context,
        title: 'Success',
        message: '${widget.summary.title} submitted successfully.',
        variant: AppModalAlertVariant.success,
      );
      if (!mounted) return;
      Navigator.popUntil(
        context,
        (route) => route.settings.name == AppRoutes.walletItemsRoute || route.isFirst,
      );
    } catch (e) {
      _showErrorModal('Action Failed', _extractDisplayErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _onQuoteExpired() {
    _showErrorModal('Quote Expired', 'Locked quote expired. Please retry with latest price.');
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
        WalletActionType.convertToCash => '',
        WalletActionType.convertToCrypto => '',
      };

  String _extractDisplayErrorMessage(Object error) {
    String pickMessageFromMap(Map<String, dynamic> map) {
      final nested = map['data'];
      if (nested is Map) {
        final nestedMap = nested.map((key, value) => MapEntry('$key', value));
        final nestedMessage = pickMessageFromMap(nestedMap);
        if (nestedMessage.isNotEmpty) return nestedMessage;
      }

      final errors = map['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first.toString().trim();
        if (first.isNotEmpty) return first;
      }
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first.toString().trim();
            if (first.isNotEmpty) return first;
          }
          final plain = value.toString().trim();
          if (plain.isNotEmpty) return plain;
        }
      }

      final directMessage = (map['message'] ?? map['error'] ?? map['title'] ?? '').toString().trim();
      if (directMessage.isNotEmpty) return directMessage;
      return '';
    }

    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map) {
        final mapData = responseData.map((key, value) => MapEntry('$key', value));
        final mappedMessage = pickMessageFromMap(mapData);
        if (mappedMessage.isNotEmpty) return mappedMessage;
      }

      if (responseData is String && responseData.trim().isNotEmpty) {
        return responseData.trim();
      }

      final fallbackErrorText = error.error?.toString().trim() ?? '';
      if (fallbackErrorText.isNotEmpty &&
          !fallbackErrorText.toLowerCase().contains('dioexception')) {
        return fallbackErrorText;
      }
    }

    return 'Something went wrong. Please try again.';
  }

  void _showCommonError() {
    _showErrorModal('Action Failed', 'Something went wrong. Please try again.');
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
