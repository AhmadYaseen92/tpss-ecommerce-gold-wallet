import 'package:tpss_ecommerce_gold_wallet/features/sell/domain/repositories/sell_repository.dart';

class GetLiveSellPriceUseCase {
  const GetLiveSellPriceUseCase(this._repository);

  final ISellRepository _repository;

  double call({required int assetIndex, required int refreshCount}) {
    return _repository.currentPriceForAsset(
      assetIndex: assetIndex,
      refreshCount: refreshCount,
    );
  }
}
