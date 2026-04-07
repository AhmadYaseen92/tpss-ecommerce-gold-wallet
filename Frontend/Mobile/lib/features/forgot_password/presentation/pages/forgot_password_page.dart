import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/widgets/reset_password_form.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/widgets/set_new_password_form.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/widgets/verify_otp_form.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) async {
          if (state is ForgotPasswordSuccess) {
            await AppModalAlert.show(
              context,
              title: 'Success',
              message: 'Password reset successfully!',
            );
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.loginRoute,
              (route) => false,
            );
          } else if (state is ForgotPasswordError) {
            AppModalAlert.show(
              context,
              title: 'Error',
              message: state.message,
            );
          }
        },
        
        builder: (context, state) {
          final cubit = BlocProvider.of<ForgotPasswordCubit>(context);

          if (state is ForgotPasswordLoading) {
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
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (cubit.currentStep > 1) {
                    cubit.goBack();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cubit.currentStep == 1) ResetPasswordForm(cubit: cubit),
                    if (cubit.currentStep == 2) VerifyOtpForm(cubit: cubit),
                    if (cubit.currentStep == 3)
                      SetNewPasswordForm(cubit: cubit),
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
