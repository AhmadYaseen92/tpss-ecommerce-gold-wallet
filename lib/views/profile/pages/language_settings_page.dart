import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/profile_cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/form_header.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final options = ['English', 'العربية', 'Türkçe'];
          final palette = context.appPalette;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Language',
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
                      title: 'Language Settings',
                      subtitle: 'Select your app language.',
                    ),
                    const SizedBox(height: 16),
                    const FormSectionLabel(label: 'APPLICATION LANGUAGE'),
                    ...options.map(
                      (option) => RadioListTile<String>(
                        value: option,
                        groupValue: cubit.selectedLanguage,
                        onChanged: cubit.isEditing
                            ? (value) {
                                if (value != null) cubit.selectLanguage(value);
                              }
                            : null,
                        title: Text(option),
                        activeColor: palette.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (cubit.isEditing)
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.save();
                          AppModalAlert.show(
                            context,
                            title: 'Saved',
                            message: 'Language updated successfully',
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
