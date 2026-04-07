import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/cubit/signup_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/widgets/signup_step1_form.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/widgets/signup_step2_form.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/step_indicator_widget.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            Navigator.pushNamed(context, AppRoutes.loginRoute);
          } else if (state is SignupError) {
            AppModalAlert.show(
              context,
              title: 'Signup Failed',
              message: state.message,
            );
          }
        },
        buildWhen: (_, current) =>
            current is SignupInitial ||
            current is SignupLoading ||
            current is SignupStepChanged,
        builder: (context, state) {
          final cubit = BlocProvider.of<SignupCubit>(context);
          final palette = context.appPalette;

          if (state is SignupLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              ),
            );
          }
          return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (cubit.currentStep == 2) {
                      cubit.goToStep1();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  'Sign Up',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.primary,
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cubit.currentStep == 1) SignupStep1Form(cubit: cubit),
                      if (cubit.currentStep == 2) SignupStep2Form(cubit: cubit),
                      const SizedBox(height: 24),
                      StepIndicator(currentStep: cubit.currentStep),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
        },
      ),
    );
  }
}
