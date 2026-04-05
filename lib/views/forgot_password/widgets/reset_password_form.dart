import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/forgot_password/presentation/cubit/forgot_password_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/forgot_password/widgets/delivery_method_card.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/form_header.dart';

class ResetPasswordForm extends StatelessWidget {
  ResetPasswordForm({super.key, required this.cubit});

  final ForgotPasswordCubit cubit;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormHeader(
            title: 'Reset Password',
            subtitle:
                'Enter your registered email or phone number to receive a verification code.',
          ),
          const SizedBox(height: 28),
          Text(
            'Email or Phone',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          AppTextField(
            initialValue: cubit.contact,
            label: '',
            hint: 'username@example.com',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onChanged: cubit.updateContact,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your email or phone number.'
                : null,
          ),
          const SizedBox(height: 24),
          Text(
            'Delivery Method',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DeliveryMethodCard(
            title: 'Send OTP via Email',
            subtitle: 'Code sent to reg***@email.com',
            icon: Icons.mail_outline,
            isSelected: cubit.deliveryMethod == 'email',
            onTap: () => cubit.updateDeliveryMethod('email'),
          ),
          const SizedBox(height: 12),
          DeliveryMethodCard(
            title: 'Send OTP via SMS',
            subtitle: 'Code sent to +1 *** *** **99',
            icon: Icons.smartphone_outlined,
            isSelected: cubit.deliveryMethod == 'sms',
            onTap: () => cubit.updateDeliveryMethod('sms'),
          ),
          const SizedBox(height: 40),
          AppButton(
            label: 'Send OTP',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                cubit.sendOtp();
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
