using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class WalletRepository(AppDbContext dbContext) : IWalletRepository
{
    public Task<Wallet?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
        => dbContext.Wallets
            .AsNoTracking()
            .Include(x => x.Assets)
            .FirstOrDefaultAsync(x => x.UserId == userId, cancellationToken);

    public async Task<Wallet> CreateForUserAsync(int userId, CancellationToken cancellationToken = default)
    {
        var wallet = new Wallet
        {
            UserId = userId,
            CurrencyCode = "USD",
            CashBalance = 0,
            CreatedAtUtc = DateTime.UtcNow,
        };

        dbContext.Wallets.Add(wallet);
        await dbContext.SaveChangesAsync(cancellationToken);

        return wallet;
    }
}
