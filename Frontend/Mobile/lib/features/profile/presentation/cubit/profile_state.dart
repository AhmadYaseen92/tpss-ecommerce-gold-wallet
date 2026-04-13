part of 'profile_cubit.dart';

class ProfileState {}

final class ProfileInitial extends ProfileState {}
final class ProfileLoading extends ProfileState {}
final class ProfileLoaded extends ProfileState {}

final class ProfileEditingChanged extends ProfileState {
  final bool isEditing;
  ProfileEditingChanged({required this.isEditing});
}

final class ProfilePaymentMethodChanged extends ProfileState {
  final int selectedIndex;
  ProfilePaymentMethodChanged({required this.selectedIndex});
}

final class ProfileBankAccountChanged extends ProfileState {
  final int selectedIndex;
  ProfileBankAccountChanged({required this.selectedIndex});
}

final class ProfileBiometricChanged extends ProfileState {
  final String selectedBiometric;
  ProfileBiometricChanged({required this.selectedBiometric});
}

final class ProfileLanguageChanged extends ProfileState {
  final String selectedLanguage;
  ProfileLanguageChanged({required this.selectedLanguage});
}

final class ProfileThemeChanged extends ProfileState {
  final String selectedTheme;
  ProfileThemeChanged({required this.selectedTheme});
}

final class ProfileNationalityChanged extends ProfileState {
  final String selectedNationality;
  ProfileNationalityChanged({required this.selectedNationality});
}

final class ProfileDocumentTypeChanged extends ProfileState {
  final String selectedDocumentType;
  ProfileDocumentTypeChanged({required this.selectedDocumentType});
}

final class ProfileSaved extends ProfileState {}

final class ProfileEmailChangedRequiresRelogin extends ProfileState {
  final String newEmail;
  ProfileEmailChangedRequiresRelogin({required this.newEmail});
}

final class ProfilePasswordChangedRequiresRelogin extends ProfileState {}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
