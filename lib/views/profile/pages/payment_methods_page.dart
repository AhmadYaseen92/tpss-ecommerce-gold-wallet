import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Payment Methods',
      subtitle: 'Set up cards, wallets, and transfer preferences.',
      fields: [
        ProfileSectionField(
          label: 'Card Holder Name',
          hint: 'Card Holder Name',
          initialValue: 'Ahmad Saleh Yaseen',
          icon: Icons.person_outline,
        ),
        ProfileSectionField(
          label: 'Primary Card Number',
          hint: 'Primary Card Number',
          initialValue: '4111 1111 1111 9281',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
        ),
        ProfileSectionField(
          label: 'Expiry Date',
          hint: 'MM/YY',
          initialValue: '09/28',
          icon: Icons.date_range_outlined,
        ),
        ProfileSectionField(
          label: 'CVV',
          hint: 'CVV',
          initialValue: '***',
          icon: Icons.security,
          keyboardType: TextInputType.number,
        ),
        ProfileSectionField(
          label: 'PayPal Email',
          hint: 'PayPal Email',
          initialValue: 'ahmadyaseen@paypal.com',
          icon: Icons.account_balance_wallet_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        ProfileSectionField(
          label: 'Apple Pay Number',
          hint: 'Apple Pay Number',
          initialValue: '+962 79 123 4567',
          icon: Icons.phone_iphone_outlined,
          keyboardType: TextInputType.phone,
        ),
        ProfileSectionField(
          label: 'Google Pay Number',
          hint: 'Google Pay Number',
          initialValue: '+962 78 777 1234',
          icon: Icons.android_outlined,
          keyboardType: TextInputType.phone,
        ),
        ProfileSectionField(
          label: 'Bank Transfer Reference',
          hint: 'Bank Transfer Reference',
          initialValue: 'TRPSS-ACC-99812',
          icon: Icons.compare_arrows_outlined,
        ),
      ],
      selectionGroups: [
        ProfileSelectionGroup(
          label: 'Preferred Payment Method',
          icon: Icons.wallet_outlined,
          selectedValue: 'Credit/Debit Card',
          options: [
            ProfileSelectionOption(title: 'Credit/Debit Card'),
            ProfileSelectionOption(title: 'PayPal'),
            ProfileSelectionOption(title: 'Apple Pay'),
            ProfileSelectionOption(title: 'Google Pay'),
            ProfileSelectionOption(title: 'Bank Transfer'),
            ProfileSelectionOption(title: 'Wallet Balance'),
          ],
        ),
      ],
    );
  }
}
