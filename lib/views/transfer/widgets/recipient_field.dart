import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transfer_cubit/transfer_cubit.dart';

class RecipientField extends StatelessWidget {
  final TransferCubit cubit;
  const RecipientField({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final mode = cubit.recipientMode;
    final isEmail = mode == RecipientMode.email;
    final isPhone = mode == RecipientMode.phone;
    final isAccount = mode == RecipientMode.account;

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
                isEmail ? Icons.email_outlined : isPhone ? Icons.phone_outlined : Icons.badge_outlined,
                color: AppColors.greyShade400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: cubit.recipientController,
                  keyboardType: isEmail
                      ? TextInputType.emailAddress
                      : isPhone
                          ? TextInputType.phone
                          : TextInputType.number,
                  decoration: InputDecoration(
                    hintText: isEmail
                        ? 'recipient@example.com'
                        : isPhone
                            ? '+1 234 567 8900'
                            : 'Enter account number',
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isAccount)
                TextButton(onPressed: cubit.verifyAccount, child: const Text('Verify')),
            ],
          ),
        ),
        if (isAccount)
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
                  cubit.isAccountVerified
                      ? 'Account exists in system and verified.'
                      : 'Account must be verified before transfer.',
                  style: TextStyle(color: cubit.isAccountVerified ? AppColors.green : AppColors.red),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
