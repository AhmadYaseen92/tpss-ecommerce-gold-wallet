using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Services;

public class OtpDeliveryService(ILogger<OtpDeliveryService> logger) : IOtpDeliveryService
{
    public Task SendOtpAsync(User user, string otpCode, IReadOnlyCollection<OtpDeliveryChannel> channels, CancellationToken cancellationToken = default)
    {
        foreach (var channel in channels)
        {
            switch (channel)
            {
                case OtpDeliveryChannel.WhatsApp:
                    logger.LogInformation("OTP sent via WhatsApp to user {UserId} ({PhoneNumber}). OTP: {OtpCode}", user.Id, user.PhoneNumber, otpCode);
                    break;
                case OtpDeliveryChannel.Email:
                    logger.LogInformation("OTP sent via Email to user {UserId} ({Email}). OTP: {OtpCode}", user.Id, user.Email, otpCode);
                    break;
            }
        }

        return Task.CompletedTask;
    }
}
