import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/wallet_action_cubit/sell_asset_action_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class SellAssetPage extends StatelessWidget {
  final WalletActionSummary asset;

  SellAssetPage({super.key, required this.asset});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SellAssetActionCubit(initialAsset: asset),
      child: BlocBuilder<SellAssetActionCubit, SellAssetActionState>(
        builder: (context, state) {
          final cubit = context.read<SellAssetActionCubit>();

          return Scaffold(
            appBar: AppBar(title: const Text('Sell Asset')),
            bottomNavigationBar: ActionBottomBar(
              summaryLabel: 'Estimated Receive',
              summaryValue: cubit.formatCurrency(cubit.receivedAmount),
              buttonText: 'Review Sell',
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ActionReviewPage(summary: cubit.buildSummary()),
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
                    WalletAssetSummaryCard(asset: asset.asset),
                    ActionSectionCard(
                      title: 'Sell Details',
                      child: Column(
                        children: [
                          ActionTextField(
                            label:
                                'Quantity to Sell (Max ${cubit.maxQuantity})',
                            hintText: 'Enter quantity',
                            controller: cubit.quantityController,
                            keyboardType: TextInputType.number,
                            validator: cubit.validateQuantity,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: cubit.payoutMethod,
                            items: const [
                              DropdownMenuItem(
                                value: 'Wallet Cash',
                                child: Text('Wallet Cash'),
                              ),
                              DropdownMenuItem(
                                value: 'Bank Account',
                                child: Text('Bank Account'),
                              ),
                            ],
                            onChanged: cubit.updatePayoutMethod,
                            decoration: const InputDecoration(
                              labelText: 'Payout Method',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ActionTextField(
                            label: 'Note',
                            hintText: 'Optional note',
                            controller: cubit.noteController,
                          ),
                        ],
                      ),
                    ),
                    FeeSummaryCard(
                      grossAmount: cubit.formatCurrency(cubit.grossAmount),
                      feeAmount: cubit.formatCurrency(cubit.feeAmount),
                      totalAmount: cubit.formatCurrency(cubit.receivedAmount),
                      totalLabel: 'You Receive',
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
