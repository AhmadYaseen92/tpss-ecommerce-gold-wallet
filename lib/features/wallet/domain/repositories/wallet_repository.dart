import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';

abstract class IWalletRepository {
  Future<List<WalletEntity>> loadWallets();

  Stream<List<WalletEntity>> watchWallets();
}
