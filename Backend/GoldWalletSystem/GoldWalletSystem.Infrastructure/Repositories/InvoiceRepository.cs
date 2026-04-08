using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Invoices;
using GoldWalletSystem.Application.Services;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class InvoiceRepository(AppDbContext dbContext) : IInvoiceReadRepository
{
    public async Task<PagedResult<InvoiceDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.Invoices.AsNoTracking().Where(x => x.UserId == userId).OrderByDescending(x => x.CreatedAtUtc);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize)
            .Select(x => new InvoiceDto(x.Id, x.UserId, x.InvoiceNumber, x.SubTotal, x.TaxAmount, x.TotalAmount, x.Status, x.IssuedOnUtc))
            .ToListAsync(cancellationToken);
        return new PagedResult<InvoiceDto>(items, totalCount, pageNumber, pageSize);
    }
}
