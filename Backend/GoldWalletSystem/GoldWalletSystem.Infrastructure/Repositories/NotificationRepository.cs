using GoldWalletSystem.Application.DTOs.Common;
using GoldWalletSystem.Application.DTOs.Notifications;
using GoldWalletSystem.Application.Interfaces.Repositories;
using GoldWalletSystem.Domain.Entities;
using GoldWalletSystem.Infrastructure.Database.Context;
using Microsoft.EntityFrameworkCore;

namespace GoldWalletSystem.Infrastructure.Repositories;

public class NotificationRepository(AppDbContext dbContext) : INotificationRepository
{
    public async Task<NotificationDto> CreateAsync(AppNotification notification, CancellationToken cancellationToken = default)
    {
        var duplicate = await dbContext.AppNotifications
            .AsNoTracking()
            .Where(x => x.UserId == notification.UserId
                        && x.Title == notification.Title
                        && x.Body == notification.Body
                        && x.ReferenceId == notification.ReferenceId
                        && x.ReferenceType == notification.ReferenceType
                        && x.CreatedAtUtc >= DateTime.UtcNow.AddSeconds(-30))
            .OrderByDescending(x => x.Id)
            .FirstOrDefaultAsync(cancellationToken);

        if (duplicate is not null)
        {
            return Map(duplicate);
        }

        dbContext.AppNotifications.Add(notification);
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(notification);
    }

    public async Task<PagedResult<NotificationDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = dbContext.AppNotifications.AsNoTracking().Where(x => x.UserId == userId).OrderByDescending(x => x.CreatedAtUtc);
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize)
            .Select(x => new NotificationDto(
                x.Id,
                x.UserId,
                x.Type,
                x.ReferenceType,
                x.ReferenceId,
                x.ActionUrl,
                x.ImageUrl,
                x.Title,
                x.Body,
                x.IsRead,
                x.ReadAtUtc,
                x.Priority,
                x.CreatedAtUtc))
            .ToListAsync(cancellationToken);

        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
        return new PagedResult<NotificationDto>(items, totalCount, pageNumber, pageSize, totalPages);
    }

    public Task<int> GetUnreadCountAsync(int userId, CancellationToken cancellationToken = default)
        => dbContext.AppNotifications.CountAsync(x => x.UserId == userId && !x.IsRead, cancellationToken);

    public async Task MarkAsReadAsync(int userId, int notificationId, CancellationToken cancellationToken = default)
    {
        var entity = await dbContext.AppNotifications.FirstOrDefaultAsync(x => x.Id == notificationId && x.UserId == userId, cancellationToken)
            ?? throw new InvalidOperationException("Notification was not found");
        if (entity.IsRead) return;
        entity.IsRead = true;
        entity.ReadAtUtc = DateTime.UtcNow;
        entity.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default)
    {
        var unread = await dbContext.AppNotifications
            .Where(x => x.UserId == userId && !x.IsRead)
            .ToListAsync(cancellationToken);
        var utcNow = DateTime.UtcNow;
        foreach (var item in unread)
        {
            item.IsRead = true;
            item.ReadAtUtc = utcNow;
            item.UpdatedAtUtc = utcNow;
        }

        if (unread.Count > 0)
            await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task RegisterPushTokenAsync(UserPushToken token, CancellationToken cancellationToken = default)
    {
        var existing = await dbContext.UserPushTokens.FirstOrDefaultAsync(
            x => x.UserId == token.UserId && x.DeviceToken == token.DeviceToken && x.Platform == token.Platform,
            cancellationToken);

        if (existing is null)
        {
            dbContext.UserPushTokens.Add(token);
        }
        else
        {
            existing.DeviceName = token.DeviceName;
            existing.IsActive = true;
            existing.UpdatedAtUtc = DateTime.UtcNow;
        }

        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UnregisterPushTokenAsync(int userId, string deviceToken, CancellationToken cancellationToken = default)
    {
        var token = await dbContext.UserPushTokens.FirstOrDefaultAsync(
            x => x.UserId == userId && x.DeviceToken == deviceToken,
            cancellationToken);
        if (token is null) return;

        token.IsActive = false;
        token.UpdatedAtUtc = DateTime.UtcNow;
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task<List<UserPushToken>> GetActivePushTokensAsync(int userId, CancellationToken cancellationToken = default)
        => dbContext.UserPushTokens.AsNoTracking().Where(x => x.UserId == userId && x.IsActive).ToListAsync(cancellationToken);

    private static NotificationDto Map(AppNotification x)
        => new(
            x.Id,
            x.UserId,
            x.Type,
            x.ReferenceType,
            x.ReferenceId,
            x.ActionUrl,
            x.ImageUrl,
            x.Title,
            x.Body,
            x.IsRead,
            x.ReadAtUtc,
            x.Priority,
            x.CreatedAtUtc);
}
