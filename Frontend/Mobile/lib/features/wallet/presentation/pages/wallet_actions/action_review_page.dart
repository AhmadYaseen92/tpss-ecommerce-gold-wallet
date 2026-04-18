import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/pages/wallet_actions/action_confirmation_page.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_bottom_bar.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/action_section_card.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/readonly_info_row.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/presentation/widgets/wallet_actions/wallet_asset_summary_card.dart';

class ActionReviewPage extends StatefulWidget {
  final WalletActionSummary summary;

  const ActionReviewPage({super.key, required this.summary});

  @override
  State<ActionReviewPage> createState() => _ActionReviewPageState();
}

class _ActionReviewPageState extends State<ActionReviewPage> {
  final IWalletActionRepository _walletActionRepository = InjectionContainer.walletActionRepository();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Transaction")),
      bottomNavigationBar: ActionBottomBar(
        summaryLabel: "Total",
        summaryValue: widget.summary.totalValue,
        buttonText: widget.summary.actionType == WalletActionType.sell ? "Confirm Sell" : "Confirm",
        onPressed: _isSubmitting
            ? null
            : () {
                if (widget.summary.actionType == WalletActionType.transfer ||
                    widget.summary.actionType == WalletActionType.gift) {
                  unawaited(_submitDirectAction(widget.summary.actionType));
                  return;
                }
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ActionConfirmationPage(summary: widget.summary),
                  ),
                );
              },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Asset
                WalletAssetSummaryCard(asset: widget.summary.asset),

                /// Action Details
                ActionSectionCard(
                  title: "Action Details",
                  child: Column(
                    children: [
                      ReadonlyInfoRow(label: "Action Type", value: widget.summary.title),
                      ReadonlyInfoRow(label: "Amount", value: widget.summary.primaryValue),
                    ],
                  ),
                ),

                /// Destination
                ActionSectionCard(
                  title: "Destination",
                  child: Column(
                    children: [
                      ReadonlyInfoRow(
                        label: widget.summary.destinationLabel,
                        value: widget.summary.destinationValue,
                      ),
                    ],
                  ),
                ),

                /// Fees
                ActionSectionCard(
                  title: "Fees",
                  child: Column(
                    children: [
                      ReadonlyInfoRow(label: "Fee", value: widget.summary.feeValue),
                      ReadonlyInfoRow(label: "Total", value: widget.summary.totalValue),
                    ],
                  ),
                ),

                /// Note
                if (widget.summary.note != null && widget.summary.note!.isNotEmpty)
                  ActionSectionCard(
                    title: "Note",
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.summary.note!),
                    ),
                  ),
              ],
            ),
          ),
          if (_isSubmitting)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _submitDirectAction(WalletActionType actionType) async {
    setState(() => _isSubmitting = true);
    try {
      final requestedQuantity = int.tryParse(widget.summary.primaryValue.split(' ').first) ?? 1;
      final safeQuantity = requestedQuantity.clamp(1, widget.summary.asset.quantity).toInt();
      final perUnitWeight = widget.summary.asset.quantity == 0
          ? 0.0
          : widget.summary.asset.weightInGrams / widget.summary.asset.quantity;
      final requestedWeight = perUnitWeight * safeQuantity.toDouble();
      final unitPricePerGram = widget.summary.asset.marketPricePerGram;
      final requestedAmount = unitPricePerGram * requestedWeight;

      await _walletActionRepository.executeWalletAction(
        WalletActionExecutionRequest(
          walletAssetId: widget.summary.asset.id,
          actionType: actionType,
          quantity: safeQuantity,
          unitPrice: unitPricePerGram,
          weight: requestedWeight,
          amount: requestedAmount,
          notes: widget.summary.note,
        ),
      );

      if (!mounted) return;
      await AppModalAlert.show(
        context,
        title: actionType == WalletActionType.sell
            ? 'Sell Submitted'
            : actionType == WalletActionType.gift
            ? 'Gift Completed'
            : 'Transfer Completed',
        message: actionType == WalletActionType.sell
            ? 'Sell request submitted successfully.'
            : actionType == WalletActionType.gift
            ? 'Gift completed successfully.'
            : 'Transfer completed successfully.',
        variant: AppModalAlertVariant.success,
      );
      if (!mounted) return;
      Navigator.popUntil(
        context,
        (route) => route.settings.name == AppRoutes.walletItemsRoute || route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      await AppModalAlert.show(
        context,
        title: actionType == WalletActionType.sell ? 'Sell Failed' : 'Action Failed',
        message: 'Failed: $e',
        variant: AppModalAlertVariant.failed,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
