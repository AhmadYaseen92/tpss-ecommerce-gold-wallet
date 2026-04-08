using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Logs;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class AuditLogService(IAuditLogRepository logRepository) : IAuditLogService
{
    public Task<PagedResult<AuditLogDto>> GetLogsAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => logRepository.GetPagedAsync(pageNumber, pageSize, cancellationToken);
}
