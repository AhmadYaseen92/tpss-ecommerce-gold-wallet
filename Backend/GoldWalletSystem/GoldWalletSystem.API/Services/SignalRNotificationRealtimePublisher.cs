using GoldWalletSystem.API.Hubs;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Services;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Options;

namespace GoldWalletSystem.API.Services;

public class SignalRNotificationRealtimePublisher(
    IHubContext<MarketplaceHub> hubContext,
    IOptions<GoldWalletSystem.Infrastructure.Services.NotificationDeliveryOptions> optionsAccessor) : INotificationRealtimePublisher
{
    public Task PublishCreatedAsync(NotificationDto notification, int unreadCount, CancellationToken cancellationToken = default)
    {
        if (!optionsAccessor.Value.EnableSignalRDelivery) return Task.CompletedTask;
        return hubContext.Clients.User(notification.UserId.ToString()).SendAsync("NotificationCreated", new
        {
            notification,
            unreadCount
        }, cancellationToken);
    }

    public Task PublishReadAsync(int userId, int notificationId, int unreadCount, CancellationToken cancellationToken = default)
    {
        if (!optionsAccessor.Value.EnableSignalRDelivery) return Task.CompletedTask;
        return hubContext.Clients.User(userId.ToString()).SendAsync("NotificationRead", new
        {
            notificationId,
            unreadCount
        }, cancellationToken);
    }

    public Task PublishAllReadAsync(int userId, int unreadCount, CancellationToken cancellationToken = default)
    {
        if (!optionsAccessor.Value.EnableSignalRDelivery) return Task.CompletedTask;
        return hubContext.Clients.User(userId.ToString()).SendAsync("AllNotificationsRead", new
        {
            unreadCount
        }, cancellationToken);
    }
}
