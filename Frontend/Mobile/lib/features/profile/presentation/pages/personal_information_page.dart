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

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();

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
              title: Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.primary,
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
                child: Form(
                  key: _formKey,
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
                        label: 'First Name *',
                        hint: 'First Name',
                        prefixIcon: Icons.person_outline,
                        controller: cubit.personalControllers['First Name'],
                        enabled: cubit.isEditing,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required field' : null,
                      ),
                      AppTextField(
                        label: 'Middle Name',
                        hint: 'Middle Name (optional)',
                        prefixIcon: Icons.person_outline,
                        controller: cubit.personalControllers['Middle Name'],
                        enabled: cubit.isEditing,
                      ),
                      AppTextField(
                        label: 'Last Name *',
                        hint: 'Last Name',
                        prefixIcon: Icons.person_outline,
                        controller: cubit.personalControllers['Last Name'],
                        enabled: cubit.isEditing,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required field' : null,
                      ),
                      const SizedBox(height: 16),
                      const FormSectionLabel(label: 'CONTACT'),
                      AppTextField(
                        label: 'Email Address *',
                        hint: 'Email Address',
                        prefixIcon: Icons.mail_outline,
                        controller: cubit.personalControllers['Email Address'],
                        enabled: cubit.isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Required field';
                          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) return 'Invalid email format';
                          return null;
                        },
                      ),
                      AppTextField(
                        label: 'Phone Number *',
                        hint: 'Phone Number',
                        prefixIcon: Icons.phone_outlined,
                        controller: cubit.personalControllers['Phone Number'],
                        enabled: cubit.isEditing,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Required field';
                          if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(v)) return 'Phone must be 8-15 digits';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const FormSectionLabel(label: 'DATE OF BIRTH'),
                      AppTextField(
                        label: 'Date of Birth *',
                        hint: 'dd/mm/yyyy',
                        prefixIcon: Icons.calendar_today_outlined,
                        controller: cubit.personalControllers['Date of Birth'],
                        enabled: cubit.isEditing,
                        readOnly: true,
                        onTap: cubit.isEditing ? () => _pickDate(context, cubit) : null,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Required field' : null,
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
                      const FormSectionLabel(label: 'NATIONALITY *'),
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
                      const FormSectionLabel(label: 'DOCUMENT TYPE *'),
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
                      const FormSectionLabel(label: 'ID NUMBER *'),
                      AppTextField(
                        label: 'ID Number *',
                        hint: 'Enter ID Number',
                        prefixIcon: Icons.badge_outlined,
                        controller: cubit.personalControllers['ID Number'],
                        enabled: cubit.isEditing,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Required field';
                          if (!RegExp(r'^[A-Za-z0-9-]{4,30}$').hasMatch(v)) return 'Invalid ID format';
                          return null;
                        },
                      ),
                      if (cubit.isEditing) ...[
                        const SizedBox(height: 16),
                        AppButton(
                          cubit: cubit,
                          label: 'Save Changes',
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              cubit.savePersonalInfo();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, ProfileCubit cubit) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    final dd = picked.day.toString().padLeft(2, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final yyyy = picked.year.toString();
    cubit.personalControllers['Date of Birth']?.text = '$dd/$mm/$yyyy';
  }
}
