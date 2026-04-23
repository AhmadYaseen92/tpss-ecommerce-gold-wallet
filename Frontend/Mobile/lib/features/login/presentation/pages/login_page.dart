import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/cubit/login_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/widgets/biometric_buttons.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/widgets/login_form.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/widgets/login_header_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/widgets/or_divider_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/widgets/signup_row_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(
        loginUseCase: InjectionContainer.loginUseCase(),
        dio: InjectionContainer.dio(),
      ),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            final next = (AuthSessionStore.quickUnlockEnabled || AuthSessionStore.pinSetupComplete)
                ? AppRoutes.homeRoute
                : AppRoutes.securitySetupRoute;
            Navigator.pushNamedAndRemoveUntil(
              context,
              next,
              (route) => false,
            );
          } else if (state is LoginError) {
            AppModalAlert.show(
              context,
              title: 'Login Failed',
              message: state.message,
            );
          } else if (state is LoginServerCheckResult ||
              state is LoginServerConfigUpdated) {
            final message = state is LoginServerCheckResult
                ? state.message
                : 'Server settings updated.';
            final isSuccess = state is LoginServerCheckResult
                ? state.success
                : true;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: isSuccess ? Colors.green : Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LoginLoading) {
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
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 36),
                    LoginForm(),
                    if (context.watch<LoginCubit>().biometricType !=
                        BiometricTypeUI.none)
                      const SizedBox(height: 24),
                    if (context.watch<LoginCubit>().biometricType !=
                        BiometricTypeUI.none)
                      const OrDivider(),
                    if (context.watch<LoginCubit>().biometricType ==
                        BiometricTypeUI.none)
                      const SizedBox(height: 0)
                    else
                      const SizedBox(height: 24),
                    if (context.watch<LoginCubit>().biometricType !=
                        BiometricTypeUI.none)
                      BiometricButtons(),
                    if (context.watch<LoginCubit>().biometricType !=
                        BiometricTypeUI.none)
                      const SizedBox(height: 24),
                    const SignUpRow(),
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
