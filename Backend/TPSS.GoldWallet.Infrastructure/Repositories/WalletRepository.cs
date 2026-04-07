using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class WalletRepository(AppDbContext dbContext) : IWalletRepository
{
    public Task<WalletAccount?> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
    {
        return dbContext.WalletAccounts
            .Include(x => x.Transactions)
            .FirstOrDefaultAsync(x => x.CustomerId == customerId, cancellationToken);
    }

    public Task AddAsync(WalletAccount account, CancellationToken cancellationToken = default)
        => dbContext.WalletAccounts.AddAsync(account, cancellationToken).AsTask();

    public void Update(WalletAccount account)
        => dbContext.WalletAccounts.Update(account);
}
