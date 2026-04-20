using GoldWalletSystem.Application.DTOs.Configuration;
using GoldWalletSystem.Application.Constants;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using System.Text.Json;

namespace GoldWalletSystem.Application.Services;

public class MobileAppConfigurationService(IMobileAppConfigurationRepository repository) : IMobileAppConfigurationService
{
    public Task<IReadOnlyList<MobileAppConfigurationDto>> GetAllAsync(CancellationToken cancellationToken = default)
        => repository.GetAllAsync(cancellationToken);

    public Task<MobileAppConfigurationDto> UpsertAsync(UpsertMobileAppConfigurationRequestDto request, CancellationToken cancellationToken = default)
    {
        if (string.Equals(request.ConfigKey, MobileAppConfigurationKeys.LoginOtpDeliveryChannels, StringComparison.OrdinalIgnoreCase))
        {
            ValidateOtpChannelsConfiguration(request.JsonValue);
        }

        return repository.UpsertAsync(request, cancellationToken);
    }

    private static void ValidateOtpChannelsConfiguration(string jsonValue)
    {
        try
        {
            using var document = JsonDocument.Parse(jsonValue);
            var channelsNode = document.RootElement.ValueKind switch
            {
                JsonValueKind.Array => document.RootElement,
                JsonValueKind.Object when document.RootElement.TryGetProperty("channels", out var channels) => channels,
                _ => throw new InvalidOperationException("OTP channels must be a JSON array or an object with a 'channels' array.")
            };

            if (channelsNode.ValueKind != JsonValueKind.Array)
                throw new InvalidOperationException("OTP channels must be an array.");

            var channels = channelsNode.EnumerateArray()
                .Select(x => x.GetString()?.Trim().ToLowerInvariant())
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .ToArray();

            if (channels.Length == 0)
                throw new InvalidOperationException("At least one OTP channel must be selected.");

            if (channels.Any(x => x is not ("whatsapp" or "email")))
                throw new InvalidOperationException("OTP channels support only 'whatsapp' and 'email'.");
        }
        catch (JsonException)
        {
            throw new InvalidOperationException("OTP channels must be valid JSON.");
        }
    }
}
