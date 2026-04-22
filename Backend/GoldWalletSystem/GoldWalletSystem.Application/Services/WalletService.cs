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
                    x.ProductId,
                    x.ProductName,
                    x.ProductSku,
                    x.ProductImageUrl,
                    x.Category.ToString(),
                    x.MaterialType,
                    x.FormType,
                    x.PurityKarat,
                    string.IsNullOrWhiteSpace(x.PurityDisplayName) ? ResolvePurityDisplayName(x.Category.ToString(), x.PurityKarat) : x.PurityDisplayName,
                    x.SellerId,
                    x.SellerName,
                    x.WeightValue,
                    x.WeightUnit,
                    x.Weight,
                    x.Unit,
                    x.Purity,
                    x.Quantity,
                    x.AverageBuyPrice,
                    x.CurrentMarketPrice,
                    x.AcquisitionSubTotalAmount,
                    x.AcquisitionFeesAmount,
                    x.AcquisitionDiscountAmount,
                    x.AcquisitionFinalAmount,
                    x.LastTransactionHistoryId,
                    x.SourceInvoiceId,
                    null,
                    null,
                    null,
                    false,
                    "Bought",
                    null))
                .ToList());
    }

    private static string? ResolvePurityDisplayName(string category, string? purityKarat)
    {
        if (string.IsNullOrWhiteSpace(category)) return purityKarat;

        return category.Trim().ToLowerInvariant() switch
        {
            "gold" => purityKarat,
            "silver" => purityKarat?.Trim().ToUpperInvariant() switch
            {
                "K24" => ".999",
                "K22" => ".925",
                _ => purityKarat
            },
            "diamond" => null,
            _ => purityKarat
        };
    }
}
