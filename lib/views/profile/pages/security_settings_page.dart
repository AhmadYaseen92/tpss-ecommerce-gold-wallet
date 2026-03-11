import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/profile_cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              title: Text(
                'Security Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: cubit.toggleEdit,
                  icon: Icon(cubit.isEditing ? Icons.close : Icons.edit),
                  label: Text(cubit.isEditing ? 'Cancel' : 'Edit'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SignupHeader(
                      title: 'Security',
                      subtitle: 'Change password and select biometric login.',
                    ),
                    const SizedBox(height: 20),
                    const SignupSectionLabel(label: 'CHANGE PASSWORD'),
                    AppTextField(
                      label: 'Current Password',
                      hint: 'Current Password',
                      prefixIcon: Icons.lock_outline,
                      controller: cubit.securityControllers['Current Password'],
                      enabled: cubit.isEditing,
                    ),
                    AppTextField(
                      label: 'New Password',
                      hint: 'New Password',
                      prefixIcon: Icons.lock_reset,
                      controller: cubit.securityControllers['New Password'],
                      enabled: cubit.isEditing,
                    ),
                    AppTextField(
                      label: 'Confirm New Password',
                      hint: 'Confirm New Password',
                      prefixIcon: Icons.lock_open_outlined,
                      controller: cubit.securityControllers['Confirm New Password'],
                      enabled: cubit.isEditing,
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.greyShade400),
                    const SizedBox(height: 14),
                    const SignupSectionLabel(label: 'SELECT BIOMETRIC'),
                    ...['Face ID', 'Fingerprint', 'Disabled'].map((item) {
                      return RadioListTile<String>(
                        value: item,
                        groupValue: cubit.selectedBiometric,
                        onChanged: cubit.isEditing
                            ? (value) {
                                if (value != null) cubit.selectBiometric(value);
                              }
                            : null,
                        title: Text(item),
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                    if (cubit.isEditing)
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Security settings updated successfully'),
                            ),
                          );
                        },
                      ),
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
