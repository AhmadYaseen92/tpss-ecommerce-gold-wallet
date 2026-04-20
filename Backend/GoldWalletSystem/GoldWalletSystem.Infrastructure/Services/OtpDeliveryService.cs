using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Domain.Enums;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Services;

public class OtpDeliveryService(
    ILogger<OtpDeliveryService> logger,
    AppDbContext dbContext,
    IConfiguration configuration) : IOtpDeliveryService
{
    private readonly string whatsappSenderNumber = configuration["OtpDelivery:WhatsApp:SenderNumber"] ?? "UNCONFIGURED_WHATSAPP_SENDER";
    private readonly string emailFromAddress = configuration["OtpDelivery:Email:FromAddress"] ?? "UNCONFIGURED_EMAIL_SENDER";
    private readonly string emailFromName = configuration["OtpDelivery:Email:FromName"] ?? "GoldWallet OTP";

    public async Task SendOtpAsync(User user, string otpCode, IReadOnlyCollection<OtpDeliveryChannel> channels, CancellationToken cancellationToken = default)
    {
        foreach (var channel in channels)
        {
            switch (channel)
            {
                case OtpDeliveryChannel.WhatsApp:
                    logger.LogInformation(
                        "OTP sent via WhatsApp sender {SenderNumber} to user {UserId} ({PhoneNumber}). OTP: {OtpCode}",
                        whatsappSenderNumber,
                        user.Id,
                        user.PhoneNumber,
                        otpCode);
                    break;
                case OtpDeliveryChannel.Email:
                    logger.LogInformation(
                        "OTP sent via Email sender {FromName} <{FromAddress}> to user {UserId} ({Email}). OTP: {OtpCode}",
                        emailFromName,
                        emailFromAddress,
                        user.Id,
                        user.Email,
                        otpCode);
                    break;
            }

            dbContext.AppNotifications.Add(new AppNotification
            {
                UserId = user.Id,
                Title = $"OTP via {channel} ({ResolveSenderLabel(channel)})",
                Body = $"Your verification OTP is {otpCode}. It expires soon.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow
            });
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    private string ResolveSenderLabel(OtpDeliveryChannel channel)
        => channel switch
        {
            OtpDeliveryChannel.WhatsApp => whatsappSenderNumber,
            OtpDeliveryChannel.Email => $"{emailFromName} <{emailFromAddress}>",
            _ => "Unknown sender"
        };
}
