using TPSS.GoldWallet.Domain.Entities;

namespace TPSS.GoldWallet.Application.Abstractions;

public interface INotificationRepository
{
    Task<IReadOnlyList<NotificationMessage>> GetByCustomerIdAsync(Guid customerId, CancellationToken cancellationToken = default);
}
