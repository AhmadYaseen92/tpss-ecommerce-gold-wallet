using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Logs;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class AuditLogRepository(AppDbContext dbContext) : IAuditLogRepository
{
    public async Task<PagedResult<AuditLogDto>> GetPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.AuditLogs.AsNoTracking().OrderByDescending(x => x.CreatedAtUtc);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize)
            .Select(x => new AuditLogDto(x.Id, x.UserId, x.Action, x.EntityName, x.EntityId, x.Details, x.CreatedAtUtc))
            .ToListAsync(cancellationToken);
        return new PagedResult<AuditLogDto>(items, totalCount, pageNumber, pageSize);
    }

    public async Task AddAsync(AuditLog log, CancellationToken cancellationToken = default)
    {
        dbContext.AuditLogs.Add(log);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
