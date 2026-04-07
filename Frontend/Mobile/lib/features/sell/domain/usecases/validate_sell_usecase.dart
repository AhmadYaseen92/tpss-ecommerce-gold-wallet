class ValidateSellUseCase {
  const ValidateSellUseCase();

  String? call({
    required double units,
    required bool agreedToTerms,
  }) {
    if (units <= 0) {
      return 'Enter a valid amount before confirming.';
    }
    if (!agreedToTerms) {
      return 'Please agree to Terms & Conditions first.';
    }
    return null;
  }
}
