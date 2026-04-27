using GoldWalletSystem.Application.DTOs.Configuration;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Enums;

namespace GoldWalletSystem.Application.Services;

public class MobileAppConfigurationService(IMobileAppConfigurationRepository repository) : IMobileAppConfigurationService
{
    public Task<IReadOnlyList<MobileAppConfigurationDto>> GetAllAsync(CancellationToken cancellationToken = default)
        => repository.GetAllAsync(cancellationToken);

    public Task<bool?> GetBoolAsync(string key, CancellationToken cancellationToken = default)
        => GetByTypeAsync(key, ConfigurationValueType.Bool, x => x.ValueBool, cancellationToken);

    public Task<int?> GetIntAsync(string key, CancellationToken cancellationToken = default)
        => GetByTypeAsync(key, ConfigurationValueType.Int, x => x.ValueInt, cancellationToken);

    public Task<string?> GetStringAsync(string key, CancellationToken cancellationToken = default)
        => GetByTypeAsync(key, ConfigurationValueType.String, x => x.ValueString, cancellationToken);

    public Task<decimal?> GetDecimalAsync(string key, CancellationToken cancellationToken = default)
        => GetByTypeAsync(key, ConfigurationValueType.Decimal, x => x.ValueDecimal, cancellationToken);

    public async Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Name))
            throw new InvalidOperationException("Name is required.");

        if (HasMoreThanOneValue(request))
            throw new InvalidOperationException("Only one value column may be set.");

        var normalized = new UpsertMobileAppConfigurationRequestDto
        {
            ConfigKey = request.ConfigKey,
            Name = request.Name,
            ValueType = request.ValueType,
            SellerAccess = request.SellerAccess,
            Description = request.Description,
            ValueString = request.ValueType == ConfigurationValueType.String ? request.ValueString : null,
            ValueBool = request.ValueType == ConfigurationValueType.Bool ? request.ValueBool : null,
            ValueInt = request.ValueType == ConfigurationValueType.Int ? request.ValueInt : null,
            ValueDecimal = request.ValueType == ConfigurationValueType.Decimal ? request.ValueDecimal : null
        };

        await ValidateDomainRulesAsync(normalized, cancellationToken);
        return await repository.UpsertAsync(normalized, cancellationToken);
    }

    private async Task ValidateDomainRulesAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken)
    {
        var all = await repository.GetAllAsync(cancellationToken);
        var map = all.ToDictionary(
            x => x.ConfigKey,
            x => new UpsertMobileAppConfigurationRequestDto
            {
                ConfigKey = x.ConfigKey,
                Name = x.Name,
                Description = x.Description,
                ValueType = x.ValueType,
                ValueBool = x.ValueBool,
                ValueInt = x.ValueInt,
                ValueDecimal = x.ValueDecimal,
                ValueString = x.ValueString,
                SellerAccess = x.SellerAccess
            }
        );

        map[request.ConfigKey] = request;

        bool ReadBool(string key) => map.TryGetValue(key, out var item) && item.ValueBool == true;
        string ReadString(string key) => map.TryGetValue(key, out var item) ? item.ValueString ?? string.Empty : string.Empty;
        int ReadInt(string key) => map.TryGetValue(key, out var item) ? item.ValueInt ?? 0 : 0;

        if (ReadBool(MobileAppConfigurationKeys.MobileReleaseIsIndividualSeller) &&
            string.IsNullOrWhiteSpace(ReadString(MobileAppConfigurationKeys.MobileReleaseIndividualSellerName)))
        {
            throw new InvalidOperationException("Single Seller Name is required when Single Seller Mode is enabled.");
        }

        var whatsappEnabled = ReadBool(MobileAppConfigurationKeys.OtpEnableWhatsapp);
        var emailEnabled = ReadBool(MobileAppConfigurationKeys.OtpEnableEmail);
        if (!whatsappEnabled && !emailEnabled)
        {
            throw new InvalidOperationException("At least one OTP delivery channel must be enabled.");
        }

        if (!ReadBool(MobileAppConfigurationKeys.LoginByPinEnabled) && ReadBool(MobileAppConfigurationKeys.LoginByBiometricEnabled))
        {
            throw new InvalidOperationException("Enable PIN Login before enabling Biometric Login.");
        }

        foreach (var key in new[]
                 {
                     MobileAppConfigurationKeys.OtpExpirySeconds,
                     MobileAppConfigurationKeys.OtpResendCooldownSeconds,
                     MobileAppConfigurationKeys.OtpMaxResendCount,
                     MobileAppConfigurationKeys.OtpMaxVerificationAttempts,
                     MobileAppConfigurationKeys.WalletSellLockSeconds,
                     MobileAppConfigurationKeys.ProductVideoMaxDurationSeconds
                 })
        {
            if (!map.ContainsKey(key)) continue;
            if (ReadInt(key) <= 0)
            {
                throw new InvalidOperationException("Value must be greater than 0.");
            }
        }
    }

    private async Task<T?> GetByTypeAsync<T>(string key, ConfigurationValueType expectedType, Func<MobileAppConfigurationDto, T?> selector, CancellationToken cancellationToken)
    {
        var config = await repository.GetByKeyAsync(key, cancellationToken);
        if (config is null || config.ValueType != expectedType)
            return default;

        return selector(config);
    }

    private static bool HasMoreThanOneValue(UpsertMobileAppConfigurationRequestDto request)
    {
        var count = 0;
        if (request.ValueString is not null) count++;
        if (request.ValueBool.HasValue) count++;
        if (request.ValueInt.HasValue) count++;
        if (request.ValueDecimal.HasValue) count++;
        return count > 1;
    }
}
