using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Dashboard.Queries.GetDashboard;

public sealed record GetDashboardQuery(Guid CustomerId) : IRequest<DashboardDto>;
