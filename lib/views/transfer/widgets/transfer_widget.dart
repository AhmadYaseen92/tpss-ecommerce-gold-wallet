import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/cubit/transfer_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/amount_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_dropdown.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/form_header.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/terms_row.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transfer/widgets/recipient_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transfer/widgets/recipient_toggle.dart';
import 'package:tpss_ecommerce_gold_wallet/views/transfer/widgets/summary_card.dart';

class TransferWidget extends StatelessWidget {
  final TransferCubit cubit;
  const TransferWidget({super.key, required this.cubit});

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
                  const FormSectionLabel(label: 'SELECT ASSET'),
                  const SizedBox(height: 8),
                  AppDropdown(cubit: cubit),

                  const SizedBox(height: 16),

                  const FormSectionLabel(label: 'AMOUNT (GRAMS)'),
                  const SizedBox(height: 8),
                  AmountField(cubit: cubit),

                  const SizedBox(height: 16),

                  const FormSectionLabel(label: 'SEND TO'),
                  const SizedBox(height: 8),
                  RecipientToggle(cubit: cubit),
                  const SizedBox(height: 10),
                  RecipientField(cubit: cubit),

                  const SizedBox(height: 20),

                  SummaryCard(cubit: cubit),

                  const SizedBox(height: 20),

                  TermsRow(
                    value: cubit.agreedToTerms,
                    onChanged: cubit.toggleTerms,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AppButton(
              label: 'Send Gift',
              icon: Icons.send_rounded,
              onPressed: cubit.submit,
            ),
          ),
        ],
      ),
    );
  }
}
