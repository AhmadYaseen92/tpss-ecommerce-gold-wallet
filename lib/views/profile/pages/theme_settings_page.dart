import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/features/app/presentation/cubit/app_state.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/form_header.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool isEditing = false;
  ThemeMode? stagedMode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final cubit = context.read<AppCubit>();
        final selectedMode = stagedMode ?? state.themeMode;
        final palette = context.appPalette;

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
                onPressed: () {
                  setState(() {
                    if (isEditing) {
                      stagedMode = null;
                    }
                    isEditing = !isEditing;
                  });
                },
                icon: Icon(isEditing ? Icons.close : Icons.edit),
                label: Text(isEditing ? 'Cancel' : 'Edit'),
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
                    subtitle: 'Choose one theme mode.',
                  ),
                  const SizedBox(height: 16),
                  const FormSectionLabel(label: 'THEME MODE'),
                  _ThemeModeTile(
                    title: 'Light',
                    mode: ThemeMode.light,
                    groupValue: selectedMode,
                    enabled: isEditing,
                    onChanged: (mode) => setState(() => stagedMode = mode),
                  ),
                  _ThemeModeTile(
                    title: 'Dark',
                    mode: ThemeMode.dark,
                    groupValue: selectedMode,
                    enabled: isEditing,
                    onChanged: (mode) => setState(() => stagedMode = mode),
                  ),
                  _ThemeModeTile(
                    title: 'System Default',
                    mode: ThemeMode.system,
                    groupValue: selectedMode,
                    enabled: isEditing,
                    onChanged: (mode) => setState(() => stagedMode = mode),
                  ),
                  if (isEditing)
                    AppButton(
                      cubit: cubit,
                      label: 'Save Changes',
                      onPressed: () {
                        cubit.setThemeMode(stagedMode ?? state.themeMode);
                        setState(() {
                          isEditing = false;
                          stagedMode = null;
                        });
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
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.title,
    required this.mode,
    required this.groupValue,
    required this.enabled,
    required this.onChanged,
  });

  final String title;
  final ThemeMode mode;
  final ThemeMode groupValue;
  final bool enabled;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: groupValue,
      onChanged: enabled
          ? (value) {
              if (value != null) onChanged(value);
            }
          : null,
      title: Text(title),
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
