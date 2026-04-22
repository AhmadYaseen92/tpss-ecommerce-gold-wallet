import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/entities/sell_asset_entities.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/domain/repositories/wallet_action_repository.dart';

part 'sell_asset_action_state.dart';

class SellAssetActionCubit extends Cubit<SellAssetActionState> {
  SellAssetActionCubit({
    required this.initialAsset,
    required IWalletActionRepository repository,
    ProfileRemoteDataSource? profileRemoteDataSource,
  }) : _repository = repository,
       _profileRemoteDataSource = profileRemoteDataSource ?? ProfileRemoteDataSource(InjectionContainer.dio()),
       quantityController = TextEditingController(text: '1'),
       noteController = TextEditingController(),
       super(SellAssetActionInitial()) {
    quantityController.addListener(_emitUpdated);
    _emitUpdated();
    _loadProfilePayoutOptions();
  }

  final WalletActionSummary initialAsset;
  final IWalletActionRepository _repository;
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final TextEditingController quantityController;
  final TextEditingController noteController;

  String payoutMethod = 'Bank Account';
  int selectedBankAccountIndex = 0;
  int selectedPaymentMethodIndex = 0;

  List<PredefinedAccount> _profileBankAccounts = List<PredefinedAccount>.from(PredefinedAccountsData.bankAccounts);
  List<PredefinedAccount> _profilePaymentMethods = List<PredefinedAccount>.from(PredefinedAccountsData.paymentMethods);

  List<PredefinedAccount> get predefinedBankAccounts => _profileBankAccounts;
  List<PredefinedAccount> get predefinedPaymentMethods => _profilePaymentMethods;

  int get maxQuantity => initialAsset.asset.quantity;

  double get unitPrice => _parseCurrency(initialAsset.asset.marketValue) / maxQuantity;

