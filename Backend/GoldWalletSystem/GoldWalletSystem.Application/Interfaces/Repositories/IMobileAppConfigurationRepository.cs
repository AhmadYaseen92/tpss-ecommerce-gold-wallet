using GoldWalletSystem.Application.DTOs.Configuration;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface IMobileAppConfigurationRepository
{
    Task<IReadOnlyList<MobileAppConfigurationDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default);
}
