using GoldWalletSystem.Application.DTOs.Wallet;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class WalletService(IWalletRepository walletRepository) : IWalletService
{
    public async Task<WalletDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        var wallet = await walletRepository.GetByUserIdAsync(userId, cancellationToken)
            ?? throw new InvalidOperationException($"Wallet for user {userId} was not found.");

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
                    x.Weight,
                    x.Unit,
                    x.Purity,
                    x.Quantity,
                    x.AverageBuyPrice,
                    x.CurrentMarketPrice))
                .ToList());
    }
}
