using GoldWalletSystem.Application.DTOs.Wallet;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class WalletService(IWalletRepository walletRepository) : IWalletService
{
    public async Task<WalletDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var wallet = await walletRepository.GetByUserIdAsync(userId, cancellationToken)
            ?? await walletRepository.CreateForUserAsync(userId, cancellationToken);

        return new WalletDto(
            wallet.Id,
            wallet.UserId,
            wallet.CashBalance,
            wallet.CurrencyCode,
            wallet.Assets
                .OrderByDescending(x => x.CreatedAtUtc)
                .Select(x => new WalletAssetDto(
                    x.Id,
                    x.AssetType.ToString(),
                    x.Category.ToString(),
                    x.SellerId,
                    x.SellerName,
                    x.Weight,
                    x.Unit,
                    x.Purity,
                    x.Quantity,
                    x.AverageBuyPrice,
                    x.CurrentMarketPrice,
                    false))
                .ToList());
    }
}
