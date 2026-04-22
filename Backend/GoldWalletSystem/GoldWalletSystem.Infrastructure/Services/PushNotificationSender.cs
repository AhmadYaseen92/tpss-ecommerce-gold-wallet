using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace GoldWalletSystem.Infrastructure.Services;

public class PushNotificationSender(
    ILogger<PushNotificationSender> logger,
    IOptions<NotificationDeliveryOptions> optionsAccessor) : IPushNotificationSender
{
    public Task SendAsync(NotificationDto notification, IReadOnlyCollection<UserPushToken> tokens, CancellationToken cancellationToken = default)
    {
        var options = optionsAccessor.Value;
        if (!options.EnablePushDelivery) return Task.CompletedTask;
        if (tokens.Count == 0) return Task.CompletedTask;
        logger.LogInformation(
            "Push placeholder invoked for notification {NotificationId}. User: {UserId}, Tokens: {TokenCount}, Provider: {Provider}",
            notification.Id,
            notification.UserId,
            tokens.Count,
            options.PushProvider);
        return Task.CompletedTask;
    }
}
