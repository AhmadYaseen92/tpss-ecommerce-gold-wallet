import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/step_indicator_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/onboarding/presentation/widgets/onboarding_buy_sell.dart';
import 'package:tpss_ecommerce_gold_wallet/features/onboarding/presentation/widgets/onboarding_digital_wallet.dart';
import 'package:tpss_ecommerce_gold_wallet/features/onboarding/presentation/widgets/onboarding_transfer_and_gift.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return OnboardingCubit()..loadOnboarding();
      },
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final onboardingCubit = BlocProvider.of<OnboardingCubit>(context);
          if (state is OnboardingLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              ),
            );
          } else if (state is OnboardingLoaded ||
              state is OnboardingPageChanged) {
            {
              if (onboardingCubit.currentPage == 1) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Column(
                    children: [
                      OnboardingBuySellPage(cubit: onboardingCubit),
                      const Spacer(),
                      StepIndicator(
                        currentStep: onboardingCubit.currentPage,
                        totalSteps: 3,
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              } else if (onboardingCubit.currentPage == 2) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Column(
                    children: [
                      OnboardingDigitalWalletPage(cubit: onboardingCubit),
                      const Spacer(),
                      StepIndicator(
                        currentStep: onboardingCubit.currentPage,
                        totalSteps: 3,
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              }
              if (onboardingCubit.currentPage == 3) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Column(
                    children: [
                      OnboardingTransferAndGiftPage(cubit: onboardingCubit),
                      const Spacer(),
                      StepIndicator(
                        currentStep: onboardingCubit.currentPage,
                        totalSteps: 3,
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                );
              }
            }
          } else if (state is OnboardingError) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Center(child: Text('Error: ${state.message}')),
            );
          }
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
