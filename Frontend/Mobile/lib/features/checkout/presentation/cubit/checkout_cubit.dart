import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/network/api_error_parser.dart';
import 'package:dio/dio.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutPaymentType selectedPaymentType = CheckoutPaymentType.bank;
  bool otpConfirmed = false;

  CheckoutCubit(this._dio) : super(CheckoutInitial());

  final Dio _dio;

  void load() {
    emit(
      CheckoutDataChanged(
        selectedPaymentType: selectedPaymentType,
        otpConfirmed: otpConfirmed,
      ),
    );
  }

  void selectPaymentType(CheckoutPaymentType type) {
    selectedPaymentType = type;
    emit(
      CheckoutDataChanged(
        selectedPaymentType: selectedPaymentType,
        otpConfirmed: otpConfirmed,
      ),
    );
  }

  Future<void> confirmOtp({required Map<String, dynamic> checkoutArgs}) async {
    emit(CheckoutLoading());
    try {
      final userId = AuthSessionStore.userId;
      if (userId == null) {
        emit(CheckoutError('No logged-in user.'));
        return;
      }

      final productIdRaw = checkoutArgs['productId'];
      final quantityRaw = checkoutArgs['quantity'];
      final productId = productIdRaw is num
          ? productIdRaw.toInt()
          : int.tryParse('$productIdRaw');
      final quantity = quantityRaw is num
          ? quantityRaw.toInt()
          : int.tryParse('$quantityRaw');
      final isDirectCheckout = productId != null && (quantity ?? 0) > 0;
      final fromCartRaw = checkoutArgs['fromCart'];
      final fromCart = fromCartRaw is bool
          ? fromCartRaw
          : (fromCartRaw is String
              ? fromCartRaw.toLowerCase() == 'true'
              : !isDirectCheckout);
      final productIdsRaw = checkoutArgs['productIds'];
      final productIds = productIdsRaw is List
          ? productIdsRaw
                .map((e) => e is num ? e.toInt() : int.tryParse('$e'))
                .whereType<int>()
                .toList()
          : <int>[];

      if (fromCart && productIds.isEmpty) {
        emit(
          CheckoutError(
            'No cart items were selected. Please select items and try again.',
          ),
        );
        return;
      }

      if (!fromCart &&
          (productId == null || quantity == null || quantity <= 0)) {
        emit(
          CheckoutError(
            'Missing product checkout data. Please retry from product details.',
          ),
        );
        return;
      }

      await _dio.post(
        '/checkout/confirm',
        data: {
          'userId': userId,
          'fromCart': fromCart,
          if (fromCart) 'productIds': productIds,
          if (!fromCart) 'productId': productId,
          if (!fromCart) 'quantity': quantity,
        },
      );

      otpConfirmed = true;
      emit(CheckoutSuccess());
      emit(
        CheckoutDataChanged(
          selectedPaymentType: selectedPaymentType,
          otpConfirmed: otpConfirmed,
        ),
      );
    } on DioException catch (e) {
      emit(
        CheckoutError(
          ApiErrorParser.friendlyMessage(
            e,
            fallback: 'Checkout failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emit(CheckoutError('Checkout could not be completed. Please try again.'));
    }
  }
}
