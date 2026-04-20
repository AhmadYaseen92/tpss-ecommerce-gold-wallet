using GoldWalletSystem.Application.DTOs.Admin;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IWebAdminDashboardService
{
    Task<WebDashboardDto> BuildAsync(string period, int? sellerId = null, CancellationToken cancellationToken = default);
}
