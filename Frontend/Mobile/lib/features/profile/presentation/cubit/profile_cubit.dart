import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/data/datasources/profile_remote_datasource.dart';

part 'profile_state.dart';

class ProfileField {
  const ProfileField(this.label, this.icon, [this.keyboardType]);

  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
}

class ProfileOption {
  const ProfileOption({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.fields,
    this.isDefault = false,
    this.remoteId,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final List<ProfileField> fields;
  final bool isDefault;
  final int? remoteId;
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({ProfileRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(InjectionContainer.dio()),
      super(ProfileInitial()) {
    _initializeControllers();
    loadProfile();
  }

  final ProfileRemoteDataSource _remoteDataSource;

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

  String profileDisplayName = '';
  String profileDisplayEmail = '';
  String profileDisplayPhone = '';
  String profilePhotoUrl = '';

  List<ProfileOption> paymentMethods = [];
  final List<String> availablePaymentTypes = const [
    'Visa / MasterCard',
    'Apple Pay',
    'ZainCash',
    'Orange Money',
    'Dinarak',
    'CliQ',
  ];

  List<ProfileOption> bankAccounts = [];

  void _initializeControllers() {
    personalControllers.addAll({
      'First Name': TextEditingController(),
      'Middle Name': TextEditingController(),
      'Last Name': TextEditingController(),
      'Email Address': TextEditingController(),
      'Phone Number': TextEditingController(),
      'Date of Birth': TextEditingController(),
      'ID Number': TextEditingController(),
    });

    securityControllers.addAll({
      'Current Password': TextEditingController(),
      'New Password': TextEditingController(),
      'Confirm New Password': TextEditingController(),
    });

    _rebuildPaymentControllers(selectedPaymentIndex);
    _rebuildBankControllers(selectedBankIndex);
  }

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _remoteDataSource.getProfile();
      profileDisplayName = profile.fullName;
      profileDisplayEmail = profile.email;
      profileDisplayPhone = profile.phoneNumber ?? '';
      profilePhotoUrl = profile.profilePhotoUrl;

      _setNameControllers(profile.fullName);
      personalControllers['Email Address']?.text = profile.email;
      personalControllers['Phone Number']?.text = profile.phoneNumber ?? '';
      personalControllers['Date of Birth']?.text = _uiDateFromIso(profile.dateOfBirth);
      personalControllers['ID Number']?.text = profile.idNumber;

      selectedNationality = profile.nationality.isNotEmpty ? profile.nationality : selectedNationality;
      selectedDocumentType = profile.documentType.isNotEmpty ? profile.documentType : selectedDocumentType;
      selectedLanguage = _uiLanguageFromCode(profile.preferredLanguage);
      selectedTheme = _uiThemeFromCode(profile.preferredTheme);

      paymentMethods = profile.paymentMethods
          .map(
            (item) => ProfileOption(
              remoteId: item.id,
              name: item.type,
              subtitle: item.isDefault ? 'Default' : 'Saved method',
              icon: _paymentIconByType(item.type),
              fields: _paymentFieldsByType(item.type),
              isDefault: item.isDefault,
            ),
          )
          .toList();

      bankAccounts = profile.linkedBankAccounts
          .map(
            (item) => ProfileOption(
              remoteId: item.id,
              name: item.bankName,
              subtitle: item.isDefault
                  ? 'Default • ${item.isVerified ? 'Verified' : 'Unverified'}'
                  : (item.isVerified ? 'Verified' : 'Unverified'),
              icon: Icons.account_balance_outlined,
              fields: const [
                ProfileField('Account Holder Name', Icons.person_outline),
                ProfileField('Bank Name', Icons.account_balance_outlined),
                ProfileField('Account Number', Icons.numbers_outlined, TextInputType.number),
                ProfileField('IBAN', Icons.credit_card_outlined),
                ProfileField('SWIFT/BIC', Icons.verified_user_outlined),
                ProfileField('Branch Name', Icons.store_outlined),
                ProfileField('Branch Address', Icons.location_on_outlined),
                ProfileField('Country', Icons.flag_outlined),
                ProfileField('City', Icons.location_city_outlined),
                ProfileField('Currency', Icons.currency_exchange_outlined),
              ],
              isDefault: item.isDefault,
            ),
          )
          .toList();

      selectedNationality = normalizeNationalityValue(selectedNationality);
      selectedPaymentIndex = _resolveDefaultPaymentIndex(profile);
      selectedBankIndex = _resolveDefaultBankIndex(profile);
      _rebuildPaymentControllers(selectedPaymentIndex, profile: profile);
      _rebuildBankControllers(selectedBankIndex, profile: profile);

      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> savePersonalInfo() async {
    try {
      final fullName = _composeFullName();
      final email = personalControllers['Email Address']?.text.trim() ?? '';
      final phone = personalControllers['Phone Number']?.text.trim() ?? '';
      final dateOfBirth = personalControllers['Date of Birth']?.text.trim() ?? '';
      final idNumber = personalControllers['ID Number']?.text.trim() ?? '';

      if (fullName.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          dateOfBirth.isEmpty ||
          selectedNationality.trim().isEmpty ||
          selectedDocumentType.trim().isEmpty ||
          idNumber.isEmpty) {
        emit(ProfileError('Please complete all mandatory personal information fields.'));
        return;
      }
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        emit(ProfileError('Please enter a valid email address.'));
        return;
      }
      if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(phone)) {
        emit(ProfileError('Phone number must be 8-15 digits.'));
        return;
      }
      if (!RegExp(r'^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/[0-9]{4}$').hasMatch(dateOfBirth)) {
        emit(ProfileError('Date of birth must be in dd/mm/yyyy format.'));
        return;
      }
      if (!RegExp(r'^[A-Za-z0-9-]{4,30}$').hasMatch(idNumber)) {
        emit(ProfileError('ID Number format is invalid.'));
        return;
      }

      await _remoteDataSource.updatePersonal(
        fullName: fullName,
        email: email,
        phoneNumber: phone,
        dateOfBirthIso: _isoDateFromUi(dateOfBirth),
        nationality: selectedNationality,
        documentType: selectedDocumentType,
        idNumber: idNumber,
        profilePhotoUrl: profilePhotoUrl,
      );

      final emailChanged = email.isNotEmpty && email != profileDisplayEmail;
      isEditing = false;
      if (emailChanged) {
        emit(ProfileEmailChangedRequiresRelogin(newEmail: email));
      } else {
        emit(ProfileSaved());
        await loadProfile();
      }
    } catch (e) {
      emit(ProfileError('Failed to save personal info: $e'));
    }
  }

  Future<void> saveLanguageSettings() async {
    try {
      await _remoteDataSource.updateSettings(
        preferredLanguage: _languageCodeFromUi(selectedLanguage),
        preferredTheme: _themeCodeFromUi(selectedTheme),
      );
      isEditing = false;
      emit(ProfileSaved());
    } catch (e) {
      emit(ProfileError('Failed to save language settings: $e'));
    }
  }

  Future<void> saveThemeSettings() async {
    try {
      await _remoteDataSource.updateSettings(
        preferredLanguage: _languageCodeFromUi(selectedLanguage),
        preferredTheme: _themeCodeFromUi(selectedTheme),
      );
      isEditing = false;
      emit(ProfileSaved());
      await loadProfile();
    } catch (e) {
      emit(ProfileError('Failed to save theme settings: $e'));
    }
  }

  Future<void> savePaymentMethod() async {
    try {
      if (paymentMethods.isEmpty) {
        emit(ProfileError('Please add a payment method first.'));
        return;
      }
      final selected = paymentMethods[selectedPaymentIndex];
      final validationError = _validatePaymentMethod(selected.name);
      if (validationError != null) {
        emit(ProfileError(validationError));
        return;
      }
      await _remoteDataSource.upsertPaymentMethod(
        paymentMethodId: selected.remoteId,
        type: selected.name,
        maskedNumber: paymentControllers[0].text.trim(),
        holderName: paymentControllers.length > 1 ? paymentControllers[1].text.trim() : '',
        expiry: paymentControllers.length > 2 ? paymentControllers[2].text.trim() : '',
        cardNumber: _isCardType(selected.name) ? paymentControllers[0].text.trim() : '',
        applePayToken: _isApplePayType(selected.name) ? paymentControllers[0].text.trim() : '',
        walletProvider: _isWalletType(selected.name) ? selected.name : '',
        walletNumber: _isWalletType(selected.name) ? paymentControllers[0].text.trim() : '',
        cliqAlias: _isCliqType(selected.name) ? paymentControllers[0].text.trim() : '',
        cliqBankName: _isCliqType(selected.name) && paymentControllers.length > 2 ? paymentControllers[2].text.trim() : '',
        isDefault: selected.isDefault,
      );
      isEditing = false;
      emit(ProfileSaved());
      await loadProfile();
    } catch (e) {
      emit(ProfileError('Failed to save payment method: $e'));
    }
  }

  Future<void> saveLinkedBank() async {
    try {
      final bankValidationError = _validateBankDetails();
      if (bankValidationError != null) {
        emit(ProfileError(bankValidationError));
        return;
      }

      final selected = bankAccounts[selectedBankIndex];
      await _remoteDataSource.upsertLinkedBankAccount(
        linkedBankAccountId: selected.remoteId,
        bankName: bankControllers[1].text.trim(),
        ibanMasked: bankControllers[3].text.trim().toUpperCase(),
        isVerified: true,
        isDefault: selected.isDefault,
        accountHolderName: bankControllers[0].text.trim(),
        accountNumber: bankControllers[2].text.trim(),
        swiftCode: bankControllers[4].text.trim().toUpperCase(),
        branchName: bankControllers[5].text.trim(),
        branchAddress: bankControllers[6].text.trim(),
        country: bankControllers[7].text.trim(),
        city: bankControllers[8].text.trim(),
        currency: bankControllers[9].text.trim().toUpperCase(),
      );
      isEditing = false;
      emit(ProfileSaved());
      await loadProfile();
    } catch (e) {
      emit(ProfileError('Failed to save linked bank account: $e'));
    }
  }

  Future<void> saveSecuritySettings() async {
    final currentPassword = securityControllers['Current Password']?.text.trim() ?? '';
    final newPassword = securityControllers['New Password']?.text.trim() ?? '';
    final confirmPassword = securityControllers['Confirm New Password']?.text.trim() ?? '';

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      emit(ProfileError('Please fill all password fields.'));
      return;
    }

    if (newPassword != confirmPassword) {
      emit(ProfileError('New password and confirm password do not match.'));
      return;
    }
    if (newPassword.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(newPassword) ||
        !RegExp(r'[a-z]').hasMatch(newPassword) ||
        !RegExp(r'[0-9]').hasMatch(newPassword) ||
        !RegExp(r'[^A-Za-z0-9]').hasMatch(newPassword)) {
      emit(
        ProfileError(
          'Password must be at least 8 chars and include upper, lower, number, and special character.',
        ),
      );
      return;
    }

    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      securityControllers['Current Password']?.clear();
      securityControllers['New Password']?.clear();
      securityControllers['Confirm New Password']?.clear();
      isEditing = false;
      emit(ProfileSaved());
    } catch (e) {
      emit(ProfileError('Failed to update security settings: $e'));
    }
  }

