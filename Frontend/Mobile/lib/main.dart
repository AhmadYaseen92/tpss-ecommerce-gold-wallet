import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/app.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.setup();
  runApp(const GoldWalletApp());
}
