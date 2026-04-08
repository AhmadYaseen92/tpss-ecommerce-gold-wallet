using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Products;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IProductService
{
    Task<PagedResult<ProductDto>> GetProductsAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}
