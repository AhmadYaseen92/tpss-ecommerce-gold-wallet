import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/features/checkout/data/models/checkout_payment_model.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutPaymentType selectedPaymentType = CheckoutPaymentType.bank;
  bool otpConfirmed = false;

  CheckoutCubit() : super(CheckoutInitial());

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

  void confirmOtp() async {
    emit(CheckoutLoading());
    await Future.delayed(const Duration(milliseconds: 700));
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
