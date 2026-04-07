import 'package:tpss_ecommerce_gold_wallet/features/transfer/domain/repositories/transfer_repository.dart';

class ValidateTransferUseCase {
  const ValidateTransferUseCase(this._repository);

  final ITransferRepository _repository;

  Future<String?> call({
    required double units,
    required double availableUnits,
    required String recipient,
    required bool requiresAccountVerification,
    required bool agreedToTerms,
  }) async {
    if (units <= 0) return 'Please enter a valid amount.';
    if (units > availableUnits) return 'Amount exceeds available balance.';
    if (recipient.isEmpty) return 'Please enter recipient account number.';

    if (requiresAccountVerification) {
      final exists = await _repository.isRegisteredAccount(recipient);
      if (!exists) return 'Recipient account must exist and be verified.';
    }

    if (!agreedToTerms) return 'Please agree to the terms and conditions.';
    return null;
  }
}
