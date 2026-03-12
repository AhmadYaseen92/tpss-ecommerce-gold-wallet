import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/profile_cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/form_header.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final options = ['Light', 'Dark', 'System Default'];

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.backgroundColor,
              title: Text(
                'Theme',
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
                    const FormHeader(
                      title: 'Theme Settings',
                      subtitle: 'Choose one theme mode.',
                    ),
                    const SizedBox(height: 16),
                    const FormSectionLabel(label: 'THEME MODE'),
                    ...options.map(
                      (option) => RadioListTile<String>(
                        value: option,
                        groupValue: cubit.selectedTheme,
                        onChanged: cubit.isEditing
                            ? (value) {
                                if (value != null) cubit.selectTheme(value);
                              }
                            : null,
                        title: Text(option),
                        activeColor: AppColors.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (cubit.isEditing)
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Theme updated successfully'),
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
