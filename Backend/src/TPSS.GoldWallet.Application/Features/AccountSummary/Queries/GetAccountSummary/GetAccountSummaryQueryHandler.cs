using MediatR;
using TPSS.GoldWallet.Application.Abstractions;
using TPSS.GoldWallet.Application.DTOs;

namespace TPSS.GoldWallet.Application.Features.AccountSummary.Queries.GetAccountSummary;

public sealed class GetAccountSummaryQueryHandler(IAccountSummaryRepository accountSummaryRepository)
    : IRequestHandler<GetAccountSummaryQuery, AccountSummaryDto>
{
    public async Task<AccountSummaryDto> Handle(GetAccountSummaryQuery request, CancellationToken cancellationToken)
    {
        var row = await accountSummaryRepository.GetLatestByCustomerIdAsync(request.CustomerId, cancellationToken);
        if (row is null)
        {
            return new AccountSummaryDto(0, 0, 0, 0, 0, 0, 0);
        }

        return new AccountSummaryDto(row.HoldMarketValue, row.GoldValue, row.SilverValue, row.JewelleryValue, row.AvailableCash, row.UsdtBalance, row.EDirhamBalance);
    }
}
