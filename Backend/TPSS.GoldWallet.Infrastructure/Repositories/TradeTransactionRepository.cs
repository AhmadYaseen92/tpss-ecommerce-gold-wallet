using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class TradeTransactionRepository(AppDbContext dbContext) : ITradeTransactionRepository
{
    public async Task<IReadOnlyList<TradeTransaction>> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        => await dbContext.TradeTransactions.Where(x => x.CustomerId == customerId).ToListAsync(cancellationToken);
}
