using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IProductService
{
    Task<PagedResult<ProductDto>> GetProductsAsync(int pageNumber, int pageSize, ProductCategory? category = null, CancellationToken cancellationToken = default);
}
