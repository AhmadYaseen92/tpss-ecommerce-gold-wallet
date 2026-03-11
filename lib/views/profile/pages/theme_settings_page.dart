import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Theme',
      subtitle: 'Select one theme mode and one accent style.',
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
        ProfileSelectionGroup(
          label: 'Accent Style',
          icon: Icons.palette_outlined,
          selectedValue: 'Gold',
          options: [
            ProfileSelectionOption(title: 'Gold'),
            ProfileSelectionOption(title: 'Emerald'),
            ProfileSelectionOption(title: 'Sapphire'),
          ],
        ),
      ],
    );
  }
}
