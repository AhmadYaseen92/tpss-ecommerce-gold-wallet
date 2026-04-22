using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;

using GoldWalletSystem.Domain.Entities;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface INotificationRepository
{
    Task<NotificationDto> CreateAsync(AppNotification notification, CancellationToken cancellationToken = default);
    Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<int> GetUnreadCountAsync(int userId, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default);
    Task MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default);
    Task RegisterPushTokenAsync(UserPushToken token, CancellationToken cancellationToken = default);
    Task UnregisterPushTokenAsync(int userId, string deviceToken, CancellationToken cancellationToken = default);
    Task<List<UserPushToken>> GetActivePushTokensAsync(int userId, CancellationToken cancellationToken = default);
}
