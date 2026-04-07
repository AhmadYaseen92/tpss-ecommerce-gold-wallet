import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/presentation/cubit/transfer_asset_action_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/action_review_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/fee_summary_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/wallet_asset_summary_card.dart';

class TransferAssetPage extends StatelessWidget {
  final WalletTransactionEntity asset;

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
            appBar: AppBar(
              title: Text(cubit.isGift ? 'Gift Asset' : 'Transfer Asset'),
            ),
            bottomNavigationBar: ActionBottomBar(
              summaryLabel: 'Estimated Value',
              summaryValue: cubit.formatCurrency(cubit.estimatedValue),
              buttonText: cubit.isGift ? 'Review Gift' : 'Review Transfer',
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
                    WalletAssetSummaryCard(asset: asset),
                    ActionSectionCard(
                      title: 'Transfer Type',
                      child: SegmentedButton<WalletActionType>(
                        segments: const [
                          ButtonSegment(
                            value: WalletActionType.transfer,
                            label: Text('Transfer'),
                          ),
                          ButtonSegment(
                            value: WalletActionType.gift,
                            label: Text('Gift'),
                          ),
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
                            label: 'Recipient Account No.',
                            hintText: 'Enter recipient account number',
                            keyboardType: TextInputType.number,
                            controller: cubit.recipientContactController,
                            validator: cubit.validateRecipientContact,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                cubit.isRecipientVerified
                                    ? Icons.verified
                                    : Icons.error_outline,
                                size: 16,
                                color: cubit.isRecipientVerified
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cubit.recipientContactController.text
                                          .trim()
                                          .isEmpty
                                      ? 'Enter account number to verify recipient in our system.'
                                      : cubit.isRecipientVerified
                                      ? 'Verified: recipient account exists in our system.'
                                      : 'Not verified: recipient account does not exist in our system.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cubit.recipientContactController.text
                                            .trim()
                                            .isEmpty
                                        ? Colors.grey
                                        : cubit.isRecipientVerified
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
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
                            label: cubit.isGift
                                ? 'Gift Message'
                                : 'Transfer Note',
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
