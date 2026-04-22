using GoldWalletSystem.Application.DTOs.Notifications;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface INotificationRealtimePublisher
{
    Task PublishCreatedAsync(NotificationDto notification, int unreadCount, CancellationToken cancellationToken = default);
    Task PublishReadAsync(int userId, int notificationId, int unreadCount, CancellationToken cancellationToken = default);
    Task PublishAllReadAsync(int userId, int unreadCount, CancellationToken cancellationToken = default);
}
