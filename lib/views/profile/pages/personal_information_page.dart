import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Personal Information',
      subtitle: 'Keep your personal details up to date for verification.',
      fields: [
        ProfileSectionField(
          label: 'First Name',
          hint: 'First Name',
          initialValue: 'Ahmad',
          icon: Icons.person_outline,
        ),
        ProfileSectionField(
          label: 'Middle Name',
          hint: 'Middle Name (optional)',
          initialValue: 'Saleh',
          icon: Icons.person_outline,
        ),
        ProfileSectionField(
          label: 'Last Name',
          hint: 'Last Name',
          initialValue: 'Yaseen',
          icon: Icons.person_outline,
        ),
        ProfileSectionField(
          label: 'Email Address',
          hint: 'Email Address',
          initialValue: 'AhmadYaseen@TradePSS.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        ProfileSectionField(
          label: 'Phone Number',
          hint: 'Phone Number',
          initialValue: '+962 79 123 4567',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        ProfileSectionField(
          label: 'City',
          hint: 'City',
          initialValue: 'Amman',
          icon: Icons.location_city_outlined,
        ),
        ProfileSectionField(
          label: 'Address Line',
          hint: 'Address Line',
          initialValue: '7th Circle, Zahran Street',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }
}
