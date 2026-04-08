using GoldWalletSystem.Application.DTOs.Configuration;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IMobileAppConfigurationService
{
    Task<IReadOnlyList<MobileAppConfigurationDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default);
}
