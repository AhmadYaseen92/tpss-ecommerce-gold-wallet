using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;

namespace GoldWalletSystem.Application.Interfaces.Services;

public interface INotificationService
{
    Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default);
}
