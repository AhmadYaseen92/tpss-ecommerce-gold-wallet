class TransactionModel {
  final int id;
  final int userId;
  final int? sellerId;
  final String investorName;
  final String transactionType;
  final String status;
  final String category;
  final int quantity;
  final double unitPrice;
  final double weight;
  final String unit;
  final double purity;
  final String notes;
  final double amount;
  final String currency;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.investorName,
    required this.transactionType,
    required this.status,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.weight,
    required this.unit,
    required this.purity,
    required this.notes,
    required this.amount,
    required this.currency,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      sellerId: (json['sellerId'] as num?)?.toInt(),
      investorName: (json['investorName'] ?? '') as String,
      transactionType: (json['transactionType'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      unit: (json['unit'] ?? 'gram') as String,
      purity: (json['purity'] as num?)?.toDouble() ?? 0,
      notes: (json['notes'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'USD') as String,
      createdAtUtc:
          DateTime.tryParse((json['createdAtUtc'] ?? '').toString()) ?? DateTime.now().toUtc(),
      updatedAtUtc: DateTime.tryParse((json['updatedAtUtc'] ?? '').toString()),
    );
  }

  DateTime get displayDate => updatedAtUtc ?? createdAtUtc;
}
