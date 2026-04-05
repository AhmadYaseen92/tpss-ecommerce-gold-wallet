import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/cubit/transfer_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/terms_row.dart';

class TransferTermsRow extends StatelessWidget {
  final TransferCubit cubit;
  const TransferTermsRow({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return TermsRow(
      value: cubit.agreedToTerms,
      onChanged: cubit.toggleTerms,
    );
  }
}
