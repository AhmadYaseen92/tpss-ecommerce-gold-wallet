using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface INotificationService
{
    Task<NotificationDto> CreateAsync(CreateNotificationRequestDto request, CancellationToken cancellationToken = default);
    Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<int> GetUnreadCountAsync(int userId, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default);
    Task MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default);
    Task RegisterPushTokenAsync(int userId, RegisterPushTokenRequestDto request, CancellationToken cancellationToken = default);
    Task UnregisterPushTokenAsync(int userId, UnregisterPushTokenRequestDto request, CancellationToken cancellationToken = default);
}
