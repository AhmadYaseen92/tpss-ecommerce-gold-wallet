import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/widgets/profile_item_widget.dart';

class PreferencesWidget extends StatelessWidget {
  const PreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ProfileItemWidget(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English, Arabic, Turkish',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.languageRoute),
          ),
          ProfileItemWidget(
            icon: Icons.brightness_6,
            title: 'Theme',
            subtitle: 'Light, Dark, System default',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.themeRoute),
          ),
        ],
      ),
    );
  }
}
