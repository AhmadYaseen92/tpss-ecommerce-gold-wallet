import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/entities/wallet_entity.dart';
import 'package:tpss_ecommerce_gold_wallet/features/wallet/domain/repositories/wallet_repository.dart';

class WatchWalletsUseCase {
  const WatchWalletsUseCase(this._repository);

  final IWalletRepository _repository;

  Stream<List<WalletEntity>> call() => _repository.watchWallets();
}
