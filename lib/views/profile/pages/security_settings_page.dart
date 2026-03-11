import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isEditing = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _selectedBiometric = 'Face ID';

  @override
  void initState() {
    super.initState();
    _currentPasswordController.text = '********';
    _newPasswordController.text = '********';
    _confirmPasswordController.text = '********';
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSave() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security settings updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Security Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _isEditing = !_isEditing),
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
                const SignupHeader(
                  title: 'Security',
                  subtitle: 'Change password and choose one biometric method.',
                ),
                const SizedBox(height: 20),
                const SignupSectionLabel(label: 'CHANGE PASSWORD'),
                AppTextField(
                  label: 'Current Password',
                  hint: 'Current Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: _obscureCurrent,
                  onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  controller: _currentPasswordController,
                  enabled: _isEditing,
                ),
                AppTextField(
                  label: 'New Password',
                  hint: 'New Password',
                  prefixIcon: Icons.lock_reset,
                  isPassword: true,
                  obscureText: _obscureNew,
                  onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                  controller: _newPasswordController,
                  enabled: _isEditing,
                ),
                AppTextField(
                  label: 'Confirm New Password',
                  hint: 'Confirm New Password',
                  prefixIcon: Icons.lock_open_outlined,
                  isPassword: true,
                  obscureText: _obscureConfirm,
                  onToggleObscure: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  controller: _confirmPasswordController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.greyShade400),
                const SizedBox(height: 14),
                const SignupSectionLabel(label: 'SELECT BIOMETRIC'),
                const SizedBox(height: 8),
                ...['Face ID', 'Fingerprint', 'Disabled'].map((item) {
                  return RadioListTile<String>(
                    value: item,
                    groupValue: _selectedBiometric,
                    onChanged: _isEditing
                        ? (value) {
                            if (value != null) {
                              setState(() => _selectedBiometric = value);
                            }
                          }
                        : null,
                    title: Text(item),
                    activeColor: AppColors.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: 12),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _onSave,
                      child: const Text('Save Changes'),
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
