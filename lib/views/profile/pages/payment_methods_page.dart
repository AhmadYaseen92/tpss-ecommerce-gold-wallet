import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Payment Methods',
      fields: [
        ProfileSectionField(
          label: 'Primary Card',
          initialValue: 'Visa •••• 9281',
          icon: Icons.credit_card,
        ),
        ProfileSectionField(
          label: 'Secondary Card',
          initialValue: 'Mastercard •••• 4423',
          icon: Icons.credit_score_outlined,
        ),
        ProfileSectionField(
          label: 'PayPal',
          initialValue: 'ahmadyaseen@paypal.com',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }
}
