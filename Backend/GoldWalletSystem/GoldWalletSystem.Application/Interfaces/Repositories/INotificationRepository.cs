using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;

namespace GoldWalletSystem.Application.Interfaces.Repositories;

public interface INotificationRepository
{
    Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default);
}
