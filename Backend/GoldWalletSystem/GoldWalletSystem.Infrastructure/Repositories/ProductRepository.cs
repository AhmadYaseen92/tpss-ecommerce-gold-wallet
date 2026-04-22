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
                x.Category,
                x.MaterialType,
                x.FormType,
                x.PricingMode,
                x.PurityKarat,
                x.PurityFactor,
                x.WeightValue,
                x.WeightUnit,
                x.BaseMarketPrice,
                x.ManualSellPrice,
                x.OfferPercent,
                x.OfferNewPrice,
                x.OfferType,
                x.IsHasOffer,
                x.AvailableStock,
                x.SellerId,
                SellerName = x.Seller.CompanyName
            })
            .ToListAsync(cancellationToken);

        var items = rows.Select(x =>
        {
            var basePrice = x.PricingMode == ProductPricingMode.Manual
                ? x.ManualSellPrice
                : ProductPricingCalculator.CalculateAutoPrice(x.MaterialType, x.BaseMarketPrice, x.WeightValue, x.PurityFactor);
            var finalPrice = ProductPricingCalculator.ApplyOffer(basePrice, x.OfferType, x.OfferPercent, x.OfferNewPrice);

            return new ProductDto(
                x.Id,
                x.Name,
                x.Sku,
                x.Description,
                x.ImageUrl,
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
                x.OfferPercent,
                x.OfferNewPrice,
                x.OfferType,
                finalPrice,
                x.IsHasOffer,
                x.AvailableStock,
                x.SellerId,
                x.SellerName);
        }).ToList();
        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
        return new PagedResult<ProductDto>(items, totalCount, pageNumber, pageSize, totalPages);
    }

    public Task<Product?> GetByIdAsync(int productId, CancellationToken cancellationToken = default)
        => dbContext.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Id == productId && x.IsActive, cancellationToken);
}
