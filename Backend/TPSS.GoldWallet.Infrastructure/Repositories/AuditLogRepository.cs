using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class AuditLogRepository(AppDbContext dbContext) : IAuditLogRepository
{
    public Task AddAsync(AuditLog auditLog, CancellationToken cancellationToken = default)
        => dbContext.AuditLogs.AddAsync(auditLog, cancellationToken).AsTask();

    public async Task<IReadOnlyList<AuditLog>> GetLatestAsync(int take, CancellationToken cancellationToken = default)
        => await dbContext.AuditLogs.OrderByDescending(x => x.CreatedAtUtc).Take(take).ToListAsync(cancellationToken);
}
