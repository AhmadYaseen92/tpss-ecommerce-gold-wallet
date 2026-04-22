import 'package:tpss_ecommerce_gold_wallet/core/models/action_summary_model.dart';

class ActionSummaryBuilder {
  const ActionSummaryBuilder._();

  static ActionSummaryModel fromBackendData(Map<String, dynamic> data) {
    final feeBreakdowns = (data['feeBreakdowns'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map(
          (line) => ActionSummaryFeeBreakdownRow(
            feeName: (line['feeName'] ?? '').toString(),
            appliedValue: _toDouble(line['appliedValue']),
            isDiscount: line['isDiscount'] == true,
          ),
        )
        .toList();

    return ActionSummaryModel(
      subTotalAmount: _toDouble(data['subTotalAmount']),
      totalFeesAmount: _toDouble(data['totalFeesAmount']),
      discountAmount: _toDouble(data['discountAmount']),
      finalAmount: _toDouble(data['finalAmount']),
      currency: (data['currency'] ?? 'USD').toString(),
      feeBreakdowns: feeBreakdowns,
    );
  }

  static ActionSummaryModel fromAny(dynamic raw) {
    if (raw == null) return ActionSummaryModel.zero;

    if (raw is ActionSummaryModel) return raw;

    if (raw is Map) {
      final map = raw.map((key, value) => MapEntry('$key', value));
      return fromBackendData({
        'subTotalAmount': map['subTotalAmount'] ?? map['subtotal'],
        'totalFeesAmount': map['totalFeesAmount'],
        'discountAmount': map['discountAmount'],
        'finalAmount': map['finalAmount'] ?? map['total'],
        'currency': map['currency'],
        'feeBreakdowns': map['feeBreakdowns'],
      });
    }

    try {
      return fromBackendData({
        'subTotalAmount': raw.subTotalAmount ?? raw.subtotal,
        'totalFeesAmount': raw.totalFeesAmount,
        'discountAmount': raw.discountAmount,
        'finalAmount': raw.finalAmount ?? raw.total,
        'currency': raw.currency,
        'feeBreakdowns': raw.feeBreakdowns,
      });
    } catch (_) {
      return ActionSummaryModel.zero;
    }
  }

  static String currencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      default:
        return '${currency.toUpperCase()} ';
    }
  }

  static String formatMoney(double value, {String currency = 'USD'}) {
    return '${currencySymbol(currency)}${value.toStringAsFixed(2)}';
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
