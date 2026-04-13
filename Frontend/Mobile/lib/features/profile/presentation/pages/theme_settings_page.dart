import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          final selected = context.read<ProfileCubit>().selectedTheme.toLowerCase();
          final appCubit = context.read<AppCubit>();
          if (selected.contains('dark')) {
            appCubit.setThemeMode(ThemeMode.dark);
          } else if (selected.contains('light')) {
            appCubit.setThemeMode(ThemeMode.light);
          } else {
            appCubit.setThemeMode(ThemeMode.system);
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final palette = context.appPalette;
          const options = ['Light', 'Dark', 'System Default'];

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Theme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormHeader(
                      title: 'Theme Settings',
                      subtitle: 'Save your preferred theme to server.',
                    ),
                    const SizedBox(height: 16),
                    const FormSectionLabel(label: 'THEME MODE'),
                    ...options.map(
                      (item) => RadioListTile<String>(
                        value: item,
                        groupValue: cubit.selectedTheme,
                        onChanged: cubit.isEditing
                            ? (value) {
                                if (value != null) cubit.selectTheme(value);
                              }
                            : null,
                        title: Text(item),
                        activeColor: palette.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (cubit.isEditing)
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.saveThemeSettings();
                          AppModalAlert.show(
                            context,
                            title: 'Saved',
                            message: 'Theme updated successfully',
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
