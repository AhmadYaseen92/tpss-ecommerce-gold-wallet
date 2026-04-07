using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Notifications.Queries.GetNotifications;

public sealed record GetNotificationsQuery(Guid CustomerId) : IRequest<IReadOnlyList<NotificationDto>>;