  void toggleEdit() {
    isEditing = !isEditing;
    emit(ProfileEditingChanged(isEditing: isEditing));
  }

  void selectPaymentMethod(int index) {
    if (paymentMethods.isEmpty || index < 0 || index >= paymentMethods.length) return;
    selectedPaymentIndex = index;
    _rebuildPaymentControllers(index);
    emit(ProfilePaymentMethodChanged(selectedIndex: index));
  }

  void selectBankAccount(int index) {
    if (bankAccounts.isEmpty || index < 0 || index >= bankAccounts.length) return;
    selectedBankIndex = index;
    _rebuildBankControllers(index);
    emit(ProfileBankAccountChanged(selectedIndex: index));
  }

  void addPaymentMethod() {
    paymentMethods = [
      ...paymentMethods,
      ProfileOption(
        name: availablePaymentTypes.first,
        subtitle: 'New method',
        icon: _paymentIconByType(availablePaymentTypes.first),
        fields: _paymentFieldsByType(availablePaymentTypes.first),
        isDefault: paymentMethods.isEmpty,
      ),
    ];
    selectedPaymentIndex = paymentMethods.length - 1;
    _rebuildPaymentControllers(selectedPaymentIndex);
    emit(ProfilePaymentMethodChanged(selectedIndex: selectedPaymentIndex));
  }

