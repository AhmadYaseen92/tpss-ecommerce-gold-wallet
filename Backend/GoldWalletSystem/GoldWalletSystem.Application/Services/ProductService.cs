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
}
