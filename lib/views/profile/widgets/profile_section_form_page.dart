import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

class ProfileSectionField {
  final String label;
  final String initialValue;
  final IconData icon;

  const ProfileSectionField({
    required this.label,
    required this.initialValue,
    required this.icon,
  });
}

class ProfileSectionFormPage extends StatefulWidget {
  final String title;
  final List<ProfileSectionField> fields;

  const ProfileSectionFormPage({
    super.key,
    required this.title,
    required this.fields,
  });

  @override
  State<ProfileSectionFormPage> createState() => _ProfileSectionFormPageState();
}

class _ProfileSectionFormPageState extends State<ProfileSectionFormPage> {
  late final List<TextEditingController> _controllers;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fields
        .map((field) => TextEditingController(text: field.initialValue))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
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
            fontWeight: FontWeight.w600,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  itemCount: widget.fields.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final field = widget.fields[index];
                    return TextField(
                      controller: _controllers[index],
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: field.label,
                        prefixIcon: Icon(field.icon),
                        filled: true,
                        fillColor: _isEditing
                            ? AppColors.white
                            : AppColors.greyShade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
