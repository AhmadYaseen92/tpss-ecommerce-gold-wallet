import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class LinkedBankAccountsPage extends StatelessWidget {
  const LinkedBankAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Linked Bank Accounts',
      subtitle: 'Manage local and international bank account details.',
      fields: [
        ProfileSectionField(
          label: 'Account Holder Name',
          hint: 'Account Holder Name',
          initialValue: 'Ahmad Saleh Yaseen',
          icon: Icons.badge_outlined,
        ),
        ProfileSectionField(
          label: 'Bank Name',
          hint: 'Bank Name',
          initialValue: 'Jordan Islamic Bank',
          icon: Icons.account_balance_outlined,
        ),
        ProfileSectionField(
          label: 'Branch Name',
          hint: 'Branch Name',
          initialValue: 'Abdoun Branch',
          icon: Icons.business_outlined,
        ),
        ProfileSectionField(
          label: 'Country',
          hint: 'Country',
          initialValue: 'Jordan',
          icon: Icons.flag_outlined,
        ),
        ProfileSectionField(
          label: 'Currency',
          hint: 'Currency',
          initialValue: 'JOD',
          icon: Icons.currency_exchange,
        ),
        ProfileSectionField(
          label: 'Account Number',
          hint: 'Account Number',
          initialValue: '2101123456789',
          icon: Icons.confirmation_number_outlined,
          keyboardType: TextInputType.number,
        ),
        ProfileSectionField(
          label: 'IBAN',
          hint: 'IBAN',
          initialValue: 'JO94CBJO0010000000000131001',
          icon: Icons.credit_card_outlined,
        ),
        ProfileSectionField(
          label: 'SWIFT/BIC',
          hint: 'SWIFT/BIC',
          initialValue: 'JIBAJOAX',
          icon: Icons.qr_code_2_outlined,
        ),
      ],
      selectionGroups: [
        ProfileSelectionGroup(
          label: 'Default Settlement Account',
          icon: Icons.savings_outlined,
          selectedValue: 'Jordan Islamic Bank ••••6789',
          options: [
            ProfileSelectionOption(title: 'Jordan Islamic Bank ••••6789'),
            ProfileSelectionOption(title: 'Arab Bank ••••1140'),
          ],
        ),
      ],
    );
  }
}
