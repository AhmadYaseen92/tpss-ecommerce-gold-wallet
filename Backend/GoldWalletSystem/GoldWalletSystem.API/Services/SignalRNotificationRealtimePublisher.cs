using GoldWalletSystem.API.Hubs;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.SignalR;

namespace GoldWalletSystem.API.Services;

public class SignalRNotificationRealtimePublisher(IHubContext<MarketplaceHub> hubContext) : INotificationRealtimePublisher
{
    public Task PublishCreatedAsync(NotificationDto notification, int unreadCount, CancellationToken cancellationToken = default)
        => hubContext.Clients.User(notification.UserId.ToString()).SendAsync("NotificationCreated", new
        {
            notification,
            unreadCount
        }, cancellationToken);

    public Task PublishReadAsync(int userId, int notificationId, int unreadCount, CancellationToken cancellationToken = default)
        => hubContext.Clients.User(userId.ToString()).SendAsync("NotificationRead", new
        {
            notificationId,
            unreadCount
        }, cancellationToken);

    public Task PublishAllReadAsync(int userId, int unreadCount, CancellationToken cancellationToken = default)
        => hubContext.Clients.User(userId.ToString()).SendAsync("AllNotificationsRead", new
        {
            unreadCount
        }, cancellationToken);
}
