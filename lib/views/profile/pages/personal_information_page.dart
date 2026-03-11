import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/profile_cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/document_type_toggle_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/nationality_dropdown_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

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
                'Personal Information',
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
                      title: 'Create Your Account',
                      subtitle: "Let's start with your personal details.",
                    ),
                    const SizedBox(height: 24),
                    const SignupSectionLabel(label: 'FULL NAME'),
                    AppTextField(
                      label: 'First Name',
                      hint: 'First Name',
                      prefixIcon: Icons.person_outline,
                      controller: cubit.personalControllers['First Name'],
                      enabled: cubit.isEditing,
                    ),
                    AppTextField(
                      label: 'Middle Name',
                      hint: 'Middle Name (optional)',
                      prefixIcon: Icons.person_outline,
                      controller: cubit.personalControllers['Middle Name'],
                      enabled: cubit.isEditing,
                    ),
                    AppTextField(
                      label: 'Last Name',
                      hint: 'Last Name',
                      prefixIcon: Icons.person_outline,
                      controller: cubit.personalControllers['Last Name'],
                      enabled: cubit.isEditing,
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'CONTACT'),
                    AppTextField(
                      label: 'Email Address',
                      hint: 'Email Address',
                      prefixIcon: Icons.mail_outline,
                      controller: cubit.personalControllers['Email Address'],
                      enabled: cubit.isEditing,
                    ),
                    AppTextField(
                      label: 'Phone Number',
                      hint: 'Phone Number',
                      prefixIcon: Icons.phone_outlined,
                      controller: cubit.personalControllers['Phone Number'],
                      enabled: cubit.isEditing,
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'DATE OF BIRTH'),
                    AppTextField(
                      label: 'Date of Birth',
                      hint: 'dd/mm/yyyy',
                      prefixIcon: Icons.calendar_today_outlined,
                      controller: cubit.personalControllers['Date of Birth'],
                      enabled: cubit.isEditing,
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.greyShade400),
                    const SizedBox(height: 14),
                    const Text(
                      'Identity Verification',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'NATIONALITY'),
                    const SizedBox(height: 8),
                    IgnorePointer(
                      ignoring: !cubit.isEditing,
                      child: Opacity(
                        opacity: cubit.isEditing ? 1 : 0.7,
                        child: NationalityDropdown(
                          selectedNationality: cubit.selectedNationality,
                          onChanged: cubit.selectNationality,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'DOCUMENT TYPE'),
                    const SizedBox(height: 8),
                    IgnorePointer(
                      ignoring: !cubit.isEditing,
                      child: Opacity(
                        opacity: cubit.isEditing ? 1 : 0.7,
                        child: DocumentTypeToggle(
                          selectedType: cubit.selectedDocumentType,
                          onChanged: cubit.selectDocumentType,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'ID NUMBER'),
                    AppTextField(
                      label: 'ID Number',
                      hint: 'Enter ID Number',
                      prefixIcon: Icons.badge_outlined,
                      controller: cubit.personalControllers['ID Number'],
                      enabled: cubit.isEditing,
                    ),
                    if (cubit.isEditing) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Personal information saved successfully'),
                            ),
                          );
                        },
                      ),
                    ],
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
