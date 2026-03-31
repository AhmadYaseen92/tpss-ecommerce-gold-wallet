import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/account_settings_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/main_profile_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/preferences_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title:Text(
            'My Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.primary,
            ),
          ),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainProfileWidget(),
              const SizedBox(height: 20),
              AccountSettingsWidget(),
              const SizedBox(height: 20),
              PreferencesWidget(),
              const SizedBox(height: 20),
              AppButton(
                label: 'Logout',
                icon: Icons.logout_rounded,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                    AppRoutes.loginRoute,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
