import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet_action/data/models/wallet_action_models.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

part 'convert_asset_action_state.dart';

class ConvertAssetActionCubit extends Cubit<ConvertAssetActionState> {
  ConvertAssetActionCubit({
    required this.asset,
    ProfileRemoteDataSource? profileRemoteDataSource,
  })
    : quantityController = TextEditingController(text: '1'),
      walletAddressController = TextEditingController(),
      _profileRemoteDataSource = profileRemoteDataSource ?? ProfileRemoteDataSource(InjectionContainer.dio()),
      super(ConvertAssetActionInitial()) {
    quantityController.addListener(_emitUpdated);
    _loadProfileCashDestinations();
  }

  final WalletTransactionEntity asset;
  final ProfileRemoteDataSource _profileRemoteDataSource;

  final TextEditingController quantityController;
  final TextEditingController walletAddressController;

  ConvertTargetType targetType = ConvertTargetType.cash;
  String cashDestination = 'Wallet Cash';
  String cryptoType = 'USDT';
  List<String> cashDestinations = <String>['Wallet Cash', 'Bank Account'];

  int get maxQuantity => asset.quantity;
  double get unitPrice => asset.actionUnitPrice;

  int get quantity {
    final parsed = int.tryParse(quantityController.text.trim()) ?? 1;
    if (parsed < 1) return 1;
    if (parsed > maxQuantity) return maxQuantity;
    return parsed;
  }

  bool get isCrypto => targetType == ConvertTargetType.crypto;
  double get grossAmount => unitPrice * quantity;
  double get serviceFee => grossAmount * 0.005;
  double get networkFee => isCrypto ? 12 : 0;
  double get totalFee => serviceFee + networkFee;
  double get cashReceived => grossAmount - totalFee;

  double get cryptoReceived {
    final usd = cashReceived;
    final rate = _cryptoRate[cryptoType] ?? 1;
    return usd / rate;
  }

  Map<String, double> get _cryptoRate => {'USDT': 1, 'BTC': 69000, 'ETH': 3500};

  String formatCurrency(double value) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);

  String? validateQuantity(String? value) {
    final qty = int.tryParse((value ?? '').trim());
    if (qty == null) return 'Please enter a valid number';
    if (qty < 1) return 'Quantity must be at least 1';
    if (qty > maxQuantity) return 'Quantity cannot exceed $maxQuantity';
    return null;
  }

  String? validateWalletAddress(String? value) {
    if (isCrypto && (value ?? '').trim().isEmpty) {
      return 'Wallet address is required';
    }
    return null;
  }

  void updateTargetType(ConvertTargetType value) {
    targetType = value;
    _emitUpdated();
  }

  void updateCashDestination(String? value) {
    if (value == null) return;
    cashDestination = value;
    _emitUpdated();
  }

  void updateCryptoType(String? value) {
    if (value == null) return;
    cryptoType = value;
    _emitUpdated();
  }

  WalletActionSummary buildSummary() {
    return WalletActionSummary(
      asset: asset,
      actionType: isCrypto ? WalletActionType.convertToCrypto : WalletActionType.convertToCash,
      title: isCrypto ? 'Convert to Crypto' : 'Convert to Cash',
      primaryValue: '$quantity Units',
      summary: ActionSummaryBuilder.fromBackendData({
        'subTotalAmount': grossAmount,
        'totalFeesAmount': totalFee,
        'discountAmount': 0,
        'finalAmount': cashReceived,
        'currency': 'USD',
        'feeBreakdowns': const [],
      }),
      destinationLabel: isCrypto ? 'Wallet Address' : 'Cash Destination',
      destinationValue: isCrypto ? walletAddressController.text.trim() : cashDestination,
      note: isCrypto ? '$cryptoType conversion' : null,
      referenceNumber: 'CNV-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      isPending: true,
    );
  }

  Future<void> _loadProfileCashDestinations() async {
    try {
      final profile = await _profileRemoteDataSource.getProfile();
      final serverDestinations = <String>[
        'Wallet Cash',
        ...profile.linkedBankAccounts.map((x) => 'Bank - ${x.bankName}').toList(),
        ...profile.paymentMethods.map((x) => 'Payment - ${x.type}').toList(),
      ].toSet().toList();

      cashDestinations = serverDestinations;
      if (!cashDestinations.contains(cashDestination)) {
        cashDestination = cashDestinations.first;
      }
    } catch (_) {
      // Keep default destinations if profile call fails.
    } finally {
      if (!isClosed) {
        _emitUpdated();
      }
    }
  }

  void _emitUpdated() => emit(ConvertAssetActionUpdated());

  @override
  Future<void> close() {
    quantityController.dispose();
    walletAddressController.dispose();
    return super.close();
  }
}
