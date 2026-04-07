using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.History.Queries.GetHistory;

public sealed class GetHistoryQueryHandler(IWalletRepository walletRepository)
    : IRequestHandler<GetHistoryQuery, IReadOnlyList<HistoryItemDto>>
{
    public async Task<IReadOnlyList<HistoryItemDto>> Handle(GetHistoryQuery request, CancellationToken cancellationToken)
    {
        var wallet = await walletRepository.GetByCustomerIdAsync(request.CustomerId, cancellationToken);
        if (wallet is null)
        {
            return [];
        }

        return wallet.Transactions
            .OrderByDescending(x => x.CreatedAtUtc)
            .Select(x => new HistoryItemDto(x.Type.ToString(), x.Reference, x.Amount, x.Currency, x.CreatedAtUtc))
            .ToList();
    }
}
