using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Transactions;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class TransactionHistoryRepository(AppDbContext dbContext) : ITransactionHistoryReadRepository
{
    public Task<PagedResult<TransactionHistoryDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => FilterAsync(new TransactionHistoryFilterRequestDto
        {
            UserId = userId,
            PageNumber = pageNumber,
            PageSize = pageSize,
        }, cancellationToken);

    public async Task<PagedResult<TransactionHistoryDto>> FilterAsync(TransactionHistoryFilterRequestDto request, CancellationToken cancellationToken = default)
    {
        var query = dbContext.TransactionHistories
            .AsNoTracking()
            .AsQueryable();

        if (request.SellerId.HasValue)
        {
            query = query.Where(x => x.SellerId == request.SellerId.Value);
        }
        else
        {
            query = query.Where(x => x.UserId == request.UserId);
        }

        if (!string.IsNullOrWhiteSpace(request.TransactionType))
        {
            var type = request.TransactionType.Trim();
            query = query.Where(x => x.TransactionType == type);
        }

        if (request.DateFromUtc is DateTime dateFromUtc)
            query = query.Where(x => x.CreatedAtUtc >= dateFromUtc);

        if (request.DateToUtc is DateTime dateToUtc)
            query = query.Where(x => x.CreatedAtUtc <= dateToUtc);

        query = query.OrderByDescending(x => x.CreatedAtUtc);

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(x => new TransactionHistoryDto(x.Id, x.UserId, x.SellerId, x.TransactionType, x.Amount, x.Currency, x.Reference, x.CreatedAtUtc))
            .ToListAsync(cancellationToken);

        return new PagedResult<TransactionHistoryDto>(items, totalCount, request.PageNumber, request.PageSize);
    }
}
