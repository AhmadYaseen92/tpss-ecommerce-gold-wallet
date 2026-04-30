import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/l10n/generated/app_localizations.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          final selected = context.read<ProfileCubit>().selectedLanguage;
          context.read<AppCubit>().setLocale(_localeFromSelection(selected));
          if (state is ProfileSaved) {
            await AppModalAlert.show(
              context,
              title: l10n.saved,
              message: l10n.languageUpdatedSuccessfully,
            );
          }
          if (state is ProfileError) {
            await AppModalAlert.show(
              context,
              title: l10n.validationError,
              message: state.message,
              variant: AppModalAlertVariant.failed,
            );
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final options = [l10n.english, l10n.arabic];
          final palette = context.appPalette;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                l10n.language,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: palette.primary,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: cubit.toggleEdit,
                  icon: Icon(cubit.isEditing ? Icons.close : Icons.edit),
                  label: Text(cubit.isEditing ? l10n.cancel : l10n.edit),
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
                    FormHeader(
                      title: l10n.languageSettings,
                      subtitle: l10n.selectYourAppLanguage,
                    ),
                    const SizedBox(height: 16),
                    FormSectionLabel(label: l10n.applicationLanguage.toUpperCase()),
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
                        label: l10n.saveChanges,
                        onPressed: cubit.saveLanguageSettings,
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

  Locale? _localeFromSelection(String selected) {
    final normalized = selected.trim().toLowerCase();
    if (normalized == AppLocalizationsEn().english.toLowerCase()) return const Locale('en');
    if (normalized == AppLocalizationsAr().arabic.toLowerCase()) return const Locale('ar');
    return null;
  }
}
