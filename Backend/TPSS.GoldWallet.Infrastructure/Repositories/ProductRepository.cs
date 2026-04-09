using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class ProductRepository(AppDbContext dbContext) : IProductRepository
{
    public async Task<IReadOnlyList<Product>> GetActiveAsync(CancellationToken cancellationToken = default)
    {
        return await dbContext.Products
            .Where(x => x.IsActive)
            .OrderBy(x => x.Name)
            .ToListAsync(cancellationToken);
    }

    public Task<Product?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return dbContext.Products.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
    }
}
