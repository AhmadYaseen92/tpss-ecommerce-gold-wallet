import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
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
      create: (_) => LoginCubit(loginUseCase: InjectionContainer.loginUseCase()),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeRoute,
              (route) => false,
            );
          } else if (state is LoginError) {
            AppModalAlert.show(
              context,
              title: 'Login Failed',
              message: state.message,
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
          } else if (state is LoginInitial ||
              state is LoginPasswordVisibilityChanged ||
              state is LoginRememberMeChanged) {
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
                      const SizedBox(height: 24),
                      const OrDivider(),
                      const SizedBox(height: 24),
                      BiometricButtons(
                        cubit: BlocProvider.of<LoginCubit>(context),
                      ),
                      const SizedBox(height: 24),
                      const SignUpRow(),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
