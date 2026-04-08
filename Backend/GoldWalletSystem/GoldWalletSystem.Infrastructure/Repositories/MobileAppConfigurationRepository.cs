using GoldWalletSystem.Application.DTOs.Configuration;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class MobileAppConfigurationRepository(AppDbContext dbContext) : IMobileAppConfigurationRepository
{
    public async Task<IReadOnlyList<MobileAppConfigurationDto>> GetAllAsync(CancellationToken cancellationToken = default)
        => await dbContext.MobileAppConfigurations.AsNoTracking().OrderBy(x => x.ConfigKey)
            .Select(x => new MobileAppConfigurationDto
            {
                Id = x.Id,
                ConfigKey = x.ConfigKey,
                JsonValue = x.JsonValue,
                IsEnabled = x.IsEnabled,
                Description = x.Description,
            }).ToListAsync(cancellationToken);

    public async Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.MobileAppConfigurations.FirstOrDefaultAsync(x => x.ConfigKey == request.ConfigKey, cancellationToken);
        if (entity is null)
        {
            entity = new MobileAppConfiguration
            {
                ConfigKey = request.ConfigKey,
                JsonValue = request.JsonValue,
                IsEnabled = request.IsEnabled,
                Description = request.Description,
            };
            dbContext.MobileAppConfigurations.Add(entity);
        }
        else
        {
            entity.JsonValue = request.JsonValue;
            entity.IsEnabled = request.IsEnabled;
            entity.Description = request.Description;
            entity.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);

        return new MobileAppConfigurationDto
        {
            Id = entity.Id,
            ConfigKey = entity.ConfigKey,
            JsonValue = entity.JsonValue,
            IsEnabled = entity.IsEnabled,
            Description = entity.Description,
        };
    }
}
