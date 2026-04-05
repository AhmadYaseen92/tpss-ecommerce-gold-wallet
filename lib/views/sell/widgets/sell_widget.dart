import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/asset_model.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/sell/presentation/cubit/sell_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/terms_row.dart';
import 'package:tpss_ecommerce_gold_wallet/views/sell/widgets/info_card_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/summary_row_widget.dart';

class SellWidget extends StatelessWidget {
  final SellCubit sellCubit;
  const SellWidget({super.key, required this.sellCubit});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Asset',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.greysShade2),
                    ),
                    child: DropdownButton<int>(
                      borderRadius: BorderRadius.circular(12.0),
                      dropdownColor: AppColors.white,
                      value: sellCubit.selectedAssetIndex,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: List.generate(
                        Asset.assets.length,
                        (i) => DropdownMenuItem(
                          
                          value: i,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.inventory_2,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                '${Asset.assets[i].name} - \$${Asset.assets[i].pricePerUnit.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) {
                          sellCubit.selectAsset(v);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    'How much to sell?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.monetization_on_outlined,
                              color: AppColors.primaryColor,
                              size: 28.0,
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: TextField(
                                controller: sellCubit.amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 22.0,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: 22.0),
                                onChanged: sellCubit.updateUnits,
                              ),
                            ),
                            Text(
                              'gram',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Available: ${sellCubit.selectedAsset.availableUnits.toStringAsFixed(0)} gram',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Expanded(
                        child: infoCard(
                          context,
                          label: 'Per gram',
                          value:
                              '\$${sellCubit.currentPricePerUnit.toStringAsFixed(2)}',
                          valueColor: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: infoCard(
                          context,
                          label: 'You Receive',
                          value: '\$${sellCubit.net.toStringAsFixed(2)}',
                          valueColor: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.greysShade2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'Price is fixed for ${sellCubit.priceLockSecondsRemaining}s. If you do not confirm, the price updates automatically.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.darkGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if ((sellCubit.statusMessage ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      sellCubit.statusMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.greysShade2),
                    ),
                    child: Column(
                      children: [
                        summaryRow(
                          context,
                          label: 'Amount',
                          value:
                              '${sellCubit.units.toStringAsFixed(1)} g x \$${sellCubit.currentPricePerUnit.toStringAsFixed(2)}',
                        ),
                        const Divider(height: 20.0),
                        summaryRow(
                          context,
                          label: 'Fee (2%)',
                          value: '-\$${sellCubit.fee.toStringAsFixed(2)}',
                        ),
                        const Divider(height: 20.0),
                        summaryRow(
                          context,
                          label: 'Net',
                          value: '\$${sellCubit.net.toStringAsFixed(2)}',
                          isBold: true,
                          valueColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: AppColors.greysShade2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Payout Bank Account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<int>(
                          value: sellCubit.selectedBankAccountIndex,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: List.generate(
                            sellCubit.predefinedBankAccounts.length,
                            (index) => DropdownMenuItem(
                              value: index,
                              child: Text(sellCubit.predefinedBankAccounts[index]),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              sellCubit.selectBankAccount(value);
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A new invoice will be generated from client to seller after confirmation.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const SizedBox(height: 20.0),
                  TermsRow(
                    value: sellCubit.agreedToTerms,
                    onChanged: sellCubit.toggleTerms,
                    connectorText: 'I agree to the ',
                    highlightedText: 'Terms & Conditions',
                    suffixText: ' for selling this asset. The transaction is final once confirmed.',
                  ),
                ],
              ),
            ),
          ), 
          Padding(
             padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: AppButton(
              cubit: sellCubit,
              label: 'Confirm Trade',
              onPressed: () async {
                final otpVerified = await Navigator.pushNamed(
                  context,
                  AppRoutes.confirmOtpRoute,
                  arguments: const {
                    'title': 'Confirm Sell OTP',
                    'subtitle': 'Enter the OTP to complete this sell action.',
                  },
                );
                if (otpVerified != true) return;

                final submitted = await sellCubit.submit();
                if (!context.mounted || !submitted) return;
                AppModalAlert.show(
                  context,
                  title: 'Sell Confirmed',
                  message: 'Sell confirmed. Tax invoice has been generated.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
