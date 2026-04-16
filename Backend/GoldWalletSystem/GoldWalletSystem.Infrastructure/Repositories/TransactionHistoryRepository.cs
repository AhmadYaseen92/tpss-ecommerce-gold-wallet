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
        if (!string.IsNullOrWhiteSpace(request.Status))
        {
            var status = request.Status.Trim();
            query = query.Where(x => x.Status == status);
        }
        if (!string.IsNullOrWhiteSpace(request.Category))
        {
            var category = request.Category.Trim();
            query = query.Where(x => x.Category == category);
        }

        if (request.DateFromUtc is DateTime dateFromUtc)
            query = query.Where(x => x.CreatedAtUtc >= dateFromUtc);

        if (request.DateToUtc is DateTime dateToUtc)
            query = query.Where(x => x.CreatedAtUtc <= dateToUtc);

        query = query.OrderByDescending(x => x.CreatedAtUtc);

        var totalCount = await query.CountAsync(cancellationToken);
        var rows = await query
            .Skip((request.PageNumber - 1) * request.PageSize)
            .Take(request.PageSize)
            .Join(
                dbContext.Users.AsNoTracking(),
                history => history.UserId,
                user => user.Id,
                (history, user) => new
                {
                    history,
                    InvestorName = user.FullName
                })
            .ToListAsync(cancellationToken);

        var sellerIds = rows
            .Where(x => x.history.SellerId.HasValue)
            .Select(x => x.history.SellerId!.Value)
            .Distinct()
            .ToList();

        var productsBySellerSku = await dbContext.Products
            .AsNoTracking()
            .Where(x => sellerIds.Contains(x.SellerId))
            .Select(x => new { x.SellerId, x.Sku, x.Name })
            .ToListAsync(cancellationToken);

        var productLookup = productsBySellerSku.ToDictionary(
            x => (x.SellerId, x.Sku),
            x => x.Name,
            EqualityComparer<(int SellerId, string Sku)>.Default);

        var items = rows
            .Select(row =>
            {
                var productName = ResolveProductName(row.history.SellerId, row.history.Notes, row.history.Category, productLookup);
                return new TransactionHistoryDto(
                    row.history.Id,
                    row.history.UserId,
                    row.InvestorName,
                    row.history.SellerId,
                    row.history.TransactionType,
                    row.history.Status,
                    productName,
                    row.history.Category,
                    row.history.Quantity,
                    row.history.UnitPrice,
                    row.history.Weight,
                    row.history.Unit,
                    row.history.Purity,
                    row.history.Amount,
                    row.history.Currency,
                    row.history.Notes,
                    row.history.CreatedAtUtc);
            })
            .ToList();

        return new PagedResult<TransactionHistoryDto>(items, totalCount, request.PageNumber, request.PageSize);
    }

    private static string ResolveProductName(
        int? sellerId,
        string? notes,
        string fallback,
        IReadOnlyDictionary<(int SellerId, string Sku), string> productLookup)
    {
        if (!sellerId.HasValue) return fallback;
        var sku = TryExtractSku(notes);
        if (string.IsNullOrWhiteSpace(sku)) return fallback;
        return productLookup.TryGetValue((sellerId.Value, sku), out var name) ? name : fallback;
    }

    private static string? TryExtractSku(string? notes)
    {
        if (string.IsNullOrWhiteSpace(notes)) return null;

        const string marker = "SKU=";
        var markerIndex = notes.IndexOf(marker, StringComparison.OrdinalIgnoreCase);
        if (markerIndex < 0) return null;

        var valueStart = markerIndex + marker.Length;
        if (valueStart >= notes.Length) return null;

        var tail = notes[valueStart..].Trim();
        if (tail.Length == 0) return null;

        var stopAt = tail.IndexOfAny(['|', ',', ';', ' ']);
        return stopAt > 0 ? tail[..stopAt].Trim() : tail;
    }
}
