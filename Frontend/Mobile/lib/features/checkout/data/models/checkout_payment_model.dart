enum CheckoutPaymentType { bank, card, cash }

class CheckoutPaymentModel {
  final CheckoutPaymentType type;
  final String label;

  const CheckoutPaymentModel({required this.type, required this.label});
}