  void addBankAccount() {
    bankAccounts = [
      ...bankAccounts,
      const ProfileOption(
        name: 'New Bank',
        subtitle: 'Unverified',
        icon: Icons.account_balance_outlined,
        fields: [
          ProfileField('Account Holder Name', Icons.person_outline),
          ProfileField('Bank Name', Icons.account_balance_outlined),
          ProfileField('Account Number', Icons.numbers_outlined, TextInputType.number),
          ProfileField('IBAN', Icons.credit_card_outlined),
          ProfileField('SWIFT/BIC', Icons.verified_user_outlined),
          ProfileField('Branch Name', Icons.store_outlined),
          ProfileField('Branch Address', Icons.location_on_outlined),
          ProfileField('Country', Icons.flag_outlined),
          ProfileField('City', Icons.location_city_outlined),
          ProfileField('Currency', Icons.currency_exchange_outlined),
        ],
        isDefault: false,
      ),
    ];
    selectedBankIndex = bankAccounts.length - 1;
    _rebuildBankControllers(selectedBankIndex);
    emit(ProfileBankAccountChanged(selectedIndex: selectedBankIndex));
  }

  void updateSelectedPaymentType(String type) {
    if (paymentMethods.isEmpty || selectedPaymentIndex >= paymentMethods.length) return;
    final current = paymentMethods[selectedPaymentIndex];
    paymentMethods[selectedPaymentIndex] = ProfileOption(
      remoteId: current.remoteId,
      name: type,
      subtitle: current.isDefault ? 'Default' : current.subtitle,
      icon: _paymentIconByType(type),
      fields: _paymentFieldsByType(type),
      isDefault: current.isDefault,
    );
    _rebuildPaymentControllers(selectedPaymentIndex);
    emit(ProfilePaymentMethodChanged(selectedIndex: selectedPaymentIndex));
  }

