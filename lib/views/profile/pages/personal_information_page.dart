import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/document_type_toggle_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/nationality_dropdown_widget.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  bool _isEditing = false;

  String _selectedNationality = 'Jordanian';
  String _selectedDocumentType = 'National ID';

  final TextEditingController _firstNameController = TextEditingController(
    text: 'Ahmad',
  );
  final TextEditingController _middleNameController = TextEditingController(
    text: 'Mohammad',
  );
  final TextEditingController _lastNameController = TextEditingController(
    text: 'Yaseen',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'ahmad.yaseen@tradepss.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '791234567',
  );
  final TextEditingController _dobController = TextEditingController(
    text: '12/05/1996',
  );
  final TextEditingController _idNumberController = TextEditingController(
    text: '9876543210',
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Personal Information',
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
                  title: 'Create Your Account',
                  subtitle: "Let's start with your personal details.",
                ),
                const SizedBox(height: 24),
                const SignupSectionLabel(label: 'FULL NAME'),
                AppTextField(
                  label: 'First Name',
                  hint: 'First Name',
                  prefixIcon: Icons.person_outline,
                  controller: _firstNameController,
                  enabled: _isEditing,
                ),
                AppTextField(
                  label: 'Middle Name',
                  hint: 'Middle Name (optional)',
                  prefixIcon: Icons.person_outline,
                  controller: _middleNameController,
                  enabled: _isEditing,
                ),
                AppTextField(
                  label: 'Last Name',
                  hint: 'Last Name',
                  prefixIcon: Icons.person_outline,
                  controller: _lastNameController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                const SignupSectionLabel(label: 'CONTACT'),
                AppTextField(
                  label: 'Email Address',
                  hint: 'Email Address',
                  prefixIcon: Icons.mail_outline,
                  controller: _emailController,
                  enabled: _isEditing,
                ),
                AppTextField(
                  label: 'Phone Number',
                  hint: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 16),
                const SignupSectionLabel(label: 'DATE OF BIRTH'),
                AppTextField(
                  label: 'Date of Birth',
                  hint: 'dd/mm/yyyy',
                  prefixIcon: Icons.calendar_today_outlined,
                  controller: _dobController,
                  enabled: _isEditing,
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.greyShade400),
                const SizedBox(height: 14),
                const Text(
                  'Identity Verification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const SignupSectionLabel(label: 'NATIONALITY'),
                const SizedBox(height: 8),
                NationalityDropdown(
                  selectedNationality: _selectedNationality,
                  onChanged: _isEditing
                      ? (value) => setState(() => _selectedNationality = value)
                      : (_) {},
                ),
                const SizedBox(height: 16),
                const SignupSectionLabel(label: 'DOCUMENT TYPE'),
                const SizedBox(height: 8),
                IgnorePointer(
                  ignoring: !_isEditing,
                  child: Opacity(
                    opacity: _isEditing ? 1 : 0.7,
                    child: DocumentTypeToggle(
                      selectedType: _selectedDocumentType,
                      onChanged: (value) {
                        setState(() => _selectedDocumentType = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SignupSectionLabel(label: 'ID NUMBER'),
                AppTextField(
                  label: 'ID Number',
                  hint: 'Enter ID Number',
                  prefixIcon: Icons.badge_outlined,
                  controller: _idNumberController,
                  enabled: _isEditing,
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _isEditing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Changes saved successfully')),
                        );
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
