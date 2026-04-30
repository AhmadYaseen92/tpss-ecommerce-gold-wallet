using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class ProductRepository(AppDbContext dbContext, ICurrentUserService currentUser) : IProductRepository
{
    private static readonly Dictionary<string, (string CurrencyCode, decimal ExchangeRate)> MarketCurrencyMap = new(StringComparer.OrdinalIgnoreCase)
    {
        ["UAE"] = ("AED", 3.67m),
        ["KSA"] = ("SAR", 3.75m),
        ["JORDAN"] = ("JOD", 0.71m),
        ["EGYPT"] = ("EGP", 48.50m),
        ["INDIA"] = ("INR", 83.20m),
    };
    public async Task<PagedResult<ProductDto>> GetPagedAsync(int pageNumber, int pageSize, ProductCategory? category = null, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Products.AsNoTracking().Where(x => x.IsActive);
        if (!currentUser.IsInRole("Admin") && currentUser.SellerId.HasValue)
        {
            query = query.Where(x => x.SellerId == currentUser.SellerId.Value);
        }

        if (category.HasValue)
        {
            query = query.Where(x => x.Category == category.Value);
        }

        query = query.OrderByDescending(x => x.CreatedAtUtc).ThenByDescending(x => x.Id);
        var totalCount = await query.CountAsync(cancellationToken);
        var rows = await query
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .Select(x => new
            {
                x.Id,
                x.Name,
                x.Sku,
                x.Description,
                x.ImageUrl,
                x.VideoUrl,
                x.Category,
                x.MaterialType,
                x.FormType,
                x.PricingMode,
                x.PurityKarat,
                x.PurityFactor,
                x.WeightValue,
                x.WeightUnit,
                x.BaseMarketPrice,
                x.AutoPrice,
                x.FixedPrice,
                x.SellPrice,
                x.OfferPercent,
                x.OfferNewPrice,
                x.OfferType,
                x.IsHasOffer,
                x.AvailableStock,
                x.IsActive,
                x.SellerId,
                SellerName = x.Seller.CompanyName,
                MarketType = x.Seller.MarketType
            })
            .ToListAsync(cancellationToken);

        var items = rows.Select(x =>
        {
            var marketKey = string.IsNullOrWhiteSpace(x.MarketType) ? "UAE" : x.MarketType.Trim().ToUpperInvariant();
            var marketInfo = MarketCurrencyMap.TryGetValue(marketKey, out var resolved)
                ? resolved
                : MarketCurrencyMap["UAE"];
            return new ProductDto(
                x.Id,
                x.Name,
                x.Sku,
                x.Description,
                x.ImageUrl,
                x.VideoUrl,
                x.Category,
                x.MaterialType,
                x.FormType,
                $"{x.MaterialType} {x.FormType}",
                x.PricingMode,
                x.PurityKarat,
                x.PurityFactor,
                x.WeightValue,
                x.WeightUnit,
                x.BaseMarketPrice,
                x.AutoPrice,
                x.FixedPrice,
                x.SellPrice,
                x.OfferPercent,
                x.OfferNewPrice,
                x.OfferType,
                x.IsHasOffer,
                x.AvailableStock,
                x.IsActive,
                x.SellerId,
                x.SellerName,
                marketInfo.CurrencyCode,
                decimal.Round(x.BaseMarketPrice * marketInfo.ExchangeRate, 2),
                decimal.Round(x.SellPrice * marketInfo.ExchangeRate, 2));
        }).ToList();
        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
        return new PagedResult<ProductDto>(items, totalCount, pageNumber, pageSize, totalPages);
    }

    public Task<Product?> GetByIdAsync(int productId, CancellationToken cancellationToken = default)
        => dbContext.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Id == productId && x.IsActive, cancellationToken);
}
