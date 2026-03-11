import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Security Settings',
      subtitle: 'Manage credentials and account protection preferences.',
      fields: [
        ProfileSectionField(
          label: 'Password',
          hint: 'Password',
          initialValue: '********',
          icon: Icons.lock_outline,
        ),
        ProfileSectionField(
          label: 'Backup Email',
          hint: 'Backup Email',
          initialValue: 'Ahmad.backup@TradePSS.com',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        ProfileSectionField(
          label: 'Recovery Phone',
          hint: 'Recovery Phone',
          initialValue: '+962 78 555 9988',
          icon: Icons.phone_in_talk_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
      selectionGroups: [
        ProfileSelectionGroup(
          label: 'Two-Factor Authentication',
          icon: Icons.verified_user_outlined,
          selectedValue: 'Authenticator App',
          options: [
            ProfileSelectionOption(title: 'Authenticator App'),
            ProfileSelectionOption(title: 'SMS Code'),
            ProfileSelectionOption(title: 'Disabled'),
          ],
        ),
        ProfileSelectionGroup(
          label: 'Biometric Login',
          icon: Icons.fingerprint,
          selectedValue: 'Face ID',
          options: [
            ProfileSelectionOption(title: 'Face ID'),
            ProfileSelectionOption(title: 'Fingerprint'),
            ProfileSelectionOption(title: 'Disabled'),
          ],
        ),
      ],
    );
  }
}
