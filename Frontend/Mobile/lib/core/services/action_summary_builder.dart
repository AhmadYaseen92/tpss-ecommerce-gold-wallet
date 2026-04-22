import 'package:tpss_ecommerce_gold_wallet/core/models/action_summary_model.dart';

class ActionSummaryBuilder {
  const ActionSummaryBuilder._();

  static ActionSummaryModel fromBackendData(Map<String, dynamic> data) {
    final feeBreakdowns = (data['feeBreakdowns'] as List<dynamic>? ?? [])
        .map(
          (line) {
            if (line is Map) {
              return ActionSummaryFeeBreakdownRow(
                feeName: (line['feeName'] ?? '').toString(),
                appliedValue: _toDouble(line['appliedValue']),
                isDiscount: line['isDiscount'] == true,
              );
            }

            return ActionSummaryFeeBreakdownRow(
              feeName: _readDynamic(line, ['feeName']).toString(),
              appliedValue: _toDouble(_readDynamic(line, ['appliedValue'])),
              isDiscount: _readDynamic(line, ['isDiscount']) == true,
            );
          },
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
        'subTotalAmount': _readDynamic(raw, ['subTotalAmount', 'subtotal']),
        'totalFeesAmount': _readDynamic(raw, ['totalFeesAmount']),
        'discountAmount': _readDynamic(raw, ['discountAmount']),
        'finalAmount': _readDynamic(raw, ['finalAmount', 'total']),
        'currency': _readDynamic(raw, ['currency']),
        'feeBreakdowns': _readDynamic(raw, ['feeBreakdowns']),
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

  static dynamic _readDynamic(dynamic raw, List<String> keys) {
    for (final key in keys) {
      try {
        final value = switch (key) {
          'subTotalAmount' => raw.subTotalAmount,
          'subtotal' => raw.subtotal,
          'totalFeesAmount' => raw.totalFeesAmount,
          'discountAmount' => raw.discountAmount,
          'finalAmount' => raw.finalAmount,
          'total' => raw.total,
          'currency' => raw.currency,
          'feeBreakdowns' => raw.feeBreakdowns,
          'feeName' => raw.feeName,
          'appliedValue' => raw.appliedValue,
          'isDiscount' => raw.isDiscount,
          _ => null,
        };
        if (value != null) return value;
      } catch (_) {
        // Try next key.
      }
    }
    return null;
  }
}
