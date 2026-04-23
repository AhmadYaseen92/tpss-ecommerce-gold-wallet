import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/session_manager.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/widgets/account_settings_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/widgets/main_profile_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/widgets/preferences_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: palette.primary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  onPressed: () async {
                    await SessionManager.forceLogout();
                    if (!mounted) return;
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
      ),
    );
  }
}
