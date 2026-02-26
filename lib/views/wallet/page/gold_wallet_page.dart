import 'package:flutter/material.dart';

class GoldWalletPage extends StatelessWidget {
  const GoldWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Gold Wallet Page',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
