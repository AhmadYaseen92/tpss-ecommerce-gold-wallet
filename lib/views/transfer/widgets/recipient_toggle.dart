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
        _toggle(context, RecipientMode.account, 'Account', Icons.account_balance_wallet_outlined),
        const SizedBox(width: 8),
        _toggle(context, RecipientMode.email, 'Email', Icons.email_outlined),
        const SizedBox(width: 8),
        _toggle(context, RecipientMode.phone, 'Phone', Icons.phone_outlined),
      ],
    );
  }

  Widget _toggle(BuildContext context, RecipientMode mode, String label, IconData icon) {
    final selected = cubit.recipientMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => cubit.setRecipientMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.luxuryIvory : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primaryColor : AppColors.greysShade2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.primaryColor : AppColors.greyShade600),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: selected ? AppColors.primaryColor : AppColors.greyShade600)),
            ],
          ),
        ),
      ),
    );
  }
}
