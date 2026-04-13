import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/routes/app_routes.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/widgets/document_type_toggle_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/features/signup/presentation/widgets/nationality_dropdown_widget.dart';

class PersonalInformationPage extends StatelessWidget {
  const PersonalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileSaved) {
            await AppModalAlert.show(
              context,
              title: 'Saved',
              message: 'Personal information saved successfully',
            );
          }
          if (state is ProfileError) {
            await AppModalAlert.show(
              context,
              title: 'Validation Error',
              message: state.message,
              variant: AppModalAlertVariant.failed,
            );
          }
          if (state is ProfileEmailChangedRequiresRelogin) {
            await AppModalAlert.show(
              context,
              title: 'Email updated',
              message:
                  'We sent a one-time OTP to ${state.newEmail}. For security, please login again using your new email.',
            );
            if (!context.mounted) return;
            await Navigator.pushNamed(
              context,
              AppRoutes.confirmOtpRoute,
              arguments: const {
                'title': 'Confirm Email OTP',
                'subtitle': 'Enter the OTP sent to your updated email address.',
              },
            );
            AuthSessionStore.clear();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.loginRoute,
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final palette = context.appPalette;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.primary,
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
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormHeader(
                      title: 'Create Your Account',
                      subtitle: "Let's start with your personal details.",
                    ),
                    const SizedBox(height: 24),
                    const FormSectionLabel(label: 'FULL NAME'),
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
                    const FormSectionLabel(label: 'CONTACT'),
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
                    const FormSectionLabel(label: 'DATE OF BIRTH'),
                    AppTextField(
                      label: 'Date of Birth',
                      hint: 'dd/mm/yyyy',
                      prefixIcon: Icons.calendar_today_outlined,
                      controller: cubit.personalControllers['Date of Birth'],
                      enabled: cubit.isEditing,
                    ),
                    const SizedBox(height: 14),
                    Divider(color: palette.border),
                    const SizedBox(height: 14),
                    const Text(
                      'Identity Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const FormSectionLabel(label: 'NATIONALITY'),
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
                    const FormSectionLabel(label: 'DOCUMENT TYPE'),
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
                    const FormSectionLabel(label: 'ID NUMBER'),
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
                        onPressed: cubit.savePersonalInfo,
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
