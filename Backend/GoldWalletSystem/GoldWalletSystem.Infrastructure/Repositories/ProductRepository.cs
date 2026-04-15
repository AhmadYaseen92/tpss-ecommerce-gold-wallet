using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
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

        query = query
            .OrderByDescending(x => x.UpdatedAtUtc ?? x.CreatedAtUtc)
            .ThenByDescending(x => x.CreatedAtUtc)
            .ThenByDescending(x => x.Id);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize)
            .Select(x => new ProductDto(
                x.Id,
                x.Name,
                x.Sku,
                x.Description,
                x.ImageUrl,
                x.Category,
                x.WeightValue,
                x.WeightUnit,
                x.Price,
                x.AvailableStock,
                x.SellerId,
                x.Seller.Name,
                x.CreatedAtUtc,
                x.UpdatedAtUtc))
            .ToListAsync(cancellationToken);
        return new PagedResult<ProductDto>(items, totalCount, pageNumber, pageSize);
    }

    public Task<Product?> GetByIdAsync(int productId, CancellationToken cancellationToken = default)
        => dbContext.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Id == productId && x.IsActive, cancellationToken);
}
