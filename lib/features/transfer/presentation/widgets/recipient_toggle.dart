import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/cubit/transfer_cubit.dart';

class RecipientToggle extends StatelessWidget {
  final TransferCubit cubit;
  const RecipientToggle({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.luxuryIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 18,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 6),
          Text(
            'Account Number (Required)',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
