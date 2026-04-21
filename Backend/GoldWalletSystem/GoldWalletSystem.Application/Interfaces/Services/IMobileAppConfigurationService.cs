using GoldWalletSystem.Application.DTOs.Configuration;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IMobileAppConfigurationService
{
    Task<IReadOnlyList<MobileAppConfigurationDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default);
    Task<bool?> GetBoolAsync(string key, CancellationToken cancellationToken = default);
    Task<int?> GetIntAsync(string key, CancellationToken cancellationToken = default);
    Task<string?> GetStringAsync(string key, CancellationToken cancellationToken = default);
    Task<decimal?> GetDecimalAsync(string key, CancellationToken cancellationToken = default);
}
