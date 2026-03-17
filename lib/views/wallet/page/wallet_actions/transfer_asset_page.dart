import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/models/wallet_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/wallet_action_cubit/transfer_asset_action_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/page/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/wallet/widgets/wallet_actions/wallet_asset_summary_card.dart';

class TransferAssetPage extends StatelessWidget {
  final WalletTransaction asset;

  TransferAssetPage({super.key, required this.asset});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransferAssetActionCubit(asset: asset),
      child: BlocBuilder<TransferAssetActionCubit, TransferAssetActionState>(
        builder: (context, state) {
          final cubit = context.read<TransferAssetActionCubit>();

          return Scaffold(
            appBar: AppBar(title: Text(cubit.isGift ? 'Gift Asset' : 'Transfer Asset')),
            bottomNavigationBar: ActionBottomBar(
              summaryLabel: 'Estimated Value',
              summaryValue: cubit.formatCurrency(cubit.estimatedValue),
              buttonText: cubit.isGift ? 'Review Gift' : 'Review Transfer',
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
                      title: 'Transfer Type',
                      child: SegmentedButton<WalletActionType>(
                        segments: const [
                          ButtonSegment(
                            value: WalletActionType.transfer,
                            label: Text('Transfer'),
                          ),
                          ButtonSegment(value: WalletActionType.gift, label: Text('Gift')),
                        ],
                        selected: {cubit.transferType},
                        onSelectionChanged: (values) {
                          cubit.updateTransferType(values.first);
                        },
                      ),
                    ),
                    ActionSectionCard(
                      title: 'Recipient Details',
                      child: Column(
                        children: [
                          ActionTextField(
                            label: 'Recipient Name',
                            hintText: 'Enter recipient name',
                            controller: cubit.recipientNameController,
                            validator: cubit.validateRecipientName,
                          ),
                          const SizedBox(height: 12),
                          ActionTextField(
                            label: cubit.isGift
                                ? 'Recipient Email / Mobile'
                                : 'Wallet ID / Email / Mobile',
                            hintText: 'Enter recipient contact',
                            controller: cubit.recipientContactController,
                            validator: cubit.validateRecipientContact,
                          ),
                        ],
                      ),
                    ),
                    ActionSectionCard(
                      title: 'Transfer Details',
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
                          ActionTextField(
                            label: cubit.isGift ? 'Gift Message' : 'Transfer Note',
                            hintText: cubit.isGift
                                ? 'Write a gift message'
                                : 'Optional transfer note',
                            controller: cubit.messageController,
                          ),
                        ],
                      ),
                    ),
                    FeeSummaryCard(
                      grossAmount: cubit.formatCurrency(cubit.grossAmount),
                      feeAmount: cubit.formatCurrency(cubit.feeAmount),
                      totalAmount: cubit.formatCurrency(cubit.estimatedValue),
                      totalLabel: 'Estimated Value',
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
