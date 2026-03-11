import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class LinkedBankAccountsPage extends StatefulWidget {
  const LinkedBankAccountsPage({super.key});

  @override
  State<LinkedBankAccountsPage> createState() => _LinkedBankAccountsPageState();
}

class _LinkedBankAccountsPageState extends State<LinkedBankAccountsPage> {
  bool _isEditing = false;
  String _selectedAccount = 'Jordan Islamic Bank ••••6789';

  final Map<String, List<Map<String, dynamic>>> _accountFields = {
    'Jordan Islamic Bank ••••6789': [
      {'hint': 'Account Holder Name', 'value': 'Ahmad Mohammad Yaseen', 'icon': Icons.badge_outlined},
      {'hint': 'Bank Name', 'value': 'Jordan Islamic Bank', 'icon': Icons.account_balance_outlined},
      {'hint': 'IBAN', 'value': 'JO94CBJO0010000000000131001', 'icon': Icons.credit_card_outlined},
      {'hint': 'SWIFT/BIC', 'value': 'JIBAJOAX', 'icon': Icons.qr_code_2_outlined},
    ],
    'Arab Bank ••••1140': [
      {'hint': 'Account Holder Name', 'value': 'Ahmad Mohammad Yaseen', 'icon': Icons.badge_outlined},
      {'hint': 'Bank Name', 'value': 'Arab Bank', 'icon': Icons.account_balance_outlined},
      {'hint': 'IBAN', 'value': 'JO32ARAB0000000000011400045', 'icon': Icons.credit_card_outlined},
      {'hint': 'SWIFT/BIC', 'value': 'ARABJOAXXXX', 'icon': Icons.qr_code_2_outlined},
    ],
  };

  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _loadSelectedFields();
  }

  void _loadSelectedFields() {
    final fields = _accountFields[_selectedAccount]!;
    for (var i = 0; i < fields.length; i++) {
      _controllers[i].text = fields[i]['value'] as String;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = _accountFields[_selectedAccount]!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Linked Bank Accounts',
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
                  title: 'Bank Information',
                  subtitle: 'Select bank account then edit its details.',
                ),
                const SizedBox(height: 20),
                const SignupSectionLabel(label: 'SELECT BANK ACCOUNT'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedAccount,
                  items: _accountFields.keys
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAccount = value;
                        _loadSelectedFields();
                      });
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SignupSectionLabel(label: 'ACCOUNT DETAILS'),
                ...List.generate(fields.length, (index) {
                  return AppTextField(
                    label: fields[index]['hint'] as String,
                    hint: fields[index]['hint'] as String,
                    controller: _controllers[index],
                    enabled: _isEditing,
                    prefixIcon: fields[index]['icon'] as IconData,
                  );
                }),
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
