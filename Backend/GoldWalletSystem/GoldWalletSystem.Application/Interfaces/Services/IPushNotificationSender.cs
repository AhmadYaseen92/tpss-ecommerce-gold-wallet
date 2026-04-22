using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface IPushNotificationSender
{
    Task SendAsync(NotificationDto notification, IReadOnlyCollection<UserPushToken> tokens, CancellationToken cancellationToken = default);
}
