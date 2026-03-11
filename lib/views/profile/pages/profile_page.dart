import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/account_settings_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/main_profile_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/profile/widgets/preferences_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.backgroundColor,
        title:Text(
            'My Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
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
            ],
          ),
        ),
      ),
    );
  }
}
