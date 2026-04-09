using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Logs;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IAuditLogRepository
{
    Task<PagedResult<AuditLogDto>> GetPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}
