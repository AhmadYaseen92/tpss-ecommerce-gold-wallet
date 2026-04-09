using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Logs;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IAuditLogService
{
    Task<PagedResult<AuditLogDto>> GetLogsAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}
