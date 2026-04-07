using Microsoft.EntityFrameworkCore;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Domain.Entities;
using TPSS.GoldWallet.Infrastructure.Persistence;

namespace TPSS.GoldWallet.Infrastructure.Repositories;

public sealed class NotificationRepository(AppDbContext dbContext) : INotificationRepository
{
    public async Task<IReadOnlyList<NotificationMessage>> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default)
        => await dbContext.Notifications.Where(x => x.CustomerId == customerId).ToListAsync(cancellationToken);
}
