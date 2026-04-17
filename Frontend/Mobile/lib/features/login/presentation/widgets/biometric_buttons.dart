import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/cubit/login_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';

class BiometricButtons extends StatelessWidget {
  const BiometricButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final cubit = context.read<LoginCubit>();

        switch (cubit.biometricType) {
          case BiometricTypeUI.faceId:
            return AppButton(
              cubit: cubit,
              label: 'Face ID',
              icon: Icons.face,
              onPressed: cubit.loginWithFaceId,
            );

          case BiometricTypeUI.fingerprint:
            return AppButton(
              cubit: cubit,
              label: 'Fingerprint',
              icon: Icons.fingerprint,
              onPressed: cubit.loginWithFingerprint,
            );

          case BiometricTypeUI.none:
          default:
            return const SizedBox(height: 0, width: 0); // show nothing
        }
      },
    );
  }
}