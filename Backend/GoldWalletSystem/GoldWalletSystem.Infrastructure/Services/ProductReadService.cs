using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Constants;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace GoldWalletSystem.Infrastructure.Services;

public class ProductReadService(IProductRepository productRepository, AppDbContext dbContext, ICurrentUserService currentUser) : IProductService
{
    public Task<PagedResult<ProductDto>> GetProductsAsync(int pageNumber, int pageSize, ProductCategory? category = null, CancellationToken cancellationToken = default)
        => productRepository.GetPagedAsync(pageNumber, pageSize, category, cancellationToken);

    public async Task<List<ProductManagementDto>> GetManagementListAsync(CancellationToken cancellationToken = default)
    {
        EnsureSellerOrAdmin();
        var query = dbContext.Products.AsNoTracking().AsQueryable();
        if (!currentUser.IsInRole(SystemRoles.Admin) && currentUser.SellerId.HasValue)
            query = query.Where(x => x.SellerId == currentUser.SellerId.Value);

        var items = await query.OrderByDescending(x => x.Id).Select(MapManagement()).ToListAsync(cancellationToken);
        items.ForEach(Normalize);
        return items;
    }

    public async Task<ProductManagementDto?> GetManagementByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        EnsureSellerOrAdmin();
        var query = dbContext.Products.AsNoTracking().Where(x => x.Id == id);
        if (!currentUser.IsInRole(SystemRoles.Admin))
        {
            if (!currentUser.SellerId.HasValue) return null;
            query = query.Where(x => x.SellerId == currentUser.SellerId.Value);
        }
        var item = await query.Select(MapManagement()).FirstOrDefaultAsync(cancellationToken);
        if (item is not null) Normalize(item);
        return item;
    }

    public Task<List<EnumItemDto>> GetCategoriesAsync() => Task.FromResult(Enum.GetValues<ProductCategory>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList());
    public Task<List<EnumItemDto>> GetWeightUnitsAsync() => Task.FromResult(Enum.GetValues<ProductWeightUnit>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList());
    public Task<List<EnumItemDto>> GetMaterialTypesAsync() => Task.FromResult(Enum.GetValues<ProductMaterialType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList());
    public Task<List<EnumItemDto>> GetFormTypesAsync() => Task.FromResult(Enum.GetValues<ProductFormType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList());
    public Task<List<EnumItemDto>> GetPricingModesAsync() => Task.FromResult(Enum.GetValues<ProductPricingMode>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList());
    public Task<List<EnumItemDto>> GetPurityKaratsAsync() => Task.FromResult(Enum.GetValues<ProductPurityKarat>().Select(x => new EnumItemDto((int)x, x.ToString().Replace("K", "K ").Trim())).ToList());
    public Task<List<EnumItemDto>> GetOfferTypesAsync() => Task.FromResult(Enum.GetValues<ProductOfferType>().Select(x => new EnumItemDto((int)x, x.ToString())).ToList());

    private static Expression<Func<Domain.Entities.Product, ProductManagementDto>> MapManagement() => x => new ProductManagementDto
    {
        Id = x.Id, Name = x.Name, Sku = x.Sku, Description = x.Description, ImageUrl = x.ImageUrl, VideoUrl = x.VideoUrl,
        Category = x.Category, MaterialType = x.MaterialType, FormType = x.FormType, DisplayCategoryLabel = x.MaterialType + " " + x.FormType,
        PricingMode = x.PricingMode, PurityKarat = x.PurityKarat, PurityFactor = x.PurityFactor, WeightValue = x.WeightValue, WeightUnit = x.WeightUnit,
        BaseMarketPrice = x.BaseMarketPrice, AutoPrice = x.AutoPrice, FixedPrice = x.FixedPrice, SellPrice = x.SellPrice,
        OfferPercent = x.OfferPercent, OfferNewPrice = x.OfferNewPrice, OfferType = x.OfferType, IsHasOffer = x.IsHasOffer,
        AvailableStock = x.AvailableStock, IsActive = x.IsActive, SellerId = x.SellerId
    };

    private static void Normalize(ProductManagementDto item)
    {
        item.ImageUrl = NormalizeRelative(item.ImageUrl);
        item.VideoUrl = NormalizeRelative(item.VideoUrl);
    }

    private static string NormalizeRelative(string? path)
        => string.IsNullOrWhiteSpace(path) ? string.Empty : (path.StartsWith("/") ? path : "/" + path);

    private void EnsureSellerOrAdmin()
    {
        if (!currentUser.IsInRole(SystemRoles.Admin) && !currentUser.IsInRole(SystemRoles.Seller))
            throw new UnauthorizedAccessException("Unauthorized");
    }
}
