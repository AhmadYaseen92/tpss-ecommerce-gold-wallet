import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/features/login/presentation/cubit/login_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';

class BiometricButtons extends StatelessWidget {
  final LoginCubit cubit;

  const BiometricButtons({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          cubit: cubit,
          label: 'Face ID',
          icon: Icons.face_outlined,
          onPressed: cubit.loginWithFaceId,
        ),
        const SizedBox(height: 14),
        AppButton(
          cubit: cubit,
          label: 'Fingerprint',
          icon: Icons.fingerprint,
          onPressed: cubit.loginWithFingerprint,
        ),
      ],
    );
  }
}
