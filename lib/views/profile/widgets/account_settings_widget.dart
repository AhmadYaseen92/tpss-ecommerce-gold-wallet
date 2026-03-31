import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_item_widget.dart';

class AccountSettingsWidget extends StatelessWidget {
  const AccountSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ProfileItemWidget(
            icon: Icons.account_circle,
            title: 'Personal Information',
            subtitle: 'Name, email, phone',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.personalInformationRoute),
          ),
          ProfileItemWidget(
            icon: Icons.lock,
            title: 'Security Settings',
            subtitle: 'Password, Face ID, 2FA',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.securitySettingsRoute),
          ),
          ProfileItemWidget(
            icon: Icons.account_balance,
            title: 'Linked Bank Accounts',
            subtitle: 'Banks accounts details',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.linkedBankAccountsRoute),
          ),
          ProfileItemWidget(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Credit/debit cards, PayPal, Wallets',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.paymentMethodsRoute),
          ),
        ],
      ),
    );
  }
}
