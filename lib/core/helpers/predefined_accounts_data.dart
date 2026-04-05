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
    const PredefinedAccount(
      id: 'bank_1',
      name: 'Jordan Islamic Bank ••••6789',
      subtitle: 'Primary Account',
    ),
    const PredefinedAccount(
      id: 'bank_2',
      name: 'Arab Bank ••••1140',
      subtitle: 'Secondary Account',
    ),
  ];

  static const List<PredefinedAccount> paymentMethods = [
    const PredefinedAccount(
      id: 'card_1',
      name: 'Visa •••• 9281',
      subtitle: 'Default Card',
    ),
    const PredefinedAccount(
      id: 'apple_pay',
      name: 'Apple Pay',
      subtitle: 'Face ID / Touch ID',
    ),
    const PredefinedAccount(
      id: 'zaincash',
      name: 'ZainCash',
      subtitle: 'Wallet + OTP',
    ),
  ];

  static const List<PredefinedAccount> usdtAccounts = [
    const PredefinedAccount(
      id: 'usdt_1',
      name: 'USDT Wallet • TRC20',
      subtitle: 'TQ7A...91XK',
    ),
  ];

  static const List<PredefinedAccount> eDirhamAccounts = [
    const PredefinedAccount(
      id: 'edirham_1',
      name: 'eDirham Wallet',
      subtitle: 'EDR-AHMAD-001',
    ),
  ];
}
