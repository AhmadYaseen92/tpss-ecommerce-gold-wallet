using GoldWalletSystem.Application.DTOs.Dashboard;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IDashboardRepository
{
    Task<DashboardDto> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
}
