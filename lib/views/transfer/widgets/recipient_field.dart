import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/transfer_cubit/transfer_cubit.dart';

class RecipientField extends StatelessWidget {
  final TransferCubit cubit;
  const RecipientField({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final isEmail = cubit.recipientMode == RecipientMode.email;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(cubit.recipientMode),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greysShade2),
        ),
        child: Row(
          children: [
            Icon(
              isEmail ? Icons.email_outlined : Icons.phone_outlined,
              color: AppColors.greyShade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: cubit.recipientController,
                keyboardType: isEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                decoration: InputDecoration(
                  hintText: isEmail
                      ? 'recipient@example.com'
                      : '+1 234 567 8900',
                  hintStyle: const TextStyle(
                    color: AppColors.greyShade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
