import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/convert_cubit/convert_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/terms_row.dart';
import 'package:tpss_ecommerce_gold_wallet/views/convert/widgets/convert_card_widget.dart';

class ConvertWidget extends StatelessWidget {
  final ConvertCubit convertCubit;
  const ConvertWidget({super.key, required this.convertCubit});

  static const List<String> currencies = ['USDT', 'USD'];

  @override
  Widget build(BuildContext context) {
    final fromAmount = convertCubit.amount;
    final toCurrency = convertCubit.toCurrency;
    final toAmount = convertCubit.subtotal;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // From / To row labels
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'From',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'To',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),

                  // From / To cards
                  Row(
                    children: [
                      // From card
                      Expanded(
                        child: CurrencyCard(
                          icon: convertCubit.currencyIcon(
                            convertCubit.fromCurrency,
                          ),
                          iconColor: convertCubit.fromCurrency == 'USDT'
                              ? AppColors.primaryColor
                              : AppColors.greyShade500,
                          selectedCurrency: convertCubit.fromCurrency,
                          currencies: currencies,
                          amountLabel: convertCubit.fromCurrency == 'USDT'
                              ? '${fromAmount.toStringAsFixed(fromAmount == fromAmount.truncateToDouble() ? 0 : 2)} USDT'
                              : '\$${fromAmount.toStringAsFixed(2)}',
                          onChanged: convertCubit.selectFromCurrency,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      // To card (read-only)
                      Expanded(
                        child: CurrencyCard(
                          icon: convertCubit.currencyIcon(toCurrency),
                          iconColor: toCurrency == 'USDT'
                              ? AppColors.primaryColor
                              : AppColors.greyShade500,
                          selectedCurrency: toCurrency,
                          currencies: null,
                          amountLabel: toCurrency == 'USDT'
                              ? '${toAmount.toStringAsFixed(toAmount == toAmount.truncateToDouble() ? 0 : 2)} USDT'
                              : '\$${toAmount.toStringAsFixed(2)}',
                          onChanged: null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Amount input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.greysShade2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          convertCubit.currencyIcon(convertCubit.fromCurrency),
                          color: convertCubit.fromCurrency == 'USDT'
                              ? AppColors.primaryColor
                              : AppColors.greyShade500,
                          size: 28.0,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 22.0,
                              ),
                              border: InputBorder.none,
                              suffixText: convertCubit.fromCurrency,
                              suffixStyle: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 16.0,
                              ),
                            ),
                            style: const TextStyle(fontSize: 22.0),
                            onChanged: convertCubit.updateAmount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Rate info card
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.greysShade2),
                    ),
                    child: _infoRow(
                      context,
                      label: 'Rate',
                      value:
                          '1 USDT = \$${ConvertCubit.usdtToUsdRate.toStringAsFixed(2)}',
                      valueColor: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Fee & Receive summary card
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          context,
                          label: 'Fee (1%)',
                          value: '-\$${convertCubit.fee.toStringAsFixed(2)}',
                          valueColor: AppColors.red,
                        ),
                        const Divider(height: 20.0),
                        _infoRow(
                          context,
                          label: 'Receive',
                          value: '\$${convertCubit.receive.toStringAsFixed(2)}',
                          isBold: true,
                          valueColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Terms checkbox
                   TermsRow(
                   value: convertCubit.agreedToTerms,
                   onChanged: convertCubit.toggleTerms,
                    connectorText: 'I agree to the ',
                    highlightedText: 'Terms & Conditions',
                    suffixText: ' for this conversion. Once confirmed, this action cannot be undone.',
                 ),
                ],
              ),
            ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: AppButton(label: 'Confirm Conversion', cubit: convertCubit),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.greyShade600,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.black,
          ),
        ),
      ],
    );
  }
}
