using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Services;

public class ProductService(IReadRepository<ProductDto> productRepository) : IProductService
{
    public Task<PagedResult<ProductDto>> GetProductsAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => productRepository.GetPagedAsync(pageNumber, pageSize, cancellationToken);
}
