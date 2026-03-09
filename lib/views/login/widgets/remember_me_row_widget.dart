import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/login_cubit/login_cubit.dart';

class RememberMeRow extends StatelessWidget {
  const RememberMeRow({super.key, required this.cubit});

  final LoginCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: cubit.rememberMe,
                    onChanged: (val) => cubit.toggleRememberMe(val ?? false),
                    activeColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.greyShade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(fontSize: 13, color: AppColors.textColor),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
  }
}
