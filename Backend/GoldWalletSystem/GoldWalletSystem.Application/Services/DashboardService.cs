using GoldWalletSystem.Application.DTOs.Dashboard;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class DashboardService(IDashboardRepository dashboardRepository) : IDashboardService
{
    public Task<DashboardDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
        => dashboardRepository.GetByUserIdAsync(userId, cancellationToken);
}
