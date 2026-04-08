using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class TransactionHistoryRepository(AppDbContext dbContext) : ITransactionHistoryReadRepository
{
    public async Task<PagedResult<TransactionHistoryDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.TransactionHistories.AsNoTracking().Where(x => x.UserId == userId).OrderByDescending(x => x.CreatedAtUtc);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize)
            .Select(x => new TransactionHistoryDto(x.Id, x.UserId, x.TransactionType, x.Amount, x.Currency, x.Reference, x.CreatedAtUtc))
            .ToListAsync(cancellationToken);
        return new PagedResult<TransactionHistoryDto>(items, totalCount, pageNumber, pageSize);
    }
}
