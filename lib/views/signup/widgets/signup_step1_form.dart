import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/signup_cubit/signup_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/phone_field_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class SignupStep1Form extends StatelessWidget {
  SignupStep1Form({super.key, required this.cubit});

  final SignupCubit cubit;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SignupHeader(
            title: 'Create Your Account',
            subtitle: "Let's start with your personal details.",
          ),
          const SizedBox(height: 28),
          const SignupSectionLabel(label: 'FULL NAME'),
          AppTextField(
            initialValue: cubit.firstName,
            label: '',
            hint: 'First Name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            onChanged: cubit.updateFirstName,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'First name is required.'
                : null,
          ),
          AppTextField(
            initialValue: cubit.middleName,
            label: '',
            hint: 'Middle Name (optional)',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            onChanged: cubit.updateMiddleName,
          ),
          AppTextField(
            initialValue: cubit.lastName,
            label: '',
            hint: 'Last Name',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            onChanged: cubit.updateLastName,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Last name is required.'
                : null,
          ),
          const SizedBox(height: 24),
          const SignupSectionLabel(label: 'CONTACT'),
          AppTextField(
            initialValue: cubit.email,
            label: '',
            hint: 'Email Address',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: cubit.updateEmail,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required.';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Please enter a valid email.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PhoneField(
            selectedCode: cubit.phoneCode,
            onCodeChanged: cubit.updatePhoneCode,
            onPhoneChanged: cubit.updatePhoneNumber,
            initialPhone: cubit.phoneNumber,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Phone number is required.' : null,
          ),
          const SizedBox(height: 24),
          const SignupSectionLabel(label: 'DATE OF BIRTH'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => cubit.pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.greyBorder, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cubit.dateOfBirth != null
                          ? '${cubit.dateOfBirth!.day.toString().padLeft(2, '0')}/'
                                '${cubit.dateOfBirth!.month.toString().padLeft(2, '0')}/'
                                '${cubit.dateOfBirth!.year}'
                          : 'dd/mm/yyyy',
                      style: TextStyle(
                        fontSize: 14,
                        color: cubit.dateOfBirth != null
                            ? AppColors.textColor
                            : AppColors.greyShade400,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.greyShade500,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            cubit: cubit,
            label: 'Next',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                cubit.goToStep2();
              }
              ;
            },
          ),
        ],
      ),
    );
  }
}