  void toggleSelectedPaymentDefault(bool value) {
    if (paymentMethods.isEmpty) return;
    paymentMethods = [
      for (var i = 0; i < paymentMethods.length; i++)
        ProfileOption(
          remoteId: paymentMethods[i].remoteId,
          name: paymentMethods[i].name,
          subtitle: i == selectedPaymentIndex && value ? 'Default' : 'Saved method',
          icon: paymentMethods[i].icon,
          fields: paymentMethods[i].fields,
          isDefault: i == selectedPaymentIndex ? value : false,
        ),
    ];
    emit(ProfilePaymentMethodChanged(selectedIndex: selectedPaymentIndex));
  }

  void toggleSelectedBankDefault(bool value) {
    if (bankAccounts.isEmpty) return;
    bankAccounts = [
      for (var i = 0; i < bankAccounts.length; i++)
        ProfileOption(
          remoteId: bankAccounts[i].remoteId,
          name: bankAccounts[i].name,
          subtitle: i == selectedBankIndex && value ? 'Default • Verified' : 'Verified',
          icon: bankAccounts[i].icon,
          fields: bankAccounts[i].fields,
          isDefault: i == selectedBankIndex ? value : false,
        ),
    ];
    emit(ProfileBankAccountChanged(selectedIndex: selectedBankIndex));
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

  void _setNameControllers(String fullName) {
    final parts = fullName.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    personalControllers['First Name']?.text = parts.isNotEmpty ? parts.first : '';
    personalControllers['Middle Name']?.text = parts.length > 2 ? parts.sublist(1, parts.length - 1).join(' ') : '';
    personalControllers['Last Name']?.text = parts.length > 1 ? parts.last : '';
  }

  String _composeFullName() {
    final firstName = personalControllers['First Name']?.text.trim() ?? '';
    final middleName = personalControllers['Middle Name']?.text.trim() ?? '';
    final lastName = personalControllers['Last Name']?.text.trim() ?? '';
    return [firstName, middleName, lastName].where((part) => part.isNotEmpty).join(' ');
  }

  String _uiDateFromIso(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final split = iso.split('-');
    if (split.length != 3) return '';
    return '${split[2]}/${split[1]}/${split[0]}';
  }

  String? _isoDateFromUi(String uiValue) {
    final clean = uiValue.trim();
    if (clean.isEmpty) return null;
    final split = clean.split('/');
    if (split.length != 3) return null;
    return '${split[2]}-${split[1].padLeft(2, '0')}-${split[0].padLeft(2, '0')}';
  }

  String _uiLanguageFromCode(String code) {
    switch (code.toLowerCase()) {
      case 'ar':
      case 'arabic':
        return 'العربية';
      case 'tr':
      case 'turkish':
        return 'Türkçe';
      default:
        return 'English';
    }
  }

  String _languageCodeFromUi(String value) {
    if (value == 'العربية') return 'ar';
    if (value == 'Türkçe') return 'tr';
    return 'en';
  }

  String _uiThemeFromCode(String code) {
    switch (code.toLowerCase()) {
      case 'dark':
        return 'Dark';
      case 'light':
        return 'Light';
      default:
        return 'System Default';
    }
  }

  String _themeCodeFromUi(String value) {
    if (value.toLowerCase().contains('dark')) return 'dark';
    if (value.toLowerCase().contains('light')) return 'light';
    return 'system';
  }

  void _rebuildPaymentControllers(int index, {ProfileRemoteModel? profile}) {
    for (final controller in paymentControllers) {
      controller.dispose();
    }
    paymentControllers.clear();

    String primary = '';
    String holder = '';
    String expiry = '';
    String details = '';
    if (profile != null && profile.paymentMethods.isNotEmpty && index < profile.paymentMethods.length) {
      final selected = profile.paymentMethods[index];
      primary = selected.maskedNumber;
      holder = selected.holderName;
      expiry = selected.expiry;
      if (_isCardType(selected.type)) {
        primary = selected.cardNumber;
      } else if (_isApplePayType(selected.type)) {
        primary = selected.applePayToken;
      } else if (_isWalletType(selected.type)) {
        primary = selected.walletNumber;
      } else if (_isCliqType(selected.type)) {
        primary = selected.cliqAlias;
        details = selected.cliqBankName;
      }
    }

    final selectedType = paymentMethods.isNotEmpty && index < paymentMethods.length
        ? paymentMethods[index].name
        : availablePaymentTypes.first;
    final fields = _paymentFieldsByType(selectedType);
    for (var i = 0; i < fields.length; i++) {
      String value = '';
      if (i == 0) value = primary;
      if (i == 1) value = holder;
      if (i == 2) {
        if (_isCardType(selectedType)) {
          value = expiry;
        } else if (_isCliqType(selectedType)) {
          value = details;
        }
      }
      paymentControllers.add(
        TextEditingController(text: value),
      );
    }
  }

  void _rebuildBankControllers(int index, {ProfileRemoteModel? profile}) {
    for (final controller in bankControllers) {
      controller.dispose();
    }
    bankControllers.clear();

    String accountHolderName = '';
    String bankName = '';
    String accountNumber = '';
    String iban = '';
    String swift = '';
    String branchName = '';
    String branchAddress = '';
    String country = '';
    String city = '';
    String currency = '';
    if (profile != null && profile.linkedBankAccounts.isNotEmpty && index < profile.linkedBankAccounts.length) {
      final selected = profile.linkedBankAccounts[index];
      accountHolderName = selected.accountHolderName;
      bankName = selected.bankName;
      accountNumber = selected.accountNumber;
      iban = selected.ibanMasked;
      swift = selected.swiftCode;
      branchName = selected.branchName;
      branchAddress = selected.branchAddress;
      country = selected.country;
      city = selected.city;
      currency = selected.currency;
    }

    bankControllers
      ..add(TextEditingController(text: accountHolderName))
      ..add(TextEditingController(text: bankName))
      ..add(TextEditingController(text: accountNumber))
      ..add(TextEditingController(text: iban))
      ..add(TextEditingController(text: swift))
      ..add(TextEditingController(text: branchName))
      ..add(TextEditingController(text: branchAddress))
      ..add(TextEditingController(text: country))
      ..add(TextEditingController(text: city))
      ..add(TextEditingController(text: currency));
  }

  static String normalizeNationalityValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'Unknown';
    return trimmed;
  }

