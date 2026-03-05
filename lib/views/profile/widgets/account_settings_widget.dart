import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_item_widget.dart';

class AccountSettingsWidget extends StatelessWidget {
  const AccountSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ProfileItemWidget(
            icon: Icons.account_circle,
            title: 'Personal Information',
            subtitle: 'Name, email, phone',
            onTap: () {
              Navigator.of(context).pushNamed('/personal-information');
            },
          ),
          ProfileItemWidget(
            icon: Icons.lock,
            title: 'Security Settings',
            subtitle: 'Password, Face ID, 2FA',
            onTap: () {
              // Handle security settings action
            },
          ),
          ProfileItemWidget(
            icon: Icons.account_balance,
            title: 'Linked Bank Accounts',
            subtitle: 'Banks accounts details',
            onTap: () {
              // Handle linked bank accounts action
            },
          ),
          ProfileItemWidget(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Credit/debit cards, PayPal, Wallets',
            onTap: () {
              // Handle payment methods action
            },
          ),
        ],
      ),
    );
  }
}
