import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/helpers/predefined_accounts_data.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';
import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/core/models/action_summary_model.dart';
import 'package:tpss_ecommerce_gold_wallet/core/services/action_summary_builder.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/domain/entities/checkout_route_args.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/data/datasources/profile_remote_datasource.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutPaymentType selectedPaymentType = CheckoutPaymentType.bank;
  bool otpConfirmed = false;
  List<PredefinedAccount> linkedBankAccounts = List<PredefinedAccount>.from(PredefinedAccountsData.bankAccounts);
  List<PredefinedAccount> predefinedPaymentMethods = List<PredefinedAccount>.from(PredefinedAccountsData.paymentMethods);
  int selectedBankIndex = 0;
  int selectedPaymentIndex = 0;
  ActionSummaryModel summary = ActionSummaryModel.zero;

  CheckoutCubit(this._dio)
      : _profileRemoteDataSource = ProfileRemoteDataSource(_dio),
        super(CheckoutInitial());

  final Dio _dio;
  final ProfileRemoteDataSource _profileRemoteDataSource;

  Future<void> load({ActionSummaryModel? initialSummary}) async {
    if (initialSummary != null) {
      summary = initialSummary;
    }
    await _syncProfilePaymentOptions();
    _emitDataChanged();
  }

  void selectPaymentType(CheckoutPaymentType type) {
    selectedPaymentType = type;
    _emitDataChanged();
  }

  void selectBankIndex(int index) {
    if (index < 0 || index >= linkedBankAccounts.length) return;
    selectedBankIndex = index;
    _emitDataChanged();
  }

  void selectPaymentIndex(int index) {
    if (index < 0 || index >= predefinedPaymentMethods.length) return;
    selectedPaymentIndex = index;
    _emitDataChanged();
  }

  Future<void> loadPreview({required CheckoutRouteArgs checkoutArgs}) async {
    final userId = AuthSessionStore.userId;
    if (userId == null) return;

    final validationError = checkoutArgs.validate();
    if (validationError != null) {
      _safeEmit(CheckoutError(validationError));
      return;
    }

    final fromCart = checkoutArgs.source == CheckoutSource.cart;
    try {
      final response = await _dio.post(
        '/wallet/actions/preview',
        data: {
          'userId': userId,
          'actionType': 'buy',
          'fromCart': fromCart,
          if (fromCart) 'productIds': checkoutArgs.productIds,
          if (!fromCart) 'productId': checkoutArgs.productId,
          if (!fromCart) 'quantity': checkoutArgs.quantity,
        },
      );

      final data =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>? ??
          {};
      summary = ActionSummaryBuilder.fromBackendData(data);
      _emitDataChanged();
    } catch (_) {
      // Keep initial summary fallback when preview API fails.
    }
  }

  Future<void> confirmOtp({
    required CheckoutRouteArgs checkoutArgs,
    String? otpVerificationToken,
    String? otpRequestId,
  }) async {
    emit(CheckoutLoading());
    try {
      final userId = AuthSessionStore.userId;
      if (userId == null) {
        _safeEmit(CheckoutError('No logged-in user.'));
        return;
      }

      final validationError = checkoutArgs.validate();
      if (validationError != null) {
        _safeEmit(CheckoutError(validationError));
        return;
      }
      final fromCart = checkoutArgs.source == CheckoutSource.cart;

      await _dio.post(
        '/checkout/confirm',
        data: {
          'userId': userId,
          'fromCart': fromCart,
          if (fromCart) 'productIds': checkoutArgs.productIds,
          if (!fromCart) 'productId': checkoutArgs.productId,
          if (!fromCart) 'quantity': checkoutArgs.quantity,
          if (otpVerificationToken != null && otpVerificationToken.trim().isNotEmpty) 'otpVerificationToken': otpVerificationToken.trim(),
          if (otpRequestId != null && otpRequestId.trim().isNotEmpty) 'otpRequestId': otpRequestId.trim(),
        },
      );

      otpConfirmed = true;
      _safeEmit(CheckoutSuccess());
      _emitDataChanged();
    } on DioException catch (e) {
      _safeEmit(
        CheckoutError(
          ApiErrorParser.friendlyMessage(
            e,
            fallback: 'Checkout failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      _safeEmit(CheckoutError('Checkout could not be completed. Please try again.'));
    }
  }

  Future<void> _syncProfilePaymentOptions() async {
    try {
      final profile = await _profileRemoteDataSource.getProfile();
      final banks = profile.linkedBankAccounts
          .map(
            (bank) => PredefinedAccount(
              id: 'bank_${bank.id}',
              name: bank.bankName.trim().isNotEmpty ? bank.bankName.trim() : 'Linked Bank ${bank.id}',
              subtitle: bank.ibanMasked.trim().isNotEmpty ? bank.ibanMasked.trim() : bank.accountNumber.trim(),
            ),
          )
          .toList();
      final cards = profile.paymentMethods
          .map(
            (payment) => PredefinedAccount(
              id: 'payment_${payment.id}',
              name: payment.type.trim().isNotEmpty ? payment.type.trim() : 'Payment Method ${payment.id}',
              subtitle: payment.maskedNumber.trim().isNotEmpty ? payment.maskedNumber.trim() : payment.holderName.trim(),
            ),
          )
          .toList();

      linkedBankAccounts = banks.isEmpty
          ? [const PredefinedAccount(id: 'bank_none', name: 'No linked bank account', subtitle: 'Add one in Profile')]
          : banks;
      predefinedPaymentMethods = cards.isEmpty
          ? [const PredefinedAccount(id: 'payment_none', name: 'No saved card/payment method', subtitle: 'Add one in Profile')]
          : cards;

      final defaultBankIndex = profile.linkedBankAccounts.indexWhere((x) => x.isDefault);
      final defaultCardIndex = profile.paymentMethods.indexWhere((x) => x.isDefault);
      selectedBankIndex = defaultBankIndex >= 0 && defaultBankIndex < linkedBankAccounts.length ? defaultBankIndex : 0;
      selectedPaymentIndex = defaultCardIndex >= 0 && defaultCardIndex < predefinedPaymentMethods.length ? defaultCardIndex : 0;
    } catch (_) {
      // Keep fallback predefined lists when profile endpoint fails.
    }
  }

  void _emitDataChanged() {
    _safeEmit(
      CheckoutDataChanged(
        selectedPaymentType: selectedPaymentType,
        otpConfirmed: otpConfirmed,
        linkedBankAccounts: linkedBankAccounts,
        predefinedPaymentMethods: predefinedPaymentMethods,
        selectedBankIndex: selectedBankIndex,
        selectedPaymentIndex: selectedPaymentIndex,
      ),
    );
  }

  void _safeEmit(CheckoutState state) {
    if (isClosed) return;
    emit(state);
  }
}
