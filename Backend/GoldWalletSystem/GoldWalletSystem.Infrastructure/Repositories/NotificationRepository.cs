using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class NotificationRepository(AppDbContext dbContext) : INotificationRepository
{
    public async Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.AppNotifications.AsNoTracking().Where(x => x.UserId == userId).OrderByDescending(x => x.CreatedAtUtc);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize)
            .Select(x => new NotificationDto(x.Id, x.UserId, x.Title, x.Body, x.IsRead, x.CreatedAtUtc))
            .ToListAsync(cancellationToken);

        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
        return new PagedResult<NotificationDto>(items, totalCount, pageNumber, pageSize, totalPages);
    }

    public async Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.AppNotifications.FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId, cancellationToken)
            ?? throw new InvalidOperationException("Notification was not found");
        entity.IsRead = true;
        entity.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
