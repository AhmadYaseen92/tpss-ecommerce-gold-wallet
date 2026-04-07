using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface IProductRepository
{
    Task<IReadOnlyList<Product>> GetActiveAsync(CancellationToken cancellationToken = default);
    Task<Product?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
}
