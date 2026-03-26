import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/models/checkout_payment_model.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/checkout_cubit/checkout_cubit.dart';

class CheckoutPaymentPage extends StatelessWidget {
  const CheckoutPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutCubit()..load(),
      child: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Checkout confirmed via WhatsApp OTP.'),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CheckoutCubit>();
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...CheckoutPaymentType.values.map(
                    (type) => RadioListTile<CheckoutPaymentType>(
                      title: Text(_label(type)),
                      value: type,
                      groupValue: cubit.selectedPaymentType,
                      onChanged: (value) {
                        if (value != null) {
                          cubit.selectPaymentType(value);
                        }
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.greyBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Review: Payment with ${_label(cubit.selectedPaymentType)} then confirm by OTP on WhatsApp.',
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state is CheckoutLoading
                          ? null
                          : cubit.confirmOtp,
                      icon: state is CheckoutLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_user_outlined),
                      label: const Text('Confirm with OTP'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _label(CheckoutPaymentType type) {
    switch (type) {
      case CheckoutPaymentType.bank:
        return 'Bank Account';
      case CheckoutPaymentType.card:
        return 'Credit Card';
      case CheckoutPaymentType.cash:
        return 'Cash Balance';
    }
  }
}
