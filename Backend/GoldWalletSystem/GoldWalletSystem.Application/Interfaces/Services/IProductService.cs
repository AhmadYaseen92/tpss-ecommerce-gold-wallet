using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IProductService
{
    Task<PagedResult<ProductDto>> GetProductsAsync(int pageNumber, int pageSize, ProductCategory? category = null, CancellationToken cancellationToken = default);
    Task<List<ProductManagementDto>> GetManagementListAsync(CancellationToken cancellationToken = default);
    Task<ProductManagementDto?> GetManagementByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<List<EnumItemDto>> GetCategoriesAsync();
    Task<List<EnumItemDto>> GetWeightUnitsAsync();
    Task<List<EnumItemDto>> GetMaterialTypesAsync();
    Task<List<EnumItemDto>> GetFormTypesAsync();
    Task<List<EnumItemDto>> GetPricingModesAsync();
    Task<List<EnumItemDto>> GetPurityKaratsAsync();
    Task<List<EnumItemDto>> GetOfferTypesAsync();
}
