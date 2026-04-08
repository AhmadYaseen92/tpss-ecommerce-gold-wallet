using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Application.Interfaces.Services;

namespace GoldWalletSystem.Application.Services;

public class NotificationService(INotificationRepository notificationRepository) : INotificationService
{
    public Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => notificationRepository.GetByUserIdAsync(userId, pageNumber, pageSize, cancellationToken);

    public Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default)
        => notificationRepository.MarkAsReadAsync(userId, notificationId, cancellationToken);
}
