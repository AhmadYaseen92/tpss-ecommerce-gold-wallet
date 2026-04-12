import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/presentation/cubit/checkout_cubit.dart';
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
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;
  final TextEditingController _discountCodeController = TextEditingController();
  String? _discountError;
  double _discountAmount = 0.0;

  Map<String, dynamic> get _checkoutArgs {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    if (args is Map) {
      return args.map((key, value) => MapEntry('$key', value));
    }
    return const {};
  }

  @override
  void dispose() {
    _discountCodeController.dispose();
    super.dispose();
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
              title: 'Checkout Successful',
              message: 'Purchase completed and added to your wallet.',
            );
            if (!mounted) return;
            _navigateAfterSuccess();
          } else if (state is CheckoutError) {
            await AppModalAlert.show(
              context,
              title: 'Checkout Failed',
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CheckoutCubit>();
          final amount = ((_checkoutArgs['amount'] as num?) ?? 1250).toDouble();
          final total = (amount - _discountAmount).clamp(0.0, double.infinity);
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(title: Text('Process Checkout', style: TextStyle(color: palette.textPrimary)), centerTitle: true),
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
                        accounts: PredefinedAccountsData.bankAccounts,
                        selectedIndex: selectedBankIndex,
                        icon: Icons.account_balance_outlined,
                        onChanged: (index) {
                          if (index == null) return;
                          setState(() => selectedBankIndex = index);
                        },
                      ),
                    ),
                  if (cubit.selectedPaymentType == CheckoutPaymentType.card)
                    ActionSectionCard(
                      title: 'Select Predefined Payment Method',
                      child: PredefinedAccountSelector(
                        label: 'Payment Method',
                        accounts: PredefinedAccountsData.paymentMethods,
                        selectedIndex: selectedPaymentIndex,
                        icon: Icons.credit_card_outlined,
                        onChanged: (index) {
                          if (index == null) return;
                          setState(() => selectedPaymentIndex = index);
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
                    title: 'Discount Code (Optional)',
                    child: Column(
                      children: [
                        TextField(
                          controller: _discountCodeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(hintText: 'Enter discount code', errorText: _discountError, border: const OutlineInputBorder()),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(onPressed: () => _applyDiscountCode(amount), child: const Text('Apply Code')),
                        ),
                      ],
                    ),
                  ),
                  ActionSectionCard(
                    title: 'Review Summary',
                    child: Column(
                      children: [
                        _row(context, 'Payment', _label(cubit.selectedPaymentType)),
                        if (cubit.selectedPaymentType == CheckoutPaymentType.bank) _row(context, 'Account', PredefinedAccountsData.bankAccounts[selectedBankIndex].name),
                        if (cubit.selectedPaymentType == CheckoutPaymentType.card) _row(context, 'Method', PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name),
                        _row(context, 'Amount', '\$${amount.toStringAsFixed(2)}'),
                        _row(context, 'Fee', '\$0.00'),
                        _row(context, 'Discount', '-\$${_discountAmount.toStringAsFixed(2)}'),
                        Divider(color: palette.border),
                        _row(context, 'Total', '\$${total.toStringAsFixed(2)}', bold: true),
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
                            final otpVerified = await Navigator.pushNamed(
                              context,
                              AppRoutes.confirmOtpRoute,
                              arguments: const {
                                'title': 'Confirm Buy OTP',
                                'subtitle': 'Enter the OTP to confirm your checkout payment.',
                              },
                            );
                            if (otpVerified == true) {
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
    if (source == 'cart') {
      Navigator.of(context, rootNavigator: true).pop(true);
      return;
    }

    if (source == 'product') {
      final navigator = Navigator.of(context, rootNavigator: true);
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
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    var foundListRoute = false;
    navigator.popUntil((route) {
      final isListRoute = route.settings.name == AppRoutes.homeRoute || route.settings.name == AppRoutes.productRoute;
      if (isListRoute) {
        foundListRoute = true;
      }
      return isListRoute || route.isFirst;
    });
    if (!foundListRoute) {
      navigator.pushNamedAndRemoveUntil(
        AppRoutes.homeRoute,
        (route) => false,
      );
    }
  }

  void _applyDiscountCode(double amount) {
    final raw = _discountCodeController.text.trim().toUpperCase();
    if (raw.isEmpty) {
      setState(() {
        _discountAmount = 0.0;
        _discountError = null;
      });
      return;
    }

    const discountMap = <String, double>{'SAVE10': 0.10, 'GOLD5': 0.05, 'VIP15': 0.15};
    final percent = discountMap[raw];
    if (percent == null) {
      setState(() {
        _discountAmount = 0.0;
        _discountError = 'Invalid discount code';
      });
      return;
    }

    setState(() {
      _discountError = null;
      _discountAmount = amount * percent;
    });
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