  List<ProfileField> _paymentFieldsByType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('apple')) {
      return const [
        ProfileField('Apple Pay Token', Icons.token_outlined),
        ProfileField('Account Holder Name', Icons.person_outline),
      ];
    }
    if (normalized.contains('zain') || normalized.contains('orange') || normalized.contains('dinar')) {
      return const [
        ProfileField('Wallet Number', Icons.phone_android_outlined, TextInputType.phone),
        ProfileField('Account Holder Name', Icons.person_outline),
      ];
    }
    if (normalized.contains('cliq')) {
      return const [
        ProfileField('CliQ Alias', Icons.account_balance_outlined),
        ProfileField('Account Holder Name', Icons.person_outline),
        ProfileField('Bank Name', Icons.account_balance_outlined),
      ];
    }
    return const [
      ProfileField('Card Number', Icons.credit_card_outlined, TextInputType.number),
      ProfileField('Card Holder Name', Icons.person_outline),
      ProfileField('Expiry (MM/YY)', Icons.calendar_today_outlined, TextInputType.number),
    ];
  }

  IconData _paymentIconByType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('apple')) return Icons.phone_iphone;
    if (normalized.contains('zain') || normalized.contains('orange') || normalized.contains('dinar')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (normalized.contains('cliq')) return Icons.account_balance_outlined;
    return Icons.credit_card_outlined;
  }

  String? _validatePaymentMethod(String type) {
    for (final controller in paymentControllers) {
      if (controller.text.trim().isEmpty) {
        return 'All payment fields are required.';
      }
    }

    final primary = paymentControllers.first.text.trim();
    final normalized = type.toLowerCase();
    if (normalized.contains('visa') || normalized.contains('master')) {
      if (!RegExp(r'^[0-9]{12,19}$').hasMatch(primary)) {
        return 'Card number must be 12 to 19 digits.';
      }
      if (paymentControllers.length > 2 &&
          !RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(paymentControllers[2].text.trim())) {
        return 'Expiry must be in MM/YY format.';
      }
      return null;
    }
    if (normalized.contains('apple')) {
      if (!RegExp(r'^[A-Za-z0-9_\-]{8,64}$').hasMatch(primary)) {
        return 'Apple Pay token format is invalid.';
      }
      return null;
    }
    if (normalized.contains('zain') || normalized.contains('orange') || normalized.contains('dinar')) {
      if (!RegExp(r'^[+0-9]{8,15}$').hasMatch(primary)) {
        return 'Wallet number must be 8-15 digits.';
      }
      return null;
    }
    if (normalized.contains('cliq')) {
      if (!RegExp(r'^[A-Za-z0-9._-]{4,40}$').hasMatch(primary)) {
        return 'CliQ alias format is invalid.';
      }
      return null;
    }

    return null;
  }

  bool _isCardType(String type) {
    final normalized = type.toLowerCase();
    return normalized.contains('visa') || normalized.contains('master');
  }

  bool _isApplePayType(String type) => type.toLowerCase().contains('apple');
  bool _isWalletType(String type) {
    final normalized = type.toLowerCase();
    return normalized.contains('zain') || normalized.contains('orange') || normalized.contains('dinar');
  }

  bool _isCliqType(String type) => type.toLowerCase().contains('cliq');

  String? _validateBankDetails() {
    for (final controller in bankControllers) {
      if (controller.text.trim().isEmpty) return 'All linked bank account fields are required.';
    }

    final accountNumber = bankControllers[2].text.trim();
    final iban = bankControllers[3].text.trim();
    final swift = bankControllers[4].text.trim();

    if (!RegExp(r'^[0-9]{6,34}$').hasMatch(accountNumber)) {
      return 'Account number must be between 6 and 34 digits.';
    }
    if (!RegExp(r'^[A-Z]{2}[A-Z0-9]{13,32}$').hasMatch(iban)) {
      return 'IBAN format is invalid.';
    }
    if (!RegExp(r'^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$').hasMatch(swift)) {
      return 'SWIFT/BIC format is invalid.';
    }
    return null;
  }

  int _resolveDefaultPaymentIndex(ProfileRemoteModel profile) {
    if (profile.paymentMethods.isEmpty) return 0;
    final index = profile.paymentMethods.indexWhere((element) => element.isDefault);
    return index >= 0 ? index : 0;
  }

  int _resolveDefaultBankIndex(ProfileRemoteModel profile) {
    if (profile.linkedBankAccounts.isEmpty) return 0;
    final index = profile.linkedBankAccounts.indexWhere((element) => element.isDefault);
    return index >= 0 ? index : 0;
  }

  @override
  Future<void> close() {
    for (final controller in personalControllers.values) {
      controller.dispose();
    }
    for (final controller in securityControllers.values) {
      controller.dispose();
    }
    for (final controller in paymentControllers) {
      controller.dispose();
    }
    for (final controller in bankControllers) {
      controller.dispose();
    }
    return super.close();
  }
}
