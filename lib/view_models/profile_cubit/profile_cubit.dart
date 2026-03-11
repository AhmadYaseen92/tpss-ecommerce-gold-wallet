import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileField {
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const ProfileField(this.label, this.icon, [this.keyboardType]);
}

class ProfileOption {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<ProfileField> fields;

  const ProfileOption({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.fields,
  });
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial()) {
    _initializeControllers();
  }

  final Map<String, TextEditingController> personalControllers = {};
  final Map<String, TextEditingController> securityControllers = {};
  final List<TextEditingController> paymentControllers = [];
  final List<TextEditingController> bankControllers = [];

  bool isEditing = false;
  int selectedPaymentIndex = 0;
  int selectedBankIndex = 0;
  String selectedBiometric = 'Face ID';
  String selectedLanguage = 'English';
  String selectedTheme = 'System Default';
  String selectedNationality = 'Jordanian';
  String selectedDocumentType = 'National ID';

  final List<ProfileOption> paymentMethods = const [
    ProfileOption(
      name: 'Card Payment',
      subtitle: 'Visa / MasterCard',
      icon: Icons.credit_card,
      fields: [
        ProfileField('Card Holder Name', Icons.person_outline),
        ProfileField('Card Number', Icons.credit_card, TextInputType.number),
        ProfileField('Expiry Date', Icons.date_range_outlined),
        ProfileField('CVV', Icons.security, TextInputType.number),
        ProfileField('3DS Verification', Icons.password_outlined),
      ],
    ),
    ProfileOption(
      name: 'Apple Pay',
      subtitle: 'Face ID / Touch ID / Passcode',
      icon: Icons.phone_iphone_outlined,
      fields: [
        ProfileField('Apple ID Email', Icons.alternate_email, TextInputType.emailAddress),
        ProfileField('Device Name', Icons.devices_outlined),
        ProfileField('Authentication Method', Icons.face_retouching_natural),
        ProfileField('Token Provider', Icons.token_outlined),
      ],
    ),
    ProfileOption(
      name: 'ZainCash',
      subtitle: 'Wallet + OTP',
      icon: Icons.account_balance_wallet_outlined,
      fields: [
        ProfileField('Wallet Number', Icons.phone_android_outlined, TextInputType.phone),
        ProfileField('Provider Name', Icons.wallet),
        ProfileField('Authorization', Icons.password_outlined),
        ProfileField('Callback Endpoint', Icons.link_outlined),
      ],
    ),
    ProfileOption(
      name: 'Orange Money',
      subtitle: 'Wallet + OTP',
      icon: Icons.account_balance_wallet_outlined,
      fields: [
        ProfileField('Wallet Number', Icons.phone_android_outlined, TextInputType.phone),
        ProfileField('Provider Name', Icons.wallet),
        ProfileField('Authorization', Icons.password_outlined),
        ProfileField('Callback Endpoint', Icons.link_outlined),
      ],
    ),
    ProfileOption(
      name: 'Dinarak',
      subtitle: 'Wallet Confirmation',
      icon: Icons.account_balance_wallet_outlined,
      fields: [
        ProfileField('Wallet ID', Icons.badge_outlined),
        ProfileField('Registered Mobile', Icons.phone_android_outlined, TextInputType.phone),
        ProfileField('Provider Name', Icons.wallet),
        ProfileField('Callback Endpoint', Icons.link_outlined),
      ],
    ),
    ProfileOption(
      name: 'CliQ',
      subtitle: 'Bank-to-Bank Instant',
      icon: Icons.account_balance_outlined,
      fields: [
        ProfileField('CliQ Alias', Icons.alternate_email),
        ProfileField('Linked Bank', Icons.account_balance_outlined),
        ProfileField('Linked IBAN', Icons.credit_card_outlined),
        ProfileField('Confirmation Channel', Icons.mobile_friendly_outlined),
      ],
    ),
  ];

  final List<ProfileOption> bankAccounts = const [
    ProfileOption(
      name: 'Jordan Islamic Bank ••••6789',
      subtitle: 'Primary Account',
      icon: Icons.account_balance_outlined,
      fields: [
        ProfileField('Account Holder Name', Icons.badge_outlined),
        ProfileField('Bank Name', Icons.account_balance_outlined),
        ProfileField('IBAN', Icons.credit_card_outlined),
        ProfileField('SWIFT/BIC', Icons.qr_code_2_outlined),
      ],
    ),
    ProfileOption(
      name: 'Arab Bank ••••1140',
      subtitle: 'Secondary Account',
      icon: Icons.account_balance_outlined,
      fields: [
        ProfileField('Account Holder Name', Icons.badge_outlined),
        ProfileField('Bank Name', Icons.account_balance_outlined),
        ProfileField('IBAN', Icons.credit_card_outlined),
        ProfileField('SWIFT/BIC', Icons.qr_code_2_outlined),
      ],
    ),
  ];

  void _initializeControllers() {
    personalControllers.addAll({
      'First Name': TextEditingController(text: 'Ahmad'),
      'Middle Name': TextEditingController(text: 'Mohammad'),
      'Last Name': TextEditingController(text: 'Yaseen'),
      'Email Address': TextEditingController(text: 'ahmad.yaseen@tradepss.com'),
      'Phone Number': TextEditingController(text: '791234567'),
      'Date of Birth': TextEditingController(text: '12/05/1996'),
      'ID Number': TextEditingController(text: '9876543210'),
    });

    securityControllers.addAll({
      'Current Password': TextEditingController(text: '********'),
      'New Password': TextEditingController(text: '********'),
      'Confirm New Password': TextEditingController(text: '********'),
    });

    _rebuildPaymentControllers(selectedPaymentIndex);
    _rebuildBankControllers(selectedBankIndex);
  }

  void toggleEdit() {
    isEditing = !isEditing;
    emit(ProfileEditingChanged(isEditing: isEditing));
  }

  void save() {
    isEditing = false;
    emit(ProfileSaved());
  }

  void selectPaymentMethod(int index) {
    selectedPaymentIndex = index;
    _rebuildPaymentControllers(index);
    emit(ProfilePaymentMethodChanged(selectedIndex: index));
  }

  void selectBankAccount(int index) {
    selectedBankIndex = index;
    _rebuildBankControllers(index);
    emit(ProfileBankAccountChanged(selectedIndex: index));
  }

  void selectBiometric(String value) {
    selectedBiometric = value;
    emit(ProfileBiometricChanged(selectedBiometric: value));
  }

  void selectLanguage(String value) {
    selectedLanguage = value;
    emit(ProfileLanguageChanged(selectedLanguage: value));
  }

  void selectTheme(String value) {
    selectedTheme = value;
    emit(ProfileThemeChanged(selectedTheme: value));
  }

  void selectNationality(String value) {
    selectedNationality = value;
    emit(ProfileNationalityChanged(selectedNationality: value));
  }

  void selectDocumentType(String value) {
    selectedDocumentType = value;
    emit(ProfileDocumentTypeChanged(selectedDocumentType: value));
  }

  void _rebuildPaymentControllers(int index) {
    for (final c in paymentControllers) {
      c.dispose();
    }
    paymentControllers.clear();

    final defaults = <List<String>>[
      ['Ahmad Mohammad Yaseen', '4111 1111 1111 9281', '09/28', '***', 'OTP'],
      ['ahmad.yaseen@icloud.com', 'iPhone 15 Pro', 'Face ID', 'Apple Pay Token Service'],
      ['0791234567', 'ZainCash', 'OTP', 'imseeh/zaincash/callback'],
      ['0787771234', 'Orange Money', 'OTP', 'imseeh/orange-money/callback'],
      ['DIN-442390', '0775559988', 'Dinarak', 'imseeh/dinarak/callback'],
      [r'$ahmad.yaseen', 'Jordan Islamic Bank', 'JO94CBJO0010000000000131001', 'Bank Mobile App'],
    ];

    paymentControllers.addAll(
      defaults[index].map((value) => TextEditingController(text: value)),
    );
  }

  void _rebuildBankControllers(int index) {
    for (final c in bankControllers) {
      c.dispose();
    }
    bankControllers.clear();

    final defaults = <List<String>>[
      ['Ahmad Mohammad Yaseen', 'Jordan Islamic Bank', 'JO94CBJO0010000000000131001', 'JIBAJOAX'],
      ['Ahmad Mohammad Yaseen', 'Arab Bank', 'JO32ARAB0000000000011400045', 'ARABJOAXXXX'],
    ];

    bankControllers.addAll(
      defaults[index].map((value) => TextEditingController(text: value)),
    );
  }

  @override
  Future<void> close() {
    for (final c in personalControllers.values) {
      c.dispose();
    }
    for (final c in securityControllers.values) {
      c.dispose();
    }
    for (final c in paymentControllers) {
      c.dispose();
    }
    for (final c in bankControllers) {
      c.dispose();
    }
    return super.close();
  }
}
