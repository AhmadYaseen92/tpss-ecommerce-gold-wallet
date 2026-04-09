using GoldWalletSystem.Application.DTOs.Dashboard;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IDashboardService
{
    Task<DashboardDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
}
