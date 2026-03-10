import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/profile_section_form_page.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSectionFormPage(
      title: 'Theme',
      fields: [
        ProfileSectionField(
          label: 'Mode',
          initialValue: 'System default',
          icon: Icons.brightness_6_outlined,
        ),
        ProfileSectionField(
          label: 'Accent Color',
          initialValue: 'Gold',
          icon: Icons.palette_outlined,
        ),
      ],
    );
  }
}
