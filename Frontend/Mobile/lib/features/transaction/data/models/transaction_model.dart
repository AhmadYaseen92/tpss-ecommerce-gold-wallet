class TransactionModel {
  final int id;
  final int userId;
  final int? sellerId;
  final String investorName;
  final String transactionType;
  final String status;
  final String productName;
  final String productImageUrl;
  final String category;
  final int quantity;
  final double unitPrice;
  final double weight;
  final String unit;
  final double purity;
  final String notes;
  final double amount;
  final String currency;
  final int? walletItemId;
  final int? invoiceId;
  final String? invoicePdfUrl;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    required this.investorName,
    required this.transactionType,
    required this.status,
    required this.productName,
    required this.productImageUrl,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.weight,
    required this.unit,
    required this.purity,
    required this.notes,
    required this.amount,
    required this.currency,
    required this.walletItemId,
    required this.invoiceId,
    required this.invoicePdfUrl,
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
      productName: (json['productName'] ?? json['category'] ?? '') as String,
      productImageUrl: (json['productImageUrl'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      unit: (json['unit'] ?? 'gram') as String,
      purity: (json['purity'] as num?)?.toDouble() ?? 0,
      notes: (json['notes'] ?? '') as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'USD') as String,
      walletItemId: (json['walletItemId'] as num?)?.toInt(),
      invoiceId: (json['invoiceId'] as num?)?.toInt(),
      invoicePdfUrl: (json['invoicePdfUrl'] ?? '').toString().isEmpty ? null : (json['invoicePdfUrl'] ?? '').toString(),
      createdAtUtc:
          DateTime.tryParse((json['createdAtUtc'] ?? '').toString()) ?? DateTime.now().toUtc(),
      updatedAtUtc: DateTime.tryParse(
        (json['updatedAtUtc'] ?? json['updatedAt'] ?? '').toString(),
      ),
    );
  }

  DateTime get displayDate => updatedAtUtc ?? createdAtUtc;

  bool get isGiftReceived =>
      transactionType.toLowerCase() == 'gift' &&
      (_readNoteValue('direction')?.toLowerCase() == 'received');

  bool get isTransferOrGift {
    final type = transactionType.toLowerCase();
    return type == 'transfer' || type == 'gift';
  }

  bool get isIncomingTransferOrGift =>
      isTransferOrGift && (_readNoteValue('direction')?.toLowerCase() == 'received');

  String? get fromInvestorName => _readNoteValue('from_investor_name');

  String? get toInvestorName => _readNoteValue('recipient_investor_name');

  String? get fromInvestorUserId => _readNoteValue('from_investor_user_id');

  String? get toInvestorUserId => _readNoteValue('recipient_investor_user_id');
  int? get walletAssetIdFromNotes {
    final raw = _readNoteValue('wallet_asset_id');
    return int.tryParse(raw ?? '');
  }

  String get transferFromLabel {
    if (!isTransferOrGift) return '-';
    if (isIncomingTransferOrGift) {
      return fromInvestorName ?? _formatInvestorId(fromInvestorUserId);
    }
    return investorName;
  }

  String get transferToLabel {
    if (!isTransferOrGift) return '-';
    if (isIncomingTransferOrGift) return investorName;
    return toInvestorName ?? _formatInvestorId(toInvestorUserId);
  }

  String? _readNoteValue(String key) {
    if (notes.isEmpty) return null;
    final marker = '$key=';
    final start = notes.toLowerCase().indexOf(marker.toLowerCase());
    if (start < 0) return null;
    final valueStart = start + marker.length;
    if (valueStart >= notes.length) return null;
    final tail = notes.substring(valueStart).trim();
    if (tail.isEmpty) return null;

    final separators = ['|', ',', ';'];
    var stopIndex = tail.length;
    for (final separator in separators) {
      final index = tail.indexOf(separator);
      if (index >= 0 && index < stopIndex) {
        stopIndex = index;
      }
    }

    final value = tail.substring(0, stopIndex).trim();
    return value.isEmpty ? null : value;
  }

  String _formatInvestorId(String? id) {
    if (id == null || id.isEmpty) return 'Unknown';
    return 'Investor #$id';
  }
}
