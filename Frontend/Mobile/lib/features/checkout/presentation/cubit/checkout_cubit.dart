import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
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
    final userId = AuthSessionStore.userId;
    if (userId == null) {
      emit(CheckoutError('No logged-in user.'));
      return;
    }

    final productIdRaw = checkoutArgs['productId'];
    final quantityRaw = checkoutArgs['quantity'];
    final productId = productIdRaw is num ? productIdRaw.toInt() : int.tryParse('$productIdRaw');
    final quantity = quantityRaw is num ? quantityRaw.toInt() : int.tryParse('$quantityRaw');
    final fromCart = productId == null || quantity == null;

    await _dio.post('/checkout/confirm', data: {
      'userId': userId,
      'fromCart': fromCart,
      if (!fromCart) 'productId': productId,
      if (!fromCart) 'quantity': quantity,
    });

    otpConfirmed = true;
    emit(CheckoutSuccess());
    emit(
      CheckoutDataChanged(
        selectedPaymentType: selectedPaymentType,
        otpConfirmed: otpConfirmed,
      ),
    );
  }
}
