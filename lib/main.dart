import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/utils/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECommerse Gold Wallet APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );

  }
}
