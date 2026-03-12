import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transfer_cubit/transfer_cubit.dart';

class RecipientToggle extends StatelessWidget {
  final TransferCubit cubit;
  const RecipientToggle({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => cubit.setRecipientMode(RecipientMode.email),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cubit.recipientMode == RecipientMode.email
                  ? AppColors.luxuryIvory
                  : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cubit.recipientMode == RecipientMode.email
                    ? AppColors.primaryColor
                    : AppColors.greysShade2,
                width: cubit.recipientMode == RecipientMode.email ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: cubit.recipientMode == RecipientMode.email
                      ? AppColors.primaryColor
                      : AppColors.greyShade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: cubit.recipientMode == RecipientMode.email
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: cubit.recipientMode == RecipientMode.email
                        ? AppColors.primaryColor
                        : AppColors.greyShade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => cubit.setRecipientMode(RecipientMode.phone),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cubit.recipientMode == RecipientMode.phone
                  ? AppColors.luxuryIvory
                  : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cubit.recipientMode == RecipientMode.phone
                    ? AppColors.primaryColor
                    : AppColors.greysShade2,
                width: cubit.recipientMode == RecipientMode.phone ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: cubit.recipientMode == RecipientMode.phone
                      ? AppColors.primaryColor
                      : AppColors.greyShade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Phone',
                  style: TextStyle(
                    fontWeight: cubit.recipientMode == RecipientMode.phone
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: cubit.recipientMode == RecipientMode.phone
                        ? AppColors.primaryColor
                        : AppColors.greyShade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}