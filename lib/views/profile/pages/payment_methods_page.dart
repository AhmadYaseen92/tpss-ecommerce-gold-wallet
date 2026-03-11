import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _isEditing = false;
  String _selectedMethod = 'Credit/Debit Card';

  final Map<String, List<Map<String, dynamic>>> _methodFields = {
    'Credit/Debit Card': [
      {'hint': 'Card Holder Name', 'value': 'Ahmad Mohammad Yaseen', 'icon': Icons.person_outline},
      {'hint': 'Card Number', 'value': '4111 1111 1111 9281', 'icon': Icons.credit_card},
      {'hint': 'Expiry Date', 'value': '09/28', 'icon': Icons.date_range_outlined},
      {'hint': 'CVV', 'value': '***', 'icon': Icons.security},
    ],
    'PayPal': [
      {'hint': 'PayPal Email', 'value': 'ahmad.yaseen@paypal.com', 'icon': Icons.email_outlined},
    ],
    'Apple Pay': [
      {'hint': 'Apple Pay Number', 'value': '+962 79 123 4567', 'icon': Icons.phone_iphone_outlined},
    ],
    'Google Pay': [
      {'hint': 'Google Pay Number', 'value': '+962 78 777 1234', 'icon': Icons.android_outlined},
    ],
    'Bank Transfer': [
      {'hint': 'Bank Transfer Reference', 'value': 'TRPSS-ACC-99812', 'icon': Icons.compare_arrows_outlined},
      {'hint': 'Beneficiary Name', 'value': 'Ahmad Mohammad Yaseen', 'icon': Icons.badge_outlined},
    ],
    'Wallet Balance': [
      {'hint': 'Wallet Nickname', 'value': 'Primary Gold Wallet', 'icon': Icons.account_balance_wallet_outlined},
    ],
  };

  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    _loadMethodFields();
  }

  void _loadMethodFields() {
    final fields = _methodFields[_selectedMethod]!;
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < fields.length ? fields[i]['value'] as String : '';
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
    final fields = _methodFields[_selectedMethod]!;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Payment Methods',
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
                  title: 'Payment',
                  subtitle: 'Select payment method then edit its fields.',
                ),
                const SizedBox(height: 20),
                const SignupSectionLabel(label: 'SELECT METHOD'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  items: _methodFields.keys
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMethod = value;
                        _loadMethodFields();
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
                const SignupSectionLabel(label: 'METHOD FIELDS'),
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
