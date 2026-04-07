using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.AccountSummary.Queries.GetAccountSummary;

public sealed record GetAccountSummaryQuery(Guid CustomerId) : IRequest<AccountSummaryDto>;
