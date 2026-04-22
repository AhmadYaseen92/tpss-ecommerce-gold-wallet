using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using Microsoft.Extensions.Logging;

namespace GoldWalletSystem.Infrastructure.Services;

public class PushNotificationSender(ILogger<PushNotificationSender> logger) : IPushNotificationSender
{
    public Task SendAsync(NotificationDto notification, IReadOnlyCollection<UserPushToken> tokens, CancellationToken cancellationToken = default)
    {
        if (tokens.Count == 0) return Task.CompletedTask;
        logger.LogInformation(
            "Push placeholder invoked for notification {NotificationId}. User: {UserId}, Tokens: {TokenCount}",
            notification.Id,
            notification.UserId,
            tokens.Count);
        return Task.CompletedTask;
    }
}
