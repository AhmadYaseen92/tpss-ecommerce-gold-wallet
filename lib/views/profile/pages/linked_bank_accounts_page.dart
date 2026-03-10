import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class LinkedBankAccountsPage extends StatelessWidget {
  const LinkedBankAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Linked Bank Accounts',
      fields: [
        ProfileSectionField(
          label: 'Bank Name',
          initialValue: 'Jordan Islamic Bank',
          icon: Icons.account_balance_outlined,
        ),
        ProfileSectionField(
          label: 'Account Number',
          initialValue: '**** **** **** 1234',
          icon: Icons.confirmation_number_outlined,
        ),
        ProfileSectionField(
          label: 'IBAN',
          initialValue: 'JO94 CBJO 0010 0000 0000 0131 001',
          icon: Icons.credit_card_outlined,
        ),
      ],
    );
  }
}
