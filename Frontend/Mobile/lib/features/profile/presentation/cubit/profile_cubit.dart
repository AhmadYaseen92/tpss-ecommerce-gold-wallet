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
    this.remoteId,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final List<ProfileField> fields;
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

      paymentMethods = profile.paymentMethods.isNotEmpty
          ? profile.paymentMethods
                .map(
                  (item) => ProfileOption(
                    remoteId: item.id,
                    name: item.type,
                    subtitle: item.isDefault ? 'Default' : 'Saved method',
                    icon: Icons.credit_card,
                    fields: const [ProfileField('Masked Number', Icons.credit_card)],
                  ),
                )
                .toList()
          : [];

      bankAccounts = profile.linkedBankAccounts.isNotEmpty
          ? profile.linkedBankAccounts
                .map(
                  (item) => ProfileOption(
                    remoteId: item.id,
                    name: item.bankName,
                    subtitle: item.isVerified ? 'Verified' : 'Unverified',
                    icon: Icons.account_balance_outlined,
                    fields: const [
                      ProfileField('Bank Name', Icons.account_balance_outlined),
                      ProfileField('IBAN', Icons.credit_card_outlined),
                    ],
                  ),
                )
                .toList()
          : [];

      selectedNationality = normalizeNationalityValue(selectedNationality);

      selectedPaymentIndex = 0;
      selectedBankIndex = 0;
      _rebuildPaymentControllers(selectedPaymentIndex, profile: profile);
      _rebuildBankControllers(selectedBankIndex, profile: profile);

      emit(ProfileLoaded());
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> savePersonalInfo() async {
    try {
      await _remoteDataSource.updatePersonal(
        fullName: _composeFullName(),
        phoneNumber: personalControllers['Phone Number']?.text.trim(),
        dateOfBirthIso: _isoDateFromUi(personalControllers['Date of Birth']?.text ?? ''),
        nationality: selectedNationality,
        documentType: selectedDocumentType,
        idNumber: personalControllers['ID Number']?.text.trim() ?? '',
        profilePhotoUrl: profilePhotoUrl,
      );
      isEditing = false;
      emit(ProfileSaved());
      await loadProfile();
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
      final selected = paymentMethods[selectedPaymentIndex];
      await _remoteDataSource.upsertPaymentMethod(
        paymentMethodId: selected.remoteId,
        type: selected.name,
        maskedNumber: paymentControllers.isNotEmpty ? paymentControllers.first.text.trim() : '',
        isDefault: selectedPaymentIndex == 0,
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
      final selected = bankAccounts[selectedBankIndex];
      await _remoteDataSource.upsertLinkedBankAccount(
        linkedBankAccountId: selected.remoteId,
        bankName: bankControllers.isNotEmpty ? bankControllers[0].text.trim() : selected.name,
        ibanMasked: bankControllers.length > 1 ? bankControllers[1].text.trim() : '',
        isVerified: true,
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

  void save() {
    isEditing = false;
    emit(ProfileSaved());
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
      const ProfileOption(
        name: 'Card',
        subtitle: 'New method',
        icon: Icons.credit_card,
        fields: [ProfileField('Masked Number', Icons.credit_card)],
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
          ProfileField('Bank Name', Icons.account_balance_outlined),
          ProfileField('IBAN', Icons.credit_card_outlined),
        ],
      ),
    ];
    selectedBankIndex = bankAccounts.length - 1;
    _rebuildBankControllers(selectedBankIndex);
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

    String defaultValue = '';
    if (profile != null && profile.paymentMethods.isNotEmpty && index < profile.paymentMethods.length) {
      defaultValue = profile.paymentMethods[index].maskedNumber;
    } else if (paymentMethods.isNotEmpty && index < paymentMethods.length && paymentMethods[index].fields.isNotEmpty) {
      defaultValue = '';
    }

    paymentControllers.add(TextEditingController(text: defaultValue));
  }

  void _rebuildBankControllers(int index, {ProfileRemoteModel? profile}) {
    for (final controller in bankControllers) {
      controller.dispose();
    }
    bankControllers.clear();

    String bankName = '';
    String iban = '';
    if (profile != null && profile.linkedBankAccounts.isNotEmpty && index < profile.linkedBankAccounts.length) {
      final selected = profile.linkedBankAccounts[index];
      bankName = selected.bankName;
      iban = selected.ibanMasked;
    }

    bankControllers
      ..add(TextEditingController(text: bankName))
      ..add(TextEditingController(text: iban));
  }

  static String normalizeNationalityValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return 'Unknown';
    return trimmed;
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
