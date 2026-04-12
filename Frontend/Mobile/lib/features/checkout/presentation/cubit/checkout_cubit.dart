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
    try {
      final userId = AuthSessionStore.userId;
      if (userId == null) {
        emit(CheckoutError('No logged-in user.'));
        return;
      }

      final explicitFromCart = checkoutArgs['fromCart'];
      final source = (checkoutArgs['source'] ?? '').toString().toLowerCase();
      final productIdRaw = checkoutArgs['productId'];
      final quantityRaw = checkoutArgs['quantity'];
      final productId = productIdRaw is num
          ? productIdRaw.toInt()
          : int.tryParse('$productIdRaw');
      final quantity = quantityRaw is num
          ? quantityRaw.toInt()
          : int.tryParse('$quantityRaw');
      final fromCart = source == 'product'
          ? false
          : explicitFromCart is bool
          ? explicitFromCart
          : (productId == null || quantity == null);
      final productIdsRaw = checkoutArgs['productIds'];
      final productIds = productIdsRaw is List
          ? productIdsRaw
                .map((e) => e is num ? e.toInt() : int.tryParse('$e'))
                .whereType<int>()
                .toList()
          : <int>[];

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
      emit(CheckoutError(_friendlyCheckoutError(e)));
    } catch (_) {
      emit(CheckoutError('Checkout could not be completed. Please try again.'));
    }
  }

  String _friendlyCheckoutError(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverMessage = _extractServerMessage(error.response?.data);
    if (serverMessage.isNotEmpty) {
      return serverMessage;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your internet connection and try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach server. Please check your internet connection.';
    }

    return switch (statusCode) {
      400 =>
        'Invalid checkout request. Please review cart/product details and try again.',
      401 || 403 => 'Your session has expired. Please log in again.',
      404 => 'Requested item was not found. Please refresh and try again.',
      409 =>
        'Stock changed during checkout. Please refresh your cart and retry.',
      _ => 'Checkout failed. Please try again.',
    };
  }

  String _extractServerMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message']?.toString().trim() ?? '';
      if (message.isNotEmpty) return message;

      final errors = payload['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first.toString().trim();
        if (first.isNotEmpty) return first;
      }

      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        final nestedMessage = data['message']?.toString().trim() ?? '';
        if (nestedMessage.isNotEmpty) return nestedMessage;
      }
    }
    return '';
  }
}
