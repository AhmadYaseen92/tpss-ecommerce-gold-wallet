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

  final List<_PaymentMethod> _methods = const [
    _PaymentMethod(
      name: 'Card Payment',
      subtitle: 'Visa / MasterCard',
      icon: Icons.credit_card,
      fields: [
        _PaymentField('Card Holder Name', 'Ahmad Mohammad Yaseen', Icons.person_outline),
        _PaymentField('Card Number', '4111 1111 1111 9281', Icons.credit_card, TextInputType.number),
        _PaymentField('Expiry Date', '09/28', Icons.date_range_outlined),
        _PaymentField('CVV', '***', Icons.security, TextInputType.number),
        _PaymentField('3DS Verification', 'OTP', Icons.password_outlined),
      ],
    ),
    _PaymentMethod(
      name: 'Apple Pay',
      subtitle: 'Face ID / Touch ID / Passcode',
      icon: Icons.phone_iphone_outlined,
      fields: [
        _PaymentField('Apple ID Email', 'ahmad.yaseen@icloud.com', Icons.alternate_email, TextInputType.emailAddress),
        _PaymentField('Device Name', 'iPhone 15 Pro', Icons.devices_outlined),
        _PaymentField('Authentication Method', 'Face ID', Icons.face_retouching_natural),
        _PaymentField('Token Provider', 'Apple Pay Token Service', Icons.token_outlined),
      ],
    ),
    _PaymentMethod(
      name: 'ZainCash',
      subtitle: 'Wallet + OTP',
      icon: Icons.account_balance_wallet_outlined,
      fields: [
        _PaymentField('Wallet Number', '0791234567', Icons.phone_android_outlined, TextInputType.phone),
        _PaymentField('Provider Name', 'ZainCash', Icons.wallet),
        _PaymentField('Authorization', 'OTP', Icons.password_outlined),
        _PaymentField('Callback Endpoint', 'imseeh/zaincash/callback', Icons.link_outlined),
      ],
    ),
    _PaymentMethod(
      name: 'Orange Money',
      subtitle: 'Wallet + OTP',
      icon: Icons.account_balance_wallet_outlined,
      fields: [
        _PaymentField('Wallet Number', '0787771234', Icons.phone_android_outlined, TextInputType.phone),
        _PaymentField('Provider Name', 'Orange Money', Icons.wallet),
        _PaymentField('Authorization', 'OTP', Icons.password_outlined),
        _PaymentField('Callback Endpoint', 'imseeh/orange-money/callback', Icons.link_outlined),
      ],
    ),
    _PaymentMethod(
      name: 'Dinarak',
      subtitle: 'Wallet Confirmation',
      icon: Icons.account_balance_wallet_outlined,
      fields: [
        _PaymentField('Wallet ID', 'DIN-442390', Icons.badge_outlined),
        _PaymentField('Registered Mobile', '0775559988', Icons.phone_android_outlined, TextInputType.phone),
        _PaymentField('Provider Name', 'Dinarak', Icons.wallet),
        _PaymentField('Callback Endpoint', 'imseeh/dinarak/callback', Icons.link_outlined),
      ],
    ),
    _PaymentMethod(
      name: 'CliQ',
      subtitle: 'Bank-to-Bank Instant',
      icon: Icons.account_balance_outlined,
      fields: [
        _PaymentField('CliQ Alias', r'$ahmad.yaseen', Icons.alternate_email),
        _PaymentField('Linked Bank', 'Jordan Islamic Bank', Icons.account_balance_outlined),
        _PaymentField('Linked IBAN', 'JO94CBJO0010000000000131001', Icons.credit_card_outlined),
        _PaymentField('Confirmation Channel', 'Bank Mobile App', Icons.mobile_friendly_outlined),
      ],
    ),
  ];

  int _selectedIndex = 0;
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _buildControllers();
  }

  void _buildControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();
    _controllers.addAll(
      _methods[_selectedIndex].fields
          .map((field) => TextEditingController(text: field.initialValue)),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_methods[_selectedIndex].name} saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMethod = _methods[_selectedIndex];

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
      body: SafeArea(
        child: SingleChildScrollView(
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
                    title: 'Payment Method Selection',
                    subtitle: 'Choose method, then edit only its own fields.',
                  ),
                  const SizedBox(height: 16),
                  const SignupSectionLabel(label: 'SELECT PAYMENT METHOD'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final method = _methods[index];
                        final selected = _selectedIndex == index;
                        return ChoiceChip(
                          label: Text(method.name),
                          selected: selected,
                          avatar: Icon(
                            method.icon,
                            size: 18,
                            color: selected
                                ? AppColors.primaryColor
                                : AppColors.greyShade600,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedIndex = index;
                              _buildControllers();
                            });
                          },
                          selectedColor: AppColors.luxuryIvory,
                          side: BorderSide(
                            color: selected
                                ? AppColors.primaryColor
                                : AppColors.greyBorder,
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemCount: _methods.length,
                    ),
                  ),
                  const SizedBox(height: 14),
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
                        Icon(selectedMethod.icon, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${selectedMethod.name} • ${selectedMethod.subtitle}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const SignupSectionLabel(label: 'METHOD FIELDS'),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey(selectedMethod.name),
                      children: List.generate(selectedMethod.fields.length, (
                        index,
                      ) {
                        final field = selectedMethod.fields[index];
                        return AppTextField(
                          label: field.label,
                          hint: field.label,
                          prefixIcon: field.icon,
                          keyboardType: field.keyboardType,
                          controller: _controllers[index],
                          enabled: _isEditing,
                        );
                      }),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _save,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<_PaymentField> fields;

  const _PaymentMethod({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.fields,
  });
}

class _PaymentField {
  final String label;
  final String initialValue;
  final IconData icon;
  final TextInputType? keyboardType;

  const _PaymentField(
    this.label,
    this.initialValue,
    this.icon, [
    this.keyboardType,
  ]);
}
