import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Theme',
      subtitle: 'Choose one theme mode.',
      selectionGroups: [
        ProfileSelectionGroup(
          label: 'Theme Mode',
          icon: Icons.brightness_6_outlined,
          selectedValue: 'System Default',
          options: [
            ProfileSelectionOption(title: 'Light'),
            ProfileSelectionOption(title: 'Dark'),
            ProfileSelectionOption(title: 'System Default'),
          ],
        ),
      ],
    );
  }
}
