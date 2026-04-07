import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Future<void> load(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacementNamed(context, AppRoutes.onboardingRoute);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: load(context),
      builder: (context, snapshot) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.backgroundColor,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      'TPSS GOLD WALLET',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                        color: AppColors.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'trusted since 2026',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                        color: AppColors.greyShade600,
                      ),
                    ),
                    const Spacer(),
                    LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: AppColors.greyShade400.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'VERSION 1.0.2',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w400,
                        color: AppColors.greyShade500,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
