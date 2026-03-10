import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Personal Information',
      fields: [
        ProfileSectionField(
          label: 'Full Name',
          initialValue: 'Ahmad Yaseen',
          icon: Icons.person_outline,
        ),
        ProfileSectionField(
          label: 'Email Address',
          initialValue: 'AhmadYaseen@TradePSS.com',
          icon: Icons.email_outlined,
        ),
        ProfileSectionField(
          label: 'Phone Number',
          initialValue: '00962 79 123 4567',
          icon: Icons.phone_outlined,
        ),
        ProfileSectionField(
          label: 'Address',
          initialValue: 'Amman, Jordan',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }
}
