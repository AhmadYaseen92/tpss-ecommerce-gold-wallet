using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Infrastructure.Services;

public class NotificationRealtimePublisher : INotificationRealtimePublisher
{
    public Task PublishCreatedAsync(NotificationDto notification, int unreadCount, CancellationToken cancellationToken = default)
        => Task.CompletedTask;

    public Task PublishReadAsync(int userId, int notificationId, int unreadCount, CancellationToken cancellationToken = default)
        => Task.CompletedTask;

    public Task PublishAllReadAsync(int userId, int unreadCount, CancellationToken cancellationToken = default)
        => Task.CompletedTask;
}
