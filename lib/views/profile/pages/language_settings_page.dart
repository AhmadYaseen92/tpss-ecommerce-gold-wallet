import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Language',
      fields: [
        ProfileSectionField(
          label: 'Application Language',
          initialValue: 'English',
          icon: Icons.language_outlined,
        ),
        ProfileSectionField(
          label: 'Secondary Language',
          initialValue: 'Arabic',
          icon: Icons.translate_outlined,
        ),
      ],
    );
  }
}
