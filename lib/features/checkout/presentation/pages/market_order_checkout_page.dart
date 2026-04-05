import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/data/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/data/market_order_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/predefined_account_selector.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_text_field.dart';

class MarketOrderCheckoutPage extends StatefulWidget {
  const MarketOrderCheckoutPage({super.key});

  @override
  State<MarketOrderCheckoutPage> createState() =>
      _MarketOrderCheckoutPageState();
}

enum MarketExecutionType { instant, limit, stop }

class _MarketOrderCheckoutPageState extends State<MarketOrderCheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  MarketExecutionType executionType = MarketExecutionType.instant;
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );

  final TextEditingController triggerPriceController = TextEditingController();
  final TextEditingController tpController = TextEditingController();
  final TextEditingController slController = TextEditingController();
  CheckoutPaymentType paymentType = CheckoutPaymentType.bank;
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {};
  }

  double get _unitPrice => (_args['amount'] as num?)?.toDouble() ?? 0;
  int get _quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    return parsed < 1 ? 1 : parsed;
  }

  double get _total => _unitPrice * _quantity;

  @override
  void dispose() {
    quantityController.dispose();
    triggerPriceController.dispose();
    tpController.dispose();
    slController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final symbol = (_args['title'] ?? 'XAUUSD').toString();
    final seller = (_args['seller'] ?? AppReleaseConfig.defaultSeller)
        .toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Market Order Checkout',
          style: TextStyle(color: palette.textPrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.marketOrderListRoute),
            child: const Text('Orders'),
          ),
        ],
      ),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: 'Estimated Total',
        summaryValue: '\$${_total.toStringAsFixed(2)}',
        buttonText: 'Place Order',
        onPressed: () async {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          final reopenOrderId = _args['reopenOrderId'] as String?;
          final order = reopenOrderId == null
              ? MarketOrderRepository.placeOrder(
                  symbol: symbol,
                  seller: seller,
                  quantity: _quantity,
                  unitPrice: _unitPrice,
                  paymentMethod: _paymentLabel(paymentType),
                  paymentAccount: _selectedAccountLabel(),
                )
              : MarketOrderRepository.reopenOrderAsPending(
                  orderId: reopenOrderId,
                  liveUnitPrice: _unitPrice,
                  quantity: _quantity,
                  paymentMethod: _paymentLabel(paymentType),
                  paymentAccount: _selectedAccountLabel(),
                );

          if (order == null) return;

          await AppModalAlert.show(
            context,
            title: 'Order Submitted',
            message:
                'Order ${order.id} is pending now. It will be completed or rejected after settlement.',
          );
          if (!context.mounted) return;
          Navigator.pop(context, true);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ActionSectionCard(
                title: 'Order Details',
                child: Column(
                  children: [
                    _readonlyRow(context, 'Symbol/Unit', symbol),
                    if (AppReleaseConfig.showSellerUi)
                      _readonlyRow(context, 'Seller', seller),
                    _readonlyRow(
                      context,
                      'Live Price',
                      '\$${_unitPrice.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              ActionSectionCard(
                title: 'Order Type & Quantity',
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Execution Type',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: MarketExecutionType.values.map((type) {
                        final selected = type == executionType;
                        return ChoiceChip(
                          label: Text(_label(type)),
                          selected: selected,
                          selectedColor: palette.primary.withAlpha(25),
                          backgroundColor: palette.surface,
                          labelStyle: TextStyle(
                            color: selected
                                ? palette.primary
                                : palette.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: selected ? palette.primary : palette.border,
                          ),
                          onSelected: (_) =>
                              setState(() => executionType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ActionTextField(
                            label: 'Quantity',
                            hintText: 'Enter quantity',
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final parsed = int.tryParse((value ?? '').trim());
                              if (parsed == null || parsed < 1)
                                return 'Quantity must be at least 1';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _quantity > 1
                              ? () {
                                  quantityController.text = (_quantity - 1)
                                      .toString();
                                  setState(() {});
                                }
                              : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: palette.textSecondary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            quantityController.text = (_quantity + 1)
                                .toString();
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ActionSectionCard(
                title: 'Payment Method',
                child: Column(
                  children:
                      const [
                        CheckoutPaymentType.bank,
                        CheckoutPaymentType.card,
                      ].map((type) {
                        final selected = paymentType == type;
                        return RadioListTile<CheckoutPaymentType>(
                          value: type,
                          groupValue: paymentType,
                          contentPadding: EdgeInsets.zero,
                          title: Text(_paymentLabel(type)),
                          subtitle: Text(
                            selected
                                ? 'Available: \$${MarketOrderRepository.getAccountBalance(_accountNameByType(type)).toStringAsFixed(2)}'
                                : _paymentSubtitle(type),
                          ),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => paymentType = value);
                          },
                        );
                      }).toList(),
                ),
              ),
              if (paymentType == CheckoutPaymentType.bank)
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
              if (paymentType == CheckoutPaymentType.card)
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
                title: 'Risk Management',
                child: Column(
                  children: [
                    if (executionType != MarketExecutionType.instant) ...[
                      ActionTextField(
                        label: executionType == MarketExecutionType.limit
                            ? 'Limit Price'
                            : 'Stop Price',
                        hintText: 'Enter trigger price',
                        controller: triggerPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (executionType == MarketExecutionType.instant)
                            return null;
                          if (value == null || value.trim().isEmpty)
                            return 'Required for ${_label(executionType)} orders';
                          if (double.tryParse(value) == null)
                            return 'Enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    ActionTextField(
                      label: 'Take Profit',
                      hintText: 'Optional',
                      controller: tpController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                    const SizedBox(height: 12),
                    ActionTextField(
                      label: 'Stop Loss',
                      hintText: 'Optional',
                      controller: slController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: _optionalNumberValidator,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _optionalNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) return 'Enter a valid number';
    return null;
  }

  Widget _readonlyRow(BuildContext context, String label, String value) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: palette.textPrimary)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _label(MarketExecutionType type) {
    switch (type) {
      case MarketExecutionType.instant:
        return 'Instant';
      case MarketExecutionType.limit:
        return 'Limit';
      case MarketExecutionType.stop:
        return 'Stop';
    }
  }

  String _paymentLabel(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Bank Account';
      case CheckoutPaymentType.card:
        return 'Card';
      case CheckoutPaymentType.cash:
        return 'Cash Balance';
    }
  }

  String _paymentSubtitle(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Deduct directly from linked bank account';
      case CheckoutPaymentType.card:
        return 'Deduct directly from saved card';
      case CheckoutPaymentType.cash:
        return 'Disabled for Spot MR market orders';
    }
  }

  String _accountNameByType(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return PredefinedAccountsData.bankAccounts[selectedBankIndex].name;
      case CheckoutPaymentType.card:
        return PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name;
      case CheckoutPaymentType.cash:
        return '';
    }
  }

  String _selectedAccountLabel() {
    switch (paymentType) {
      case CheckoutPaymentType.bank:
        return PredefinedAccountsData.bankAccounts[selectedBankIndex].name;
      case CheckoutPaymentType.card:
        return PredefinedAccountsData.paymentMethods[selectedPaymentIndex].name;
      case CheckoutPaymentType.cash:
        return 'Wallet Cash Balance';
    }
  }
}
