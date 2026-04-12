using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IProductRepository
{
    Task<PagedResult<ProductDto>> GetPagedAsync(int pageNumber, int pageSize, ProductCategory? category = null, CancellationToken cancellationToken = default);
    Task<Product?> GetByIdAsync(int productId, CancellationToken cancellationToken = default);
}
