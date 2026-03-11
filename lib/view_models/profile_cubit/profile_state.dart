part of 'profile_cubit.dart';

class ProfileState {
  final bool isEditing;
  final int selectedPaymentIndex;
  final int selectedBankIndex;
  final String selectedBiometric;
  final String selectedLanguage;
  final String selectedTheme;
  final String selectedNationality;
  final String selectedDocumentType;

  const ProfileState({
    this.isEditing = false,
    this.selectedPaymentIndex = 0,
    this.selectedBankIndex = 0,
    this.selectedBiometric = 'Face ID',
    this.selectedLanguage = 'English',
    this.selectedTheme = 'System Default',
    this.selectedNationality = 'Jordanian',
    this.selectedDocumentType = 'National ID',
  });

  ProfileState copyWith({
    bool? isEditing,
    int? selectedPaymentIndex,
    int? selectedBankIndex,
    String? selectedBiometric,
    String? selectedLanguage,
    String? selectedTheme,
    String? selectedNationality,
    String? selectedDocumentType,
  }) {
    return ProfileState(
      isEditing: isEditing ?? this.isEditing,
      selectedPaymentIndex: selectedPaymentIndex ?? this.selectedPaymentIndex,
      selectedBankIndex: selectedBankIndex ?? this.selectedBankIndex,
      selectedBiometric: selectedBiometric ?? this.selectedBiometric,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedNationality: selectedNationality ?? this.selectedNationality,
      selectedDocumentType: selectedDocumentType ?? this.selectedDocumentType,
    );
  }
}
