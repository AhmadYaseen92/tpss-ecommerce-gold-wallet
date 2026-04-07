using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Notifications.Queries.GetNotifications;

public sealed class GetNotificationsQueryHandler(INotificationRepository notificationRepository)
    : IRequestHandler<GetNotificationsQuery, IReadOnlyList<NotificationDto>>
{
    public async Task<IReadOnlyList<NotificationDto>> Handle(GetNotificationsQuery request, CancellationToken cancellationToken)
    {
        var rows = await notificationRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        return rows.OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new NotificationDto(x.Title, x.Description, x.Category, x.IsRead, x.CreatedAtUtc))
            .ToList();
    }
}
