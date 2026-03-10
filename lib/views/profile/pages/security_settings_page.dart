import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Security Settings',
      fields: [
        ProfileSectionField(
          label: 'Password',
          initialValue: '********',
          icon: Icons.lock_outline,
        ),
        ProfileSectionField(
          label: 'Two-Factor Authentication',
          initialValue: 'Enabled',
          icon: Icons.verified_user_outlined,
        ),
        ProfileSectionField(
          label: 'Face ID',
          initialValue: 'Enabled',
          icon: Icons.face_outlined,
        ),
      ],
    );
  }
}
