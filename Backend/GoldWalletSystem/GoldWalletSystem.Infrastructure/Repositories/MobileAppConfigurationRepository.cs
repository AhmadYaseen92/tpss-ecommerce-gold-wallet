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
                Name = x.Name,
                Description = x.Description,
                ValueType = x.ValueType,
                ValueBool = x.ValueBool,
                ValueInt = x.ValueInt,
                ValueDecimal = x.ValueDecimal,
                ValueString = x.ValueString,
                SellerAccess = x.SellerAccess,
            })
            .ToListAsync(cancellationToken);

    public async Task<MobileAppConfigurationDto?> GetByKeyAsync(string configKey, CancellationToken cancellationToken = default)
        => await dbContext.MobileAppConfigurations.AsNoTracking()
            .Where(x => x.ConfigKey == configKey)
            .Select(x => new MobileAppConfigurationDto
            {
                Id = x.Id,
                ConfigKey = x.ConfigKey,
                Name = x.Name,
                Description = x.Description,
                ValueType = x.ValueType,
                ValueBool = x.ValueBool,
                ValueInt = x.ValueInt,
                ValueDecimal = x.ValueDecimal,
                ValueString = x.ValueString,
                SellerAccess = x.SellerAccess,
            })
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.MobileAppConfigurations.FirstOrDefaultAsync(x => x.ConfigKey == request.ConfigKey, cancellationToken);
        if (entity is null)
        {
            entity = new MobileAppConfiguration
            {
                ConfigKey = request.ConfigKey,
                Name = request.Name,
                Description = request.Description,
                ValueType = request.ValueType,
                ValueBool = request.ValueBool,
                ValueInt = request.ValueInt,
                ValueDecimal = request.ValueDecimal,
                ValueString = request.ValueString,
                SellerAccess = request.SellerAccess,
            };
            dbContext.MobileAppConfigurations.Add(entity);
        }
        else
        {
            entity.Name = request.Name;
            entity.Description = request.Description;
            entity.ValueType = request.ValueType;
            entity.ValueBool = request.ValueBool;
            entity.ValueInt = request.ValueInt;
            entity.ValueDecimal = request.ValueDecimal;
            entity.ValueString = request.ValueString;
            entity.SellerAccess = request.SellerAccess;
            entity.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return ToDto(entity);
    }

    private static MobileAppConfigurationDto ToDto(MobileAppConfiguration entity) => new()
    {
        Id = entity.Id,
        ConfigKey = entity.ConfigKey,
        Name = entity.Name,
        Description = entity.Description,
        ValueType = entity.ValueType,
        ValueBool = entity.ValueBool,
        ValueInt = entity.ValueInt,
        ValueDecimal = entity.ValueDecimal,
        ValueString = entity.ValueString,
        SellerAccess = entity.SellerAccess,
    };
}
