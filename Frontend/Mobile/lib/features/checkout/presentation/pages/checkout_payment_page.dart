import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final Dio _dio = InjectionContainer.dio();
  double _subTotalAmount = 0;
  double _totalFeesAmount = 0;
  double _discountAmount = 0;
  double _finalAmount = 0;
  List<Map<String, dynamic>> _feeBreakdowns = const [];
  Map<String, dynamic> _checkoutArgs = const {};
  bool _didInitPreview = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitPreview) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _checkoutArgs = args;
    } else if (args is Map) {
      _checkoutArgs = args.map((key, value) => MapEntry('$key', value));
    } else {
      _checkoutArgs = const {};
    }

    _didInitPreview = true;
    _loadPreview();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return BlocProvider(
      create: (_) => CheckoutCubit(InjectionContainer.dio())..load(),
      child: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) async {
          if (state is CheckoutSuccess) {
            await AppModalAlert.show(
              context,
              message: 'Purchase completed and added to your wallet.',
              variant: AppModalAlertVariant.success,
            );
            if (!mounted) return;
            context.read<AppCubit>().notifyCheckoutCompleted();
            _navigateAfterSuccess();
          } else if (state is CheckoutError) {
            await AppModalAlert.show(
              context,
              message: state.message,
              variant: AppModalAlertVariant.failed,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CheckoutCubit>();
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Process Checkout',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ActionSectionCard(
                    title: 'Select Payment Method',
                    child: Column(
                      children: CheckoutPaymentType.values.map((type) {
                        return _PaymentTile(
                          title: _label(type),
                          subtitle: _subtitle(type),
                          icon: _icon(type),
                          selected: cubit.selectedPaymentType == type,
                          onTap: () => cubit.selectPaymentType(type),
                        );
                      }).toList(),
                    ),
                  ),
                  if (cubit.selectedPaymentType == CheckoutPaymentType.bank)
                    ActionSectionCard(
                      title: 'Select Linked Bank Account',
                      child: PredefinedAccountSelector(
                        label: 'Bank Account',
                        accounts: cubit.linkedBankAccounts,
                        selectedIndex: cubit.selectedBankIndex,
                        icon: Icons.account_balance_outlined,
                        onChanged: (index) {
                          if (index == null) return;
                          cubit.selectBankIndex(index);
                        },
                      ),
                    ),
                  if (cubit.selectedPaymentType == CheckoutPaymentType.card)
                    ActionSectionCard(
                      title: 'Select Predefined Payment Method',
                      child: PredefinedAccountSelector(
                        label: 'Payment Method',
                        accounts: cubit.predefinedPaymentMethods,
                        selectedIndex: cubit.selectedPaymentIndex,
                        icon: Icons.credit_card_outlined,
                        onChanged: (index) {
                          if (index == null) return;
                          cubit.selectPaymentIndex(index);
                        },
                      ),
                    ),
                  ActionSectionCard(
                    title: 'Order Details',
                    child: Column(
                      children: [
                        _row(context, 'Asset', (_checkoutArgs['title'] ?? 'Gold Asset').toString()),
                        if (AppReleaseConfig.showSellerUi)
                          _row(context, 'Seller', (_checkoutArgs['seller'] ?? AppReleaseConfig.defaultSeller).toString()),
                      ],
                    ),
                  ),
                  ActionSectionCard(
                    title: 'Review Summary',
                    child: Column(
                      children: [
                        _row(context, 'Payment', _label(cubit.selectedPaymentType)),
                        if (cubit.selectedPaymentType == CheckoutPaymentType.bank)
                          _row(context, 'Account', cubit.linkedBankAccounts[cubit.selectedBankIndex].name),
                        if (cubit.selectedPaymentType == CheckoutPaymentType.card)
                          _row(context, 'Method', cubit.predefinedPaymentMethods[cubit.selectedPaymentIndex].name),
                        _row(context, 'Subtotal', '\$${_subTotalAmount.toStringAsFixed(2)}'),
                        ..._feeBreakdowns.map((line) => _row(context, '${line['feeName']}', '${(line['isDiscount'] == true) ? '-' : ''}\$${((line['appliedValue'] as num?) ?? 0).toStringAsFixed(2)}')),
                        _row(context, 'Discount', '-\$${_discountAmount.toStringAsFixed(2)}'),
                        Divider(color: palette.border),
                        _row(context, 'Final Amount', '\$${_finalAmount.toStringAsFixed(2)}', bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  height: 52,
                          child: FilledButton.icon(
                    onPressed: state is CheckoutLoading
                        ? null
                        : () async {
                            final userId = AuthSessionStore.userId;
                            if (userId == null) {
                              await AppModalAlert.show(
                                context,
                                message: 'No logged-in user.',
                                variant: AppModalAlertVariant.failed,
                              );
                              return;
                            }

                            final otpResult = await Navigator.pushNamed(
                              context,
                              AppRoutes.confirmOtpRoute,
                              arguments: {
                                'title': 'Confirm Buy OTP',
                                'subtitle': 'Enter the OTP to confirm your checkout payment.',
                                'otpFlow': 'checkout',
                                'userId': userId,
                                'productId': _checkoutArgs['productId'],
                                'quantity': _checkoutArgs['quantity'],
                                'productIds': _checkoutArgs['productIds'],
                              },
                            );
                            if (otpResult is Map && otpResult['verified'] == true) {
                              await cubit.confirmOtp(
                                checkoutArgs: _checkoutArgs,
                                otpVerificationToken: '${otpResult['otpVerificationToken'] ?? ''}',
                                otpRequestId: '${otpResult['otpRequestId'] ?? ''}',
                              );
                            } else if (otpResult == true) {
                              await cubit.confirmOtp(checkoutArgs: _checkoutArgs);
                            }
                          },
                    icon: state is CheckoutLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.lock_open_outlined),
                    label: const Text('Confirm Checkout'),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateAfterSuccess() {
    final source = (_checkoutArgs['source'] ?? '').toString().toLowerCase();
    final navigator = Navigator.of(context, rootNavigator: true);
    if (source == 'cart') {
      navigator.pop(true);
      return;
    }

    if (source != 'product') {
      navigator.pop();
      return;
    }

    var foundProductRoute = false;
    navigator.popUntil((route) {
      final isProductRoute = route.settings.name == AppRoutes.productRoute;
      if (isProductRoute) {
        foundProductRoute = true;
      }
      return isProductRoute || route.isFirst;
    });
    if (!foundProductRoute) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.productRoute,
        (route) => false,
      );
    }
  }

  Future<void> _loadPreview() async {
    final args = _checkoutArgs;
    final summary = args['summary'];
    if (_applySummaryFromArgs(summary)) {
      return;
    }

    final userId = AuthSessionStore.userId;
    if (userId == null) return;

    final fromCart = (args['fromCart'] as bool?) ?? false;
    final productId = args['productId'];
    final quantity = args['quantity'];
    final productIds = (args['productIds'] as List<dynamic>? ?? [])
        .map((e) => e is num ? e.toInt() : int.tryParse('$e'))
        .whereType<int>()
        .toList();

    if (fromCart && productIds.isEmpty) return;
    if (!fromCart && (productId == null || quantity == null)) return;

    try {
      final response = await _dio.post(
        '/wallet/actions/preview',
        data: {
          'userId': userId,
          'actionType': 'buy',
          'fromCart': fromCart,
          if (fromCart) 'productIds': productIds,
          if (!fromCart) 'productId': productId,
          if (!fromCart) 'quantity': quantity,
        },
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _subTotalAmount = (data['subTotalAmount'] as num?)?.toDouble() ?? 0;
        _totalFeesAmount = (data['totalFeesAmount'] as num?)?.toDouble() ?? 0;
        _discountAmount = (data['discountAmount'] as num?)?.toDouble() ?? 0;
        _finalAmount = (data['finalAmount'] as num?)?.toDouble() ?? 0;
        _feeBreakdowns = (data['feeBreakdowns'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
      });
    } catch (_) {
      _applySummaryFromArgs(summary);
    }
  }

  bool _applySummaryFromArgs(dynamic summary) {
    if (summary == null) return false;

    try {
      if (summary is Map) {
        final map = summary.map((key, value) => MapEntry('$key', value));
        final feeLines = (map['feeBreakdowns'] as List<dynamic>? ?? [])
            .map((line) {
              if (line is Map) {
                return {
                  'feeName': (line['feeName'] ?? '').toString(),
                  'appliedValue': _toDouble(line['appliedValue']),
                  'isDiscount': line['isDiscount'] == true,
                };
              }
              return <String, dynamic>{
                'feeName': (line.feeName ?? '').toString(),
                'appliedValue': _toDouble(line.appliedValue),
                'isDiscount': line.isDiscount == true,
              };
            })
            .toList();

        if (!mounted) return false;
        setState(() {
          _subTotalAmount = _toDouble(map['subtotal'] ?? map['subTotalAmount']);
          _totalFeesAmount = _toDouble(map['totalFeesAmount']);
          _discountAmount = _toDouble(map['discountAmount']);
          _finalAmount = _toDouble(map['total'] ?? map['finalAmount']);
          _feeBreakdowns = feeLines;
        });
        return true;
      }

      if (!mounted) return false;
      setState(() {
        _subTotalAmount = _toDouble(summary.subtotal ?? summary.subTotalAmount);
        _totalFeesAmount = _toDouble(summary.totalFeesAmount);
        _discountAmount = _toDouble(summary.discountAmount);
        _finalAmount = _toDouble(summary.total ?? summary.finalAmount);
        _feeBreakdowns = (summary.feeBreakdowns as List<dynamic>? ?? [])
            .map((line) => {
                  'feeName': (line.feeName ?? '').toString(),
                  'appliedValue': _toDouble(line.appliedValue),
                  'isDiscount': line.isDiscount == true,
                })
            .toList();
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  IconData _icon(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return Icons.account_balance_outlined;
      case CheckoutPaymentType.card:
        return Icons.credit_card_outlined;
      case CheckoutPaymentType.cash:
        return Icons.wallet_outlined;
    }
  }

  String _label(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Bank Account';
      case CheckoutPaymentType.card:
        return 'Credit Card';
      case CheckoutPaymentType.cash:
        return 'Cash Balance';
    }
  }

  String _subtitle(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Pay from linked bank account';
      case CheckoutPaymentType.card:
        return 'Pay using predefined payment method';
      case CheckoutPaymentType.cash:
        return 'Use wallet cash balance';
    }
  }

  Widget _row(BuildContext context, String label, String value, {bool bold = false}) {
    final palette = context.appPalette;
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: palette.textPrimary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Expanded(child: Text(label, style: style)), Text(value, style: style)]),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? palette.surfaceMuted : palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? palette.primary : palette.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: palette.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: palette.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: palette.primary),
          ],
        ),
      ),
    );
  }
}
