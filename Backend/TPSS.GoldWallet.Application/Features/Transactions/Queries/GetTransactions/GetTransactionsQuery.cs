using MediatR;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Transactions.Queries.GetTransactions;

public sealed record GetTransactionsQuery(Guid CustomerId) : IRequest<IReadOnlyList<TradeTransactionDto>>;
