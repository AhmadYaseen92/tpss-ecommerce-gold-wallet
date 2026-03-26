class PredefinedAccount {
  final String id;
  final String name;
  final String subtitle;

  const PredefinedAccount({
    required this.id,
    required this.name,
    required this.subtitle,
  });
}

class PredefinedAccountsData {
  static const List<PredefinedAccount> bankAccounts = [
    PredefinedAccount(
      id: 'bank_1',
      name: 'Jordan Islamic Bank ••••6789',
      subtitle: 'Primary Account',
    ),
    PredefinedAccount(
      id: 'bank_2',
      name: 'Arab Bank ••••1140',
      subtitle: 'Secondary Account',
    ),
  ];

  static const List<PredefinedAccount> paymentMethods = [
    PredefinedAccount(
      id: 'card_1',
      name: 'Visa •••• 9281',
      subtitle: 'Default Card',
    ),
    PredefinedAccount(
      id: 'apple_pay',
      name: 'Apple Pay',
      subtitle: 'Face ID / Touch ID',
    ),
    PredefinedAccount(
      id: 'zaincash',
      name: 'ZainCash',
      subtitle: 'Wallet + OTP',
    ),
  ];
}
