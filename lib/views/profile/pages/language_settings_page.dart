import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/profile_cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final options = ['English', 'العربية', 'Türkçe'];

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              title: Text(
                'Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: cubit.toggleEdit,
                  icon: Icon(state.isEditing ? Icons.close : Icons.edit),
                  label: Text(state.isEditing ? 'Cancel' : 'Edit'),
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
                      title: 'Language Settings',
                      subtitle: 'Select your app language.',
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'APPLICATION LANGUAGE'),
                    ...options.map(
                      (option) => RadioListTile<String>(
                        value: option,
                        groupValue: state.selectedLanguage,
                        onChanged: state.isEditing
                            ? (value) {
                                if (value != null) cubit.selectLanguage(value);
                              }
                            : null,
                        title: Text(option),
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (state.isEditing)
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Language updated successfully')),
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
