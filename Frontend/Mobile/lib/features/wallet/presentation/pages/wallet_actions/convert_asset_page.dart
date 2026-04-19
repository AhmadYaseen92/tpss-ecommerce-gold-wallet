import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/presentation/cubit/convert_asset_action_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/wallet_asset_summary_card.dart';

class ConvertAssetPage extends StatelessWidget {
  final WalletTransactionEntity asset;

  ConvertAssetPage({super.key, required this.asset});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConvertAssetActionCubit(asset: asset),
      child: BlocBuilder<ConvertAssetActionCubit, ConvertAssetActionState>(
        builder: (context, state) {
          final cubit = context.read<ConvertAssetActionCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('Convert Asset')),
            bottomNavigationBar: ActionBottomBar(
              summaryLabel: cubit.isCrypto ? 'Estimated Crypto' : 'Estimated Cash',
              summaryValue: cubit.isCrypto
                  ? '${cubit.cryptoReceived.toStringAsFixed(6)} ${cubit.cryptoType}'
                  : cubit.formatCurrency(cubit.cashReceived),
              buttonText: 'Review Conversion',
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActionReviewPage(summary: cubit.buildSummary()),
                  ),
                );
              },
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    WalletAssetSummaryCard(asset: asset),
                    ActionSectionCard(
                      title: 'Convert To',
                      child: SegmentedButton<ConvertTargetType>(
                        segments: const [
                          ButtonSegment(value: ConvertTargetType.cash, label: Text('Cash')),
                          ButtonSegment(
                            value: ConvertTargetType.crypto,
                            label: Text('Crypto'),
                          ),
                        ],
                        selected: {cubit.targetType},
                        onSelectionChanged: (values) {
                          cubit.updateTargetType(values.first);
                        },
                      ),
                    ),
                    ActionSectionCard(
                      title: 'Conversion Details',
                      child: Column(
                        children: [
                          ActionTextField(
                            label: 'Quantity (Max ${cubit.maxQuantity})',
                            hintText: 'Enter quantity',
                            controller: cubit.quantityController,
                            keyboardType: TextInputType.number,
                            validator: cubit.validateQuantity,
                          ),
                          const SizedBox(height: 12),
                          if (!cubit.isCrypto)
                            DropdownButtonFormField<String>(
                              value: cubit.cashDestination,
                              items: cubit.cashDestinations
                                  .map(
                                    (destination) => DropdownMenuItem(
                                      value: destination,
                                      child: Text(destination),
                                    ),
                                  )
                                  .toList(),
                              onChanged: cubit.updateCashDestination,
                              decoration: const InputDecoration(
                                labelText: 'Cash Destination',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          if (cubit.isCrypto) ...[
                            DropdownButtonFormField<String>(
                              value: cubit.cryptoType,
                              items: const [
                                DropdownMenuItem(value: 'USDT', child: Text('USDT')),
                                DropdownMenuItem(value: 'BTC', child: Text('BTC')),
                                DropdownMenuItem(value: 'ETH', child: Text('ETH')),
                              ],
                              onChanged: cubit.updateCryptoType,
                              decoration: const InputDecoration(
                                labelText: 'Crypto Type',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ActionTextField(
                              label: 'Wallet Address',
                              hintText: 'Enter crypto wallet address',
                              controller: cubit.walletAddressController,
                              validator: cubit.validateWalletAddress,
                            ),
                          ],
                        ],
                      ),
                    ),
                    FeeSummaryCard(
                      grossAmount: cubit.formatCurrency(cubit.grossAmount),
                      feeAmount: cubit.formatCurrency(cubit.serviceFee),
                      extraFeeLabel: cubit.isCrypto ? 'Network Fee' : null,
                      extraFeeAmount: cubit.isCrypto
                          ? cubit.formatCurrency(cubit.networkFee)
                          : null,
                      totalAmount: cubit.isCrypto
                          ? '${cubit.cryptoReceived.toStringAsFixed(6)} ${cubit.cryptoType}'
                          : cubit.formatCurrency(cubit.cashReceived),
                      totalLabel: cubit.isCrypto ? 'You Receive' : 'Cash Received',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
