import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/user_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/login_cubit/login_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/login/widgets/remember_me_row_widget.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<LoginCubit>(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email or Phone Number",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          AppTextField(
            initialValue: cubit.identifier,
            label: 'Email or Phone Number',
            hint: 'Enter your email or phone number',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone number.';
              }
              if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value) &&
                  !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                return 'Please enter a valid email or phone number.';
              }
              if (value != dummyUser.email && value != dummyUser.phoneNumber) {
                return 'No account found with this email or phone number.';
              }
              return null;
            },
            onChanged: cubit.updateIdentifier,
          ),
          const SizedBox(height: 18),
          Text(
            "Password",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          AppTextField(
            initialValue: cubit.password,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            obscureText: cubit.obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            onToggleObscure: cubit.togglePasswordVisibility,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              if (value != dummyUser.password) {
                return 'Incorrect password. Please try again.';
              }
              return null;
            },
            onChanged: cubit.updatePassword,
          ),
          SizedBox(height: 14),
          RememberMeRow(cubit: cubit),
          SizedBox(height: 24),
          AppButton(
            cubit: cubit,
            label: 'Log In',
            onPressed: () => cubit.onLoginPressed(formKey),
          ),
        ],
      ),
    );
  }
}
