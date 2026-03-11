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
  String _selectedMethod = 'Card Payment (Visa / MasterCard)';

  final Map<String, _PaymentMethodConfig> _methodConfigs = {
    'Card Payment (Visa / MasterCard)': _PaymentMethodConfig(
      purpose:
          'Process secure card transactions through a PCI-compliant gateway with 3DS authentication.',
      flowSteps: const [
        'User selects card payment from mobile.',
        'System routes the request to the card gateway integration flow.',
        'Gateway initiates 3D Secure (3DS) using OTP.',
        'Gateway returns authorization result (approved / declined).',
        'System updates internal payment status and returns final response to user.',
      ],
      keyCharacteristics: const [
        'Real-time authorization',
        'Strong Customer Authentication (SCA)',
        'Immediate success/failure response',
      ],
      fields: const [
        _PaymentField(
          label: 'Card Holder Name',
          value: 'Ahmad Mohammad Yaseen',
          icon: Icons.person_outline,
        ),
        _PaymentField(
          label: 'Card Number',
          value: '4111 1111 1111 9281',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
        ),
        _PaymentField(
          label: 'Expiry Date',
          value: '09/28',
          icon: Icons.date_range_outlined,
        ),
        _PaymentField(
          label: 'CVV',
          value: '***',
          icon: Icons.security,
          keyboardType: TextInputType.number,
        ),
        _PaymentField(
          label: '3DS Authentication Method',
          value: 'OTP',
          icon: Icons.password_outlined,
        ),
        _PaymentField(
          label: 'Payment Gateway',
          value: 'PCI-Compliant Gateway',
          icon: Icons.hub_outlined,
        ),
      ],
    ),
    'Apple Pay': _PaymentMethodConfig(
      purpose:
          'Enable secure instant payments using Apple device biometrics or passcode with tokenized card data.',
      flowSteps: const [
        'User selects Apple Pay at checkout.',
        'System verifies Apple Pay availability and device eligibility.',
        'Apple Pay confirmation sheet is shown with fixed amount.',
        'User authorizes via Face ID / Touch ID / passcode.',
        'Apple Pay sends secure payment token to gateway.',
        'Gateway confirms transaction and returns result.',
        'System updates payment status and completes order.',
      ],
      keyCharacteristics: const [
        'Tokenized payment credentials',
        'Biometric/device-level authentication',
        'Fast confirmation experience',
      ],
      fields: const [
        _PaymentField(
          label: 'Apple ID Email',
          value: 'ahmad.yaseen@icloud.com',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        _PaymentField(
          label: 'Device Type',
          value: 'iPhone 15 Pro',
          icon: Icons.phone_iphone_outlined,
        ),
        _PaymentField(
          label: 'Supported Authentication',
          value: 'Face ID',
          icon: Icons.face_retouching_natural,
        ),
        _PaymentField(
          label: 'Token Provider',
          value: 'Apple Pay Token Service',
          icon: Icons.token_outlined,
        ),
      ],
    ),
    'ZainCash Wallet': _PaymentMethodConfig(
      purpose:
          'Complete wallet payments through ZainCash with OTP authorization and backend callback confirmation.',
      flowSteps: const [
        'System sends payment request to ZainCash provider.',
        'User authorizes transaction via OTP.',
        'ZainCash sends confirmation callback to backend.',
        'System updates payment status and returns result to user.',
      ],
      keyCharacteristics: const [
        'OTP-based wallet authorization',
        'Provider callback confirmation',
        'Provider-specific integration flow',
      ],
      fields: const [
        _PaymentField(
          label: 'Wallet Number',
          value: '0791234567',
          icon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        _PaymentField(
          label: 'Provider',
          value: 'ZainCash',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _PaymentField(
          label: 'Authorization Type',
          value: 'OTP',
          icon: Icons.password_outlined,
        ),
        _PaymentField(
          label: 'Callback URL Alias',
          value: 'imseeh/zaincash/callback',
          icon: Icons.link_outlined,
        ),
      ],
    ),
    'Orange Money Wallet': _PaymentMethodConfig(
      purpose:
          'Initiate Orange Money wallet payment and confirm through OTP and backend callback response.',
      flowSteps: const [
        'System initiates payment request with Orange Money.',
        'User authorizes transaction via OTP.',
        'Orange Money sends confirmation callback to backend.',
        'System updates payment status and returns final status.',
      ],
      keyCharacteristics: const [
        'OTP-based authorization',
        'Asynchronous callback confirmation',
        'Mobile wallet checkout experience',
      ],
      fields: const [
        _PaymentField(
          label: 'Wallet Number',
          value: '0787771234',
          icon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        _PaymentField(
          label: 'Provider',
          value: 'Orange Money',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _PaymentField(
          label: 'Authorization Type',
          value: 'OTP',
          icon: Icons.password_outlined,
        ),
        _PaymentField(
          label: 'Callback URL Alias',
          value: 'imseeh/orange-money/callback',
          icon: Icons.link_outlined,
        ),
      ],
    ),
    'Dinarak Wallet': _PaymentMethodConfig(
      purpose:
          'Process Dinarak wallet transactions with in-wallet confirmation and backend callback updates.',
      flowSteps: const [
        'System initiates payment request with Dinarak.',
        'User confirms payment within Dinarak wallet.',
        'Dinarak sends confirmation callback.',
        'System updates status and notifies user.',
      ],
      keyCharacteristics: const [
        'Wallet-native payment confirmation',
        'Provider callback status update',
        'Fast wallet transaction response',
      ],
      fields: const [
        _PaymentField(
          label: 'Wallet ID',
          value: 'DIN-442390',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _PaymentField(
          label: 'Registered Mobile Number',
          value: '0775559988',
          icon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
        ),
        _PaymentField(
          label: 'Provider',
          value: 'Dinarak',
          icon: Icons.wallet,
        ),
        _PaymentField(
          label: 'Callback URL Alias',
          value: 'imseeh/dinarak/callback',
          icon: Icons.link_outlined,
        ),
      ],
    ),
    'CliQ (Bank-to-Bank Instant)': _PaymentMethodConfig(
      purpose:
          'Enable instant bank-to-bank payments through CliQ with bank app confirmation.',
      flowSteps: const [
        'System initiates CliQ request via bank integration.',
        'User receives request in bank mobile app.',
        'User confirms payment in bank app.',
        'Bank sends instant payment confirmation to system.',
        'System updates payment status and returns result.',
      ],
      keyCharacteristics: const [
        'Near real-time settlement',
        'High trust and low failure rate',
        'Bank-controlled authentication',
      ],
      fields: const [
        _PaymentField(
          label: 'CliQ Alias',
          value: r'$ahmad.yaseen',
          icon: Icons.alternate_email,
        ),
        _PaymentField(
          label: 'Linked Bank Name',
          value: 'Jordan Islamic Bank',
          icon: Icons.account_balance_outlined,
        ),
        _PaymentField(
          label: 'Linked IBAN',
          value: 'JO94CBJO0010000000000131001',
          icon: Icons.credit_card_outlined,
        ),
        _PaymentField(
          label: 'Confirmation Channel',
          value: 'Bank Mobile App',
          icon: Icons.mobile_friendly_outlined,
        ),
      ],
    ),
  };

  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _setupControllersForSelectedMethod();
  }

  void _setupControllersForSelectedMethod() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers.clear();

    final fields = _methodConfigs[_selectedMethod]!.fields;
    _controllers.addAll(
      fields.map((field) => TextEditingController(text: field.value)),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment method configuration updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _methodConfigs[_selectedMethod]!;

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
                  title: 'Payment Method Selection',
                  subtitle:
                      'Choose preferred payment type, then configure integration-specific fields.',
                ),
                const SizedBox(height: 20),
                const SignupSectionLabel(label: 'PAYMENT TYPE'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _methodConfigs.keys
                      .map(
                        (method) => DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMethod = value;
                        _setupControllersForSelectedMethod();
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                _InfoBlock(title: 'Purpose', items: [config.purpose]),
                const SizedBox(height: 10),
                _InfoBlock(title: 'Flow', items: config.flowSteps),
                const SizedBox(height: 10),
                _InfoBlock(
                  title: 'Key Characteristics',
                  items: config.keyCharacteristics,
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.greyShade400),
                const SizedBox(height: 14),
                const SignupSectionLabel(label: 'METHOD FIELDS'),
                ...List.generate(config.fields.length, (index) {
                  final field = config.fields[index];
                  return AppTextField(
                    label: field.label,
                    hint: field.label,
                    prefixIcon: field.icon,
                    keyboardType: field.keyboardType,
                    controller: _controllers[index],
                    enabled: _isEditing,
                  );
                }),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _onSave,
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

class _PaymentField {
  final String label;
  final String value;
  final IconData icon;
  final TextInputType? keyboardType;

  const _PaymentField({
    required this.label,
    required this.value,
    required this.icon,
    this.keyboardType,
  });
}

class _PaymentMethodConfig {
  final String purpose;
  final List<String> flowSteps;
  final List<String> keyCharacteristics;
  final List<_PaymentField> fields;

  const _PaymentMethodConfig({
    required this.purpose,
    required this.flowSteps,
    required this.keyCharacteristics,
    required this.fields,
  });
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.luxuryIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $item',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.greyShade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
