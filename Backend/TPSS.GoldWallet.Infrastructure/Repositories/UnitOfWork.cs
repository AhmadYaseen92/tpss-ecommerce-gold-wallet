using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class UnitOfWork(AppDbContext dbContext) : IUnitOfWork
{
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => dbContext.SaveChangesAsync(cancellationToken);
}
