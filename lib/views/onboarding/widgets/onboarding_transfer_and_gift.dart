import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';

class OnboardingTransferAndGiftPage extends StatelessWidget {
  const OnboardingTransferAndGiftPage({super.key,required this.cubit});
  final OnboardingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
                    },
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 440,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/gold1.jpeg', fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.transparent,
                            AppColors.greyShade100.withOpacity(0.75),
                            AppColors.greyShade100,
                          ],
                          stops: const [0.55, 0.82, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'Transfer & Gift Gold',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Send gold to friends and family instantly. It\'s the perfect gift that holds its value forever.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyShade600,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Next',
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.loginRoute);
                },
              ),
            ],
          ),
        ),
      );
  }
}
