class TransactionModel {
  final String id;
  final String title;
  final String type;
  final String status;
  final DateTime date;
  final String amount;
  final String? secondaryAmount;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
    required this.amount,
    this.secondaryAmount,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    String? type,
    String? status,
    DateTime? date,
    String? amount,
    String? secondaryAmount,
    String? secondaryLabel,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      secondaryAmount: secondaryAmount ?? this.secondaryAmount,
    );
  }
}

final List<TransactionModel> dummyTransactions = [
  // Within last 7 days
  TransactionModel(
    id: 'TRX-8932',
    title: 'Buy Gold',
    type: 'buy',
    status: 'completed',
    date: DateTime.now().subtract(const Duration(days: 2)),
    amount: '+ 10g',
    secondaryAmount: '- \$650.00',
  ),

  // Within last 7 days
  TransactionModel(
    id: 'TRX-8931',
    title: 'Deposit Funds',
    type: 'deposit',
    status: 'completed',
    date: DateTime.now().subtract(const Duration(days: 5)),
    amount: '+ \$1000.00',
    secondaryAmount: null,
  ),

  // Within last 30 days (not 7)
  TransactionModel(
    id: 'TRX-8920',
    title: 'Sell Silver',
    type: 'sell',
    status: 'pending',
    date: DateTime.now().subtract(const Duration(days: 15)),
    amount: '+ \$420.00',
    secondaryAmount: '- 500g',
  ),

  // Within last 90 days (not 30)
  TransactionModel(
    id: 'TRX-8910',
    title: 'Sell Gold',
    type: 'sell',
    status: 'completed',
    date: DateTime.now().subtract(const Duration(days: 45)),
    amount: '+ \$320.00',
    secondaryAmount: '- 5g',
  ),

  // Within last 90 days (not 30)
  TransactionModel(
    id: 'TRX-8905',
    title: 'Withdraw',
    type: 'withdraw',
    status: 'failed',
    date: DateTime.now().subtract(const Duration(days: 60)),
    amount: '- \$200.00',
    secondaryAmount: null,
  ),

  // Older than 90 days (only visible in All Periods)
  TransactionModel(
    id: 'TRX-8900',
    title: 'Buy Silver',
    type: 'buy',
    status: 'completed',
    date: DateTime.now().subtract(const Duration(days: 120)),
    amount: '+ 200g',
    secondaryAmount: '- \$180.00',
  ),
];

List<TransactionModel> filteredTransactions = [];
