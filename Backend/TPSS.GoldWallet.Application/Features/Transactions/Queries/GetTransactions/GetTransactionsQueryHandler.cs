using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.Transactions.Queries.GetTransactions;

public sealed class GetTransactionsQueryHandler(ITradeTransactionRepository tradeTransactionRepository)
    : IRequestHandler<GetTransactionsQuery, IReadOnlyList<TradeTransactionDto>>
{
    public async Task<IReadOnlyList<TradeTransactionDto>> Handle(GetTransactionsQuery request, CancellationToken cancellationToken)
    {
        var rows = await tradeTransactionRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        return rows.OrderByDescending(x => x.DateUtc)
            .Select(x => new TradeTransactionDto(x.Id.ToString(), x.Title, x.Type, x.Status, x.DateUtc, x.Amount, x.SellerName, x.SecondaryAmount))
            .ToList();
    }
}
