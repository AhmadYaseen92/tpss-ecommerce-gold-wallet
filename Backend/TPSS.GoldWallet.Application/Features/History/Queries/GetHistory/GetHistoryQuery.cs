using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.History.Queries.GetHistory;

public sealed record GetHistoryQuery(Guid CustomerId) : IRequest<IReadOnlyList<HistoryItemDto>>;
