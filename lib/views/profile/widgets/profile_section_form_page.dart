import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class ProfileSectionField {
  final String label;
  final String hint;
  final String initialValue;
  final IconData icon;
  final TextInputType? keyboardType;

  const ProfileSectionField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.icon,
    this.keyboardType,
  });
}

class ProfileSelectionOption {
  final String title;
  final String? subtitle;

  const ProfileSelectionOption({required this.title, this.subtitle});
}

class ProfileSelectionGroup {
  final String label;
  final IconData icon;
  final List<ProfileSelectionOption> options;
  final String selectedValue;

  const ProfileSelectionGroup({
    required this.label,
    required this.icon,
    required this.options,
    required this.selectedValue,
  });
}

class ProfileSectionFormPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<ProfileSectionField> fields;
  final List<ProfileSelectionGroup> selectionGroups;

  const ProfileSectionFormPage({
    super.key,
    required this.title,
    required this.subtitle,
    this.fields = const [],
    this.selectionGroups = const [],
  });

  @override
  State<ProfileSectionFormPage> createState() => _ProfileSectionFormPageState();
}

class _ProfileSectionFormPageState extends State<ProfileSectionFormPage> {
  late final List<TextEditingController> _controllers;
  late final List<String> _initialValues;
  late final Map<int, String> _selectedValues;
  late final Map<int, String> _initialSelectedValues;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initialValues = widget.fields.map((field) => field.initialValue).toList();
    _controllers = _initialValues
        .map((value) => TextEditingController(text: value))
        .toList();

    _selectedValues = {
      for (var i = 0; i < widget.selectionGroups.length; i++)
        i: widget.selectionGroups[i].selectedValue,
    };

    _initialSelectedValues = Map.from(_selectedValues);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    if (_isEditing) {
      for (var i = 0; i < _controllers.length; i++) {
        _controllers[i].text = _initialValues[i];
      }

      _selectedValues
        ..clear()
        ..addAll(_initialSelectedValues);
    }

    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    for (var i = 0; i < _controllers.length; i++) {
      _initialValues[i] = _controllers[i].text;
    }

    _initialSelectedValues
      ..clear()
      ..addAll(_selectedValues);

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.title} updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _toggleEditMode,
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            label: Text(_isEditing ? 'Cancel' : 'Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                SignupHeader(title: widget.title, subtitle: widget.subtitle),
                const SizedBox(height: 20),
                if (widget.fields.isNotEmpty) ...[
                  const SignupSectionLabel(label: 'DETAILS'),
                  const SizedBox(height: 8),
                  ...List.generate(widget.fields.length, (index) {
                    final field = widget.fields[index];
                    return AppTextField(
                      label: field.label,
                      hint: field.hint,
                      prefixIcon: field.icon,
                      controller: _controllers[index],
                      enabled: _isEditing,
                      keyboardType: field.keyboardType,
                    );
                  }),
                ],
                if (widget.selectionGroups.isNotEmpty) ...[
                  if (widget.fields.isNotEmpty) const SizedBox(height: 14),
                  const Divider(color: AppColors.greyShade400),
                  const SizedBox(height: 14),
                  ...List.generate(widget.selectionGroups.length, (groupIndex) {
                    final group = widget.selectionGroups[groupIndex];
                    final selectedValue = _selectedValues[groupIndex] ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignupSectionLabel(label: group.label.toUpperCase()),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.luxuryIvory,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.greyBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(group.icon, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Selected: $selectedValue',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...group.options.map((option) {
                          return RadioListTile<String>(
                            value: option.title,
                            groupValue: selectedValue,
                            onChanged: _isEditing
                                ? (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedValues[groupIndex] = value;
                                      });
                                    }
                                  }
                                : null,
                            title: Text(option.title),
                            subtitle: option.subtitle != null
                                ? Text(option.subtitle!)
                                : null,
                            activeColor: AppColors.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                ],
                const SizedBox(height: 12),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _saveChanges,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.luxuryIvory,
                        side: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
