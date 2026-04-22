import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/models/action_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_route_args.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';

class CheckoutPaymentPage extends StatefulWidget {
  const CheckoutPaymentPage({super.key});

  @override
  State<CheckoutPaymentPage> createState() => _CheckoutPaymentPageState();
}

class _CheckoutPaymentPageState extends State<CheckoutPaymentPage> {
  final Dio _dio = InjectionContainer.dio();
  ActionSummaryModel _summary = ActionSummaryModel.zero;
  CheckoutRouteArgs? _checkoutArgs;
  bool _didInitPreview = false;
  String? _routeArgsError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitPreview) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CheckoutRouteArgs) {
      _checkoutArgs = args;
      _routeArgsError = args.validate();
    } else {
      _routeArgsError = 'Invalid checkout arguments. Please retry from product details or cart.';
    }

    _didInitPreview = true;
    if (_routeArgsError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await AppModalAlert.show(
          context,
          message: _routeArgsError!,
          variant: AppModalAlertVariant.failed,
        );
        if (!mounted) return;
        Navigator.of(context).maybePop();
      });
      return;
    }
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
                        _row(context, 'Asset', (_checkoutArgs?.title ?? 'Gold Asset').toString()),
                        if (AppReleaseConfig.showSellerUi)
                          _row(context, 'Seller', (_checkoutArgs?.seller ?? AppReleaseConfig.defaultSeller).toString()),
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
                        _row(context, 'Subtotal', ActionSummaryBuilder.formatMoney(_summary.subTotalAmount, currency: _summary.currency)),
                        ..._summary.feeBreakdowns.map((line) => _row(context, line.feeName, '${line.isDiscount ? '-' : ''}${ActionSummaryBuilder.formatMoney(line.appliedValue, currency: _summary.currency)}')),
                        _row(context, 'Discount', '-${ActionSummaryBuilder.formatMoney(_summary.discountAmount, currency: _summary.currency)}'),
                        Divider(color: palette.border),
                        _row(context, 'Final Amount', ActionSummaryBuilder.formatMoney(_summary.finalAmount, currency: _summary.currency), bold: true),
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
                        || _checkoutArgs == null
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
                              arguments: (() {
                                final otpContext = _checkoutArgs?.toOtpContext(
                                  userId: userId,
                                );
                                return {
                                  'title': 'Confirm Buy OTP',
                                  'subtitle': 'Enter the OTP to confirm your checkout payment.',
                                  'otpFlow': 'checkout',
                                  'userId': userId,
                                  'productId': otpContext?.productId,
                                  'quantity': otpContext?.quantity,
                                  'productIds': otpContext?.productIds,
                                };
                              })(),
                            );
                            if (otpResult is Map && otpResult['verified'] == true) {
                              await cubit.confirmOtp(
                                checkoutArgs: _checkoutArgs!,
                                otpVerificationToken: '${otpResult['otpVerificationToken'] ?? ''}',
                                otpRequestId: '${otpResult['otpRequestId'] ?? ''}',
                              );
                            } else if (otpResult == true) {
                              await cubit.confirmOtp(checkoutArgs: _checkoutArgs!);
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
    final args = _checkoutArgs;
    if (args == null) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (args.source == CheckoutSource.cart) {
      navigator.pop(true);
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
    if (args == null) return;

    _applySummaryFromArgs(args.summary);

    final userId = AuthSessionStore.userId;
    if (userId == null) return;
    final validationError = args.validate();
    if (validationError != null) {
      await AppModalAlert.show(
        context,
        message: validationError,
        variant: AppModalAlertVariant.failed,
      );
      return;
    }

    final fromCart = args.source == CheckoutSource.cart;

    try {
      final response = await _dio.post(
        '/wallet/actions/preview',
        data: {
          'userId': userId,
          'actionType': 'buy',
          'fromCart': fromCart,
          if (fromCart) 'productIds': args.productIds,
          if (!fromCart) 'productId': args.productId,
          if (!fromCart) 'quantity': args.quantity,
        },
      );
      final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _summary = ActionSummaryBuilder.fromBackendData(data);
      });
    } catch (_) {
      // Keep the pre-applied args summary as a fallback only when preview fails.
    }
  }

  bool _applySummaryFromArgs(dynamic summary) {
    if (summary == null) return false;

    try {
      if (!mounted) return false;
      setState(() {
        _summary = ActionSummaryBuilder.fromAny(summary);
      });
      return true;
    } catch (_) {
      return false;
    }
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
