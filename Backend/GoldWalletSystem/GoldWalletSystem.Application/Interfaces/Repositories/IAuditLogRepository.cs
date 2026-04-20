using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Logs;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IAuditLogRepository
{
    Task<PagedResult<AuditLogDto>> GetPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task AddAsync(AuditLog log, CancellationToken cancellationToken = default);
}
