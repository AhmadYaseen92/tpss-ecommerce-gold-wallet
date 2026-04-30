using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Services;

public class ProductService(IProductRepository productRepository) : IProductService
{
    public Task<PagedResult<ProductDto>> GetProductsAsync(int pageNumber, int pageSize, ProductCategory? category = null, CancellationToken cancellationToken = default)
        => productRepository.GetPagedAsync(pageNumber, pageSize, category, cancellationToken);

    public Task<List<ProductManagementDto>> GetManagementListAsync(CancellationToken cancellationToken = default) => throw new NotImplementedException();
    public Task<ProductManagementDto?> GetManagementByIdAsync(int id, CancellationToken cancellationToken = default) => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetCategoriesAsync() => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetWeightUnitsAsync() => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetMaterialTypesAsync() => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetFormTypesAsync() => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetPricingModesAsync() => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetPurityKaratsAsync() => throw new NotImplementedException();
    public Task<List<EnumItemDto>> GetOfferTypesAsync() => throw new NotImplementedException();
}
