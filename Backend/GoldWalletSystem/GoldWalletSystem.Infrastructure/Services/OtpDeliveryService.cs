using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Services;

public class OtpDeliveryService(ILogger<OtpDeliveryService> logger, AppDbContext dbContext) : IOtpDeliveryService
{
    public async Task SendOtpAsync(User user, string otpCode, IReadOnlyCollection<OtpDeliveryChannel> channels, CancellationToken cancellationToken = default)
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

            dbContext.AppNotifications.Add(new AppNotification
            {
                UserId = user.Id,
                Title = $"OTP via {channel}",
                Body = $"Your verification OTP is {otpCode}. It expires soon.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