  int get quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > maxQuantity) return maxQuantity;
    return parsed;
  }

  bool get isBankPayout => payoutMethod == 'Bank Account';
  bool get isPaymentMethodPayout => payoutMethod == 'Payment Method';

  SellAssetResultEntity? get calculatedResult {
    final current = state;
    if (current is SellAssetActionUpdated) return current.result;
    return null;
  }

  String? get errorMessage {
    final current = state;
    if (current is SellAssetActionUpdated) return current.errorMessage;
    return null;
  }

  String formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  String? validateQuantity(String? value) {
    final qty = int.tryParse((value ?? '').trim());
    if (qty == null) return 'Please enter a valid number';
    if (qty < 1) return 'Quantity must be at least 1';
    if (qty > maxQuantity) return 'Quantity cannot exceed $maxQuantity';
    return null;
  }

  void updatePayoutMethod(String? value) {
    if (value == null) return;
    payoutMethod = value;
    if (isBankPayout && selectedBankAccountIndex >= predefinedBankAccounts.length) {
      selectedBankAccountIndex = 0;
    }
    if (isPaymentMethodPayout && selectedPaymentMethodIndex >= predefinedPaymentMethods.length) {
      selectedPaymentMethodIndex = 0;
    }
    _emitUpdated();
  }

  void updateBankAccount(int? index) {
    if (index == null) return;
    selectedBankAccountIndex = index;
    _emitUpdated();
  }

  void updatePaymentMethod(int? index) {
    if (index == null) return;
    selectedPaymentMethodIndex = index;
    _emitUpdated();
  }

  Future<void> _emitUpdated() async {
    try {
      final marketOpen = await _repository.isMarketOpen();
      final liquidity = await _repository.availableLiquidity();
      final lockedPrice = await _repository.lockUnitPrice(unitPrice);
      final quantityToSell = quantity;
      final requestedWeight = maxQuantity == 0 ? 0.0 : (initialAsset.asset.weightInGrams / maxQuantity) * quantityToSell;
      final grossAmount = unitPrice * quantityToSell;
      final preview = await _repository.previewWalletAction(
        actionType: WalletActionType.sell,
        walletAssetId: initialAsset.asset.id,
        quantity: quantityToSell,
        unitPrice: unitPrice,
        weight: requestedWeight,
        amount: grossAmount,
      );

      final result = SellAssetResultEntity(
        quantity: quantityToSell,
        grossAmount: preview.subTotalAmount,
        feeAmount: preview.totalFeesAmount - preview.discountAmount,
        receivedAmount: preview.finalAmount,
        lockedUnitPrice: lockedPrice,
      );

      emit(SellAssetActionUpdated(result: result, preview: preview));
    } catch (e) {
      emit(SellAssetActionUpdated(result: null, errorMessage: e.toString()));
    }
  }

  Future<void> _loadProfilePayoutOptions() async {
    try {
      final profile = await _profileRemoteDataSource.getProfile();
      final linkedBanks = profile.linkedBankAccounts
          .map(
            (bank) => PredefinedAccount(
              id: 'bank_${bank.id}',
              name: bank.bankName.trim().isEmpty ? 'Linked Bank ${bank.id}' : bank.bankName.trim(),
              subtitle: bank.ibanMasked.trim().isNotEmpty
                  ? bank.ibanMasked.trim()
                  : bank.accountNumber.trim(),
            ),
          )
          .toList();
      final paymentMethods = profile.paymentMethods
          .map(
            (payment) => PredefinedAccount(
              id: 'payment_${payment.id}',
              name: payment.type.trim().isEmpty ? 'Payment ${payment.id}' : payment.type.trim(),
              subtitle: payment.maskedNumber.trim().isNotEmpty
                  ? payment.maskedNumber.trim()
                  : payment.holderName.trim(),
            ),
          )
          .toList();

      _profileBankAccounts = linkedBanks.isEmpty
          ? [const PredefinedAccount(id: 'bank_none', name: 'No linked bank account', subtitle: 'Add one in Profile')]
          : linkedBanks;
      _profilePaymentMethods = paymentMethods.isEmpty
          ? [const PredefinedAccount(id: 'payment_none', name: 'No payment method', subtitle: 'Add one in Profile')]
          : paymentMethods;

      selectedBankAccountIndex = _defaultIndex(_profileBankAccounts, profile.linkedBankAccounts.indexWhere((x) => x.isDefault));
      selectedPaymentMethodIndex = _defaultIndex(_profilePaymentMethods, profile.paymentMethods.indexWhere((x) => x.isDefault));

      if (_isPlaceholderSelection(_profileBankAccounts[selectedBankAccountIndex]) &&
          !_isPlaceholderSelection(_profilePaymentMethods[selectedPaymentMethodIndex])) {
        payoutMethod = 'Payment Method';
      } else if (!_isPlaceholderSelection(_profileBankAccounts[selectedBankAccountIndex])) {
        payoutMethod = 'Bank Account';
      }
    } catch (_) {
      // Keep fallback predefined values if profile call fails.
    } finally {
      if (!isClosed) {
        _emitUpdated();
      }
    }
  }

  WalletActionSummary buildSummary() {
    final result = calculatedResult;
    if (result == null) {
      throw Exception(errorMessage ?? 'Unable to prepare sell summary.');
    }

    final payout = isBankPayout
        ? 'Bank - ${predefinedBankAccounts[selectedBankAccountIndex].name}'
        : 'Payment - ${predefinedPaymentMethods[selectedPaymentMethodIndex].name}';

    return WalletActionSummary(
      asset: initialAsset.asset,
      actionType: WalletActionType.sell,
      title: 'Sell Asset',
      primaryValue: '${result.quantity} Units',
      feeValue: formatCurrency(result.feeAmount),
      totalValue: formatCurrency(result.receivedAmount),
      preview: state is SellAssetActionUpdated ? (state as SellAssetActionUpdated).preview : null,
      destinationLabel: 'Payout Method',
      destinationValue: payout,
      note: noteController.text.trim(),
      referenceNumber: 'SELL-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      isPending: true,
    );
  }

  int _defaultIndex(List<PredefinedAccount> accounts, int remoteDefaultIndex) {
    if (accounts.isEmpty) return 0;
    if (remoteDefaultIndex >= 0 && remoteDefaultIndex < accounts.length) return remoteDefaultIndex;
    return 0;
  }

  bool _isPlaceholderSelection(PredefinedAccount account) =>
      account.id.endsWith('_none');

  double _parseCurrency(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0;
  }

  @override
  Future<void> close() {
    quantityController.dispose();
    noteController.dispose();
    return super.close();
  }
}
