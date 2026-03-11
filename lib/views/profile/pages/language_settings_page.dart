import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Language',
      subtitle: 'Choose one language for app content and notifications.',
      selectionGroups: [
        ProfileSelectionGroup(
          label: 'Application Language',
          icon: Icons.language_outlined,
          selectedValue: 'English',
          options: [
            ProfileSelectionOption(title: 'English'),
            ProfileSelectionOption(title: 'العربية'),
            ProfileSelectionOption(title: 'Türkçe'),
          ],
        ),
      ],
    );
  }
}
