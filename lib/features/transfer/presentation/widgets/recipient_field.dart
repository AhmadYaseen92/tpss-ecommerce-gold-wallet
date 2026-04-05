import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/cubit/transfer_cubit.dart';

class RecipientField extends StatelessWidget {
  final TransferCubit cubit;
  const RecipientField({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final hasInput = cubit.recipientController.text.trim().isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greysShade2),
          ),
          child: Row(
            children: [
              Icon(
                Icons.badge_outlined,
                color: AppColors.greyShade400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cubit.recipientController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter recipient account number',
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton(onPressed: cubit.verifyAccount, child: const Text('Verify')),
            ],
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  cubit.isAccountVerified ? Icons.verified : Icons.error_outline,
                  color: cubit.isAccountVerified ? AppColors.green : AppColors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  !hasInput
                      ? 'Enter account number to verify in system.'
                      : cubit.isAccountVerified
                          ? 'Verified: account exists in our system.'
                          : 'Not verified: account does not exist in our system.',
                  style: TextStyle(
                    color: !hasInput
                        ? AppColors.greyShade600
                        : cubit.isAccountVerified
                            ? AppColors.green
                            : AppColors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
