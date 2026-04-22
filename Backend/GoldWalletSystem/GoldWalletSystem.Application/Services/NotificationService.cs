using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;
using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Services;

public class NotificationService(
    INotificationRepository notificationRepository,
    INotificationRealtimePublisher realtimePublisher,
    IPushNotificationSender pushNotificationSender) : INotificationService
{
    public async Task<NotificationDto> CreateAsync(CreateNotificationRequestDto request, CancellationToken cancellationToken = default)
    {
        var entity = new AppNotification
        {
            UserId = request.UserId,
            Type = request.Type,
            ReferenceId = request.ReferenceId,
            ReferenceType = request.ReferenceType,
            ActionUrl = request.ActionUrl,
            ImageUrl = request.ImageUrl,
            Role = request.Role,
            Priority = request.Priority,
            Title = request.Title,
            Body = request.Body,
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow
        };

        var created = await notificationRepository.CreateAsync(entity, cancellationToken);
        var unreadCount = await notificationRepository.GetUnreadCountAsync(request.UserId, cancellationToken);
        await realtimePublisher.PublishCreatedAsync(created, unreadCount, cancellationToken);
        var tokens = await notificationRepository.GetActivePushTokensAsync(request.UserId, cancellationToken);
        await pushNotificationSender.SendAsync(created, tokens, cancellationToken);
        return created;
    }

    public Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => notificationRepository.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);

    public Task<int> GetUnreadCountAsync(int userId, CancellationToken cancellationToken = default)
        => notificationRepository.GetUnreadCountAsync(userId, cancellationToken);

    public async Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default)
    {
        await notificationRepository.MarkAsReadAsync(userId, notificationId, cancellationToken);
        var unreadCount = await notificationRepository.GetUnreadCountAsync(userId, cancellationToken);
        await realtimePublisher.PublishReadAsync(userId, notificationId, unreadCount, cancellationToken);
    }

    public async Task MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default)
    {
        await notificationRepository.MarkAllAsReadAsync(userId, cancellationToken);
        var unreadCount = await notificationRepository.GetUnreadCountAsync(userId, cancellationToken);
        await realtimePublisher.PublishAllReadAsync(userId, unreadCount, cancellationToken);
    }

    public Task RegisterPushTokenAsync(int userId, RegisterPushTokenRequestDto request, CancellationToken cancellationToken = default)
    {
        var entity = new UserPushToken
        {
            UserId = userId,
            Platform = request.Platform,
            DeviceToken = request.DeviceToken,
            DeviceName = request.DeviceName,
            IsActive = true,
            CreatedAtUtc = DateTime.UtcNow
        };
        return notificationRepository.RegisterPushTokenAsync(entity, cancellationToken);
    }

    public Task UnregisterPushTokenAsync(int userId, UnregisterPushTokenRequestDto request, CancellationToken cancellationToken = default)
        => notificationRepository.UnregisterPushTokenAsync(userId, request.DeviceToken, cancellationToken);
}
